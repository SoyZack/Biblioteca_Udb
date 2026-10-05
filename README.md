# udb_biblioteca

Aplicación web para gestionar libros, estudiantes y préstamos de una biblioteca.
Jakarta EE 10 sobre JSP, con acceso a datos manual por JDBC (no usa JPA ni JNDI).

- Base de datos: `bibliotecaudb` en MySQL
- Empaquetado: WAR, desplegado en GlassFish
- JDBC: clase `Conexion` propia, cada bean abre y cierra su conexión

## Requisitos

- JDK 11 o superior
- NetBeans 21 con GlassFish 10 (server de applications)
- MySQL 8 corriendo en `localhost:3306`
- La base `bibliotecaudb` ya creada

## Puesta en marcha

1. Levanta MySQL y verifica que existe la base con las cuatro tablas:

   ```sql
   CREATE DATABASE IF NOT EXISTS bibliotecaudb
     CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   USE bibliotecaudb;
   SHOW TABLES;  -- categorias, estudiantes, libros, prestamos
   ```

2. Ajusta las credenciales en `src/main/java/udb_biblioteca/Conexion.java`. Por defecto
   son `root` con contraseña vacía.

3. El driver MySQL viene declarado en el `pom.xml` con scope de compilación, así que se
   empaqueta dentro de `WEB-INF/lib` del WAR. No hace falta copiarlo a mano.

4. Desde NetBeans: Run Project. Se despliega en GlassFish y queda disponible en
   `http://localhost:8080/udb_biblioteca/`.

## Base de datos

Las cuatro tablas usan **MyISAM**. Esto tiene consecuencias importantes, léelas antes de
la sección "Trampas".

### `categorias`

| Columna | Tipo | Clave |
|---|---|---|
| `id_categoria` | int, auto_increment | PK |
| `nombre_categoria` | varchar(80) | |

### `estudiantes`

| Columna | Tipo | Clave |
|---|---|---|
| `id_estudiante` | int, auto_increment | PK |
| `carnet` | varchar(10) | único |
| `nombre_estudiante` | varchar(100) | |
| `carrera` | varchar(80) | |
| `telefono` | varchar(9) | |

### `libros`

| Columna | Tipo | Clave |
|---|---|---|
| `id_libro` | int, auto_increment | PK |
| `titulo` | varchar(150) | |
| `autor` | varchar(100) | texto, no tabla |
| `isbn` | varchar(20) | único |
| `id_categoria` | int | índice `fk_libros_categorias` |
| `cantidad_disponible` | int | default 1 |

Nota el detalle de este proyecto: el autor se guarda como texto dentro de `libros`. No
hay tabla `autores`.

### `prestamos`

| Columna | Tipo | Clave |
|---|---|---|
| `id_prestamo` | int, auto_increment | PK |
| `id_estudiante` | int | índice `fk_prestamos_estudiantes` |
| `id_libro` | int | índice `fk_prestamos_libros` |
| `fecha_prestamo` | date | |
| `fecha_devolucion` | date | |
| `estado` | varchar(20) | default `'Activo'` |

Los dos valores de `estado` que usa la aplicación son `Activo` y `Devuelto`.

## Estructura

```
src/main/java/udb_biblioteca/
  Conexion.java       Abre la conexión JDBC
  CategoriaBean.java
  EstudianteBean.java
  LibroBean.java
  PrestamoBean.java   Incluye registrar y devolver préstamos

src/main/webapp/
  index.jsp                 Portada
  navbar.jsp                Menú superior, se incluye en todas las páginas
  registroLibro.jsp         Formulario de libro
  controllerLibro.jsp       Procesa el alta
  registroEstudiante.jsp    Formulario de estudiante
  controllerEstudiante.jsp  Procesa el alta
  registroPrestamo.jsp      Formulario de préstamo
  controllerPrestamo.jsp    Procesa el préstamo
  listaPrestamo.jsp         Listado con devolución
  devolverPrestamo.jsp      Procesa la devolución y redirige
```

El nombre de archivo importa y no es uniforme: los formularios y el listado están en
singular (`registroLibro.jsp`, `listaPrestamo.jsp`), los controladores igual. Si un
enlace no coincide con el nombre real del archivo sale un 404, no un error de
compilación, así que conviene revisarlos cuando se agrega una página.

## Cómo funciona una página

No hay servlets. Cada operación tiene su propio JSP, que hace de controlador:

1. El JSP declara el bean con `<jsp:useBean>`. Los que procesan formularios usan
   `scope="request"`; los que solo pintan listas usan `scope="page"`.
2. `<jsp:setProperty name="x" property="*">` copia todos los parámetros del formulario a
   los setters del bean que tengan el mismo nombre. Por eso los atributos `name` del
   HTML tienen que coincidir exactamente con las propiedades del bean.
3. Se llama al método: `guardar()`, `registrarPrestamo()`, `getListaPrestamos()`.
4. Se muestra el resultado con un `alert` de Bootstrap.

Cada método abre su propia conexión con try-with-resources y la cierra al terminar.

### Registrar un libro

`registroLibro.jsp` llena el combo de categorías con `getListaCategorias()` y envía por
POST a `controllerLibro.jsp`, que mapea los campos y llama a `LibroBean.guardar()`.

### Registrar un préstamo

`registroPrestamo.jsp` necesita dos combos: estudiantes (`getListaEstudiantes()`) y
libros (`getListaLibros()`). Este último hace un `INNER JOIN` con `categorias`, así que
un libro con categoría inexistente no sale en el desplegable.

`PrestamoBean.registrarPrestamo()` hace tres cosas en orden: comprueba que queden
ejemplares, inserta el préstamo con estado `Activo`, y descuenta una unidad del stock.

### Ver préstamos

`listaPrestamo.jsp` muestra el estado de dos formas. `estado` es lo que está guardado en
la base; `getEstadoCalculado()` es lo que la aplicación deduce comparando
`fecha_devolucion` con la fecha de hoy. Un préstamo puede estar guardado como `Activo` y
mostrarse como `Vencido` si ya pasó su fecha.

`estado` solo pasa a `Devuelto` cuando alguien pulsa el botón Devolver, que va por POST a
`devolverPrestamo.jsp`.

## Trampas

### MyISAM no aplica claves foráneas

Las tablas no son InnoDB. Los índices `fk_libros_categorias`, `fk_prestamos_libros` y
`fk_prestamos_estudiantes` son índices normales, no restricciones, así que MySQL acepta
un `id_categoria` o un `id_libro` que no existe sin avisar.

Para que la base te proteja:

```sql
ALTER TABLE libros      ENGINE=InnoDB;
ALTER TABLE prestamos   ENGINE=InnoDB;
ALTER TABLE estudiantes ENGINE=InnoDB;
ALTER TABLE categorias  ENGINE=InnoDB;
```

### MyISAM no soporta transacciones

`PrestamoBean.registrarPrestamo()` y `devolverPrestamo()` escriben con
`setAutoCommit(false)` y `commit()` / `rollback()`. Con MyISAM esas órdenes no tienen
efecto: no hay nada que deshacer. Si el INSERT del préstamo funciona y el UPDATE del
stock falla, el préstamo queda registrado y el stock no se descuenta.

El mismo problema afecta a `devolverPrestamo()`: suma stock sin comprobar que el préstamo
estuviera realmente activo, así que llamarlo dos veces sobre el mismo préstamo suma dos
unidades al stock en lugar de una.

### El chequeo de stock no cubre el libro inexistente

En `registrarPrestamo()` la disponibilidad se comprueba con `if (rs.next())`, y ese `if`
no tiene `else`. Si el libro no existe, `rs.next()` devuelve `false`, el bloque no se
entra y el código sigue adelante e inserta el préstamo de todos modos. Con MyISAM la
inserción se completa y queda un préstamo huérfano.

### El INNER JOIN oculta libros

`LibroBean.getListaLibros()` hace `INNER JOIN` con `categorias`. Un libro guardado con una
categoría inválida existe en la base pero no aparece en ningún listado. Para
diagnosticarlo:

```sql
SELECT l.id_libro, l.titulo, l.id_categoria
  FROM libros l
  LEFT JOIN categorias c ON l.id_categoria = c.id_categoria
 WHERE c.id_categoria IS NULL;
```

### El ISBN y el carnet son únicos

`libros.isbn` y `estudiantes.carnet` tienen índice único. Registrar dos veces el mismo
isbn o carnet lanza una violación de clave duplicada y el bean devuelve `false`. El
formulario marca ambos campos como `required` pero no como únicos, así que el error solo
aparece al enviar.

Para diagnosticarlo, `LibroBean` y `EstudianteBean` guardan el texto del error de MySQL
en `ultimoError`, y los controladores lo muestran debajo del mensaje.

## Problemas frecuentes

**Error 500 al registrar libro, estudiante o préstamo**

Casi siempre es `conexion.jsp`. Si ese archivo existe, revisa la directiva
`<%@page import=...%>`: si está mal escrita, el contenedor no logra traducir el JSP y
devuelve 500. En esta versión el archivo ya no existe y las conexiones las abre cada
bean, así que si reaparece el error revisa la URL y las credenciales de `Conexion.java`.

**Error 500 en una página de listado**

Revisa dos cosas: que el nombre del paquete sea `udb_biblioteca` con guion bajo (no
`udb.biblioteca`), y que todo bean que se use en un `<% for(...) %>` esté declarado antes
con `<jsp:useBean>`.

**Error 404 al ver préstamos**

Un enlace apunta a `listaPrestamos.jsp` (con s) y el archivo se llama
`listaPrestamo.jsp`. Comprueba los `href` del `navbar.jsp`.

**Los desplegables salen vacíos**

Los beans devuelven listas vacías cuando la consulta falla y escriben el error en la
consola de GlassFish, no en la página. Revisa el log del servidor: ahí está el motivo
real.

**Los acentos se ven como caracteres raros en el menú**

El archivo debe guardarse en UTF-8, que es lo que declara `pageEncoding="UTF-8"`. Si se
guarda en Windows-1252, "Préstamos" se ve como "Pr�stamos".

**Sale "Error de conexión" en vez de un resultado**

`Conexion.getConexion()` lanza `SQLException` con el motivo, y los métodos que devuelven
texto lo incluyen en el mensaje que se muestra.

## Notas

- `persistence.xml` está presente pero vacío: este proyecto no usa JPA. No hay que
  tocarlo ni se está leyendo en ningún momento.
- `beans.xml` también está vacío y no hace falta. Los beans de `udb_biblioteca` no son
  CDI: los crea cada JSP con `<jsp:useBean>` y se usan con JDBC directo, sin `@Inject`.
  Los dos archivos podrían borrarse sin cambiar nada.
- La dependencia `jakarta.jakartaee-api` va con scope `provided` porque GlassFish ya
  trae el contenedor. El driver de MySQL, en cambio, va con scope normal a propósito:
  tiene que acabar en `WEB-INF/lib` para que la aplicación lo encuentre en runtime.
- `web.xml` solo define el tiempo de sesión. No hay servlets declarados.
- Los dos `</head>` duplicados que tenían `controllerPrestamo.jsp` y `listaPrestamo.jsp`
  se quitaron. No afectan al funcionamiento, pero rompían la validación del HTML.
- Los JSP guardan los archivos en UTF-8. Si un editor te pregunta la codificación al
  abrirlos, no la cambies.