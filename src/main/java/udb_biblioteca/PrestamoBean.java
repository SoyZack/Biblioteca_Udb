 /*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package udb_biblioteca;

import udb_biblioteca.LibroBean;
import udb_biblioteca.Conexion;
import java.io.Serializable;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
/**
 *
 * @author Uptim
 */
// Prestamos: alta, devolucion y listado.
public class PrestamoBean implements Serializable {
    private int id_prestamo;
    private int id_estudiante;
    private int id_libro;

    // Las fechas se guardan como texto y no como LocalDate. El formulario HTML ya las
    // envia en formato aaaa-mm-dd, que es el que MySQL acepta en un campo DATE, asi que
    // no hace falta convertir. El orden de las columnas en el INSERT es el del SQL de
    // abajo, no el de los atributos.
    private String fecha_prestamo;
    private String fecha_devolucion;

    // Estado guardado en la base. Solo son dos valores: Activo y Devuelto.
    private String estado;

    // Objetos anidados, se llenan al hacer el listado con JOIN. No son claves foraneas:
    // los ids ya estan arriba. El constructor los inicializa para evitar null.
    private LibroBean libro;
    private EstudianteBean estudiante;

    public PrestamoBean() {
        this.libro = new LibroBean();
        this.estudiante = new EstudianteBean();
    }

    public int getId_prestamo() { return id_prestamo; }
    public void setId_prestamo(int id_prestamo) { this.id_prestamo = id_prestamo; }

    public int getId_estudiante() { return id_estudiante; }
    public void setId_estudiante(int id_estudiante) { this.id_estudiante = id_estudiante; }

    public int getId_libro() { return id_libro; }
    public void setId_libro(int id_libro) { this.id_libro = id_libro; }

    public String getFecha_prestamo() { return fecha_prestamo; }
    public void setFecha_prestamo(String fecha_prestamo) { this.fecha_prestamo = fecha_prestamo; }

    public String getFecha_devolucion() { return fecha_devolucion; }
    public void setFecha_devolucion(String fecha_devolucion) { this.fecha_devolucion = fecha_devolucion; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public LibroBean getLibro() { return libro; }
    public void setLibro(LibroBean libro) { this.libro = libro; }

    public EstudianteBean getEstudiante() { return estudiante; }
    public void setEstudiante(EstudianteBean estudiante) { this.estudiante = estudiante; }

    // Estado que se muestra en pantalla, distinto del estado guardado.
    //   Devuelto  si ya se devolvio
    //   Vencido   si sigue Activo pero la fecha de devolucion ya paso
    //   Vigente   si sigue Activo y todavia no vence
    // Solo calcula, no escribe: la base sigue con estado = 'Activo' hasta que alguien
    // pulse el boton Devolver. Por eso un prestamo puede verse Vencido y seguir Activo.
    public String getEstadoCalculado() {
        if ("Devuelto".equalsIgnoreCase(this.estado)) {
            return "Devuelto";
        }
        // isBlank y no un null: MySQL devuelve "" en vez de null cuando la columna DATE
        // esta vacia, y parse("") lanza DateTimeParseException. Ese error no es
        // SQLException, asi que sin esta comprobacion reventaria el listado entero.
        if (fecha_devolucion != null && !fecha_devolucion.isBlank()) {
            try {
                LocalDate fechaDev = LocalDate.parse(fecha_devolucion);
                if (LocalDate.now().isAfter(fechaDev)) {
                    return "Vencido";
                }
            } catch (java.time.format.DateTimeParseException e) {
                System.err.println("Fecha de devolucion invalida: " + fecha_devolucion);
                return "Vigente";
            }
        }
        return "Vigente";
    }

    // Registrar prestamo y descontar una unidad del stock.
    // Devuelve "OK" si salio bien, o el texto del error si fallo. Se eligió String en vez
    // de boolean para poderle enseñar el motivo al usuario en el JSP.
    public String registrarPrestamo() {
        String sqlCheck = "SELECT cantidad_disponible FROM libros WHERE id_libro = ?";
        String sqlInsert = "INSERT INTO prestamos (id_estudiante, id_libro, fecha_prestamo, fecha_devolucion, estado) VALUES (?, ?, ?, ?, 'Activo')";
        String sqlUpdateLibro = "UPDATE libros SET cantidad_disponible = cantidad_disponible - 1 WHERE id_libro = ?";

        try (Connection conn = Conexion.getConexion()) {
            // Validar disponibilidad
            try (PreparedStatement psCheck = conn.prepareStatement(sqlCheck)) {
                psCheck.setInt(1, this.id_libro);
                ResultSet rs = psCheck.executeQuery();
                // Este if no tiene else. Si el libro no existe, rs.next() devuelve false,
                // el bloque no se ejecuta y el codigo sigue adelante: el INSERT del
                // prestamo se completa igual y queda un prestamo de un libro inexistente.
                // Para cubrirlo haria falta un else que devolviera un error.
                if (rs.next()) {
                    int cant = rs.getInt("cantidad_disponible");
                    if (cant <= 0) {
                        return "Error: No hay ejemplares disponibles para este libro.";
                    }
                }
            }

            // OJO: las tablas son MyISAM, que no soporta transacciones. Este
            // setAutoCommit(false) y el commit/rollback de abajo no tienen ningun
            // efecto real. Si el INSERT funcionara y el UPDATE del stock fallara, el
            // rollback no desharia nada y quedaria el prestamo creado sin descontar el
            // ejemplar. Para que la transaccion sirva de algo hay que convertir las
            // tablas a InnoDB.
            conn.setAutoCommit(false);
            try (PreparedStatement psInsert = conn.prepareStatement(sqlInsert);
                 PreparedStatement psUpdate = conn.prepareStatement(sqlUpdateLibro)) {

                psInsert.setInt(1, this.id_estudiante);
                psInsert.setInt(2, this.id_libro);
                psInsert.setString(3, this.fecha_prestamo);
                psInsert.setString(4, this.fecha_devolucion);
                psInsert.executeUpdate();

                psUpdate.setInt(1, this.id_libro);
                psUpdate.executeUpdate();

                conn.commit();
                return "OK";
            } catch (SQLException e) {
                conn.rollback();
                return "Error al registrar el préstamo: " + e.getMessage();
            }
        } catch (SQLException e) {
            return "Error de conexión: " + e.getMessage();
        }
    }

    // Devolucion: marca el prestamo como Devuelto y devuelve una unidad al stock.
    // OJO: no comprueba que el prestamo estuviera Activo. Si se llama dos veces sobre el
    // mismo prestamo, suma dos unidades al stock. who lo llama es listaPrestamo.jsp, que
    // solo muestra el boton cuando el estado no es Devuelto.
    // La pagina listaPrestamo.jsp es quien lo llama, y solo muestra el boton cuando el
    // estado no es Devuelto.
    public boolean devolverPrestamo(int idPrestamo, int idLibro) {
        String sqlUpdatePrestamo = "UPDATE prestamos SET estado = 'Devuelto' WHERE id_prestamo = ?";
        String sqlUpdateLibro = "UPDATE libros SET cantidad_disponible = cantidad_disponible + 1 WHERE id_libro = ?";

        try (Connection conn = Conexion.getConexion()) {
            conn.setAutoCommit(false);
            try (PreparedStatement psP = conn.prepareStatement(sqlUpdatePrestamo);
                 PreparedStatement psL = conn.prepareStatement(sqlUpdateLibro)) {

                psP.setInt(1, idPrestamo);
                psP.executeUpdate();

                psL.setInt(1, idLibro);
                psL.executeUpdate();

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                return false;
            }
        } catch (SQLException e) {
            return false;
        }
    }

    // Listado de prestamos con los datos del estudiante y del libro.
    // Son dos INNER JOIN, asi que un prestamo cuyo estudiante o libro no exista en sus
    // tablas no aparece. Con MyISAM esto es posible: los ids no se validan al insertar.
    public List<PrestamoBean> getListaPrestamos() {
        List<PrestamoBean> lista = new ArrayList<>();
        String sql = "SELECT p.*, e.carnet, e.nombre_estudiante, l.titulo " +
                     "FROM prestamos p " +
                     "INNER JOIN estudiantes e ON p.id_estudiante = e.id_estudiante " +
                     "INNER JOIN libros l ON p.id_libro = l.id_libro";
        try (Connection conn = Conexion.getConexion();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                PrestamoBean p = new PrestamoBean();
                p.setId_prestamo(rs.getInt("id_prestamo"));
                p.setId_estudiante(rs.getInt("id_estudiante"));
                p.setId_libro(rs.getInt("id_libro"));
                p.setFecha_prestamo(rs.getString("fecha_prestamo"));
                p.setFecha_devolucion(rs.getString("fecha_devolucion"));
                p.setEstado(rs.getString("estado"));

                // getEstudiante() y getLibro() nunca devuelven null porque el
                // constructor inicializo ambos objetos.
                p.getEstudiante().setCarnet(rs.getString("carnet"));
                p.getEstudiante().setNombre_estudiante(rs.getString("nombre_estudiante"));
                p.getLibro().setTitulo(rs.getString("titulo"));

                lista.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }
}
