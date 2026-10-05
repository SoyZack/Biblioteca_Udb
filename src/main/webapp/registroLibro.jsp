<%-- 
    Document   : registroLibro
    Created on : 4 oct 2026, 19:22:58
    Author     : Uptim
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--
    Formulario de alta de libro. No guarda nada: solo pinta el desplegable de categorias
    y envia los datos por POST a controllerLibro.jsp, que es quien los procesa.

    El nombre del paquete es udb_biblioteca con guion bajo, igual que la carpeta
    src/main/java/udb_biblioteca/. No es udb.biblioteca: ese paquete no existe y daria 500.
--%>

<%-- El import hace falta porque el bucle de mas abajo declara el tipo
     CategoriaBean directamente. --%>
<%@ page import="udb_biblioteca.CategoriaBean" %>

<%-- useBean crea el objeto. scope="page" porque solo hace falta mientras se dibuja
     esta pagina. getListaCategorias() devuelve lista vacia si la consulta falla, y en
     ese caso el desplegable queda con la unica opcion "-- Seleccione Categoria --". --%>
<jsp:useBean id="catBean" class="udb_biblioteca.CategoriaBean" scope="page" />

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Registro de Libro</title>
</head>
<body class="bg-light">
    <%@ include file="navbar.jsp" %>
    
    <div class="container col-md-6 my-4">
        <div class="card shadow-sm p-4">
            <h2 class="mb-4 text-primary">Registrar Nuevo Libro</h2>
            
            <%-- method="POST" porque se envian datos a la base. Cada name del formulario
                 tiene que coincidir con una propiedad de LibroBean: eso es lo que hace
                 <jsp:setProperty property="*"> en controllerLibro.jsp. Si un name no
                 coincide con ninguna propiedad, el valor se pierde sin dar error. --%>
            <form action="controllerLibro.jsp" method="POST">
                <div class="mb-3">
                    <label class="form-label">Título:</label>
                    <input type="text" name="titulo" class="form-control" required />
                </div>
                
                <div class="mb-3">
                    <label class="form-label">Autor:</label>
                    <input type="text" name="autor" class="form-control" required />
                </div>
                
                <div class="mb-3">
                <label class="form-label">ISBN:</label>
                <%--isbn es unico en la tabla libros, con indice unico. Si se repite, el
                     INSERT falla y controllerLibro.jsp lo avisa con el mensaje de error. --%>
                <input type="text" name="isbn" class="form-control" required />
                </div>
                
                <div class="mb-3">
                    <label class="form-label">Categoría:</label>
                    <select name="id_categoria" class="form-select" required>
                        <%-- Opcion vacia: required impide enviar el formulario sin elegir,
                             pero no impide enviarla con el valor "". --%>
                        <option value="">-- Seleccione Categoría --</option>
                        <%-- El value lleva el id, que es lo que necesita el INSERT. El texto
                             que ve el usuario es el nombre. --%>
                        <% for(CategoriaBean c : catBean.getListaCategorias()) { %>
                            <option value="<%= c.getId_categoria() %>"><%= c.getNombre_categoria() %></option>
                        <% } %>
                    </select>
                </div>
                
                <div class="mb-3">
                <label class="form-label">Cantidad Disponible:</label>
                <%-- min="1" evita que se registre un libro con stock 0, que luego
                     registrarPrestamo() rechazaria. El value="1" es solo el valor
                     inicial del formulario. --%>
                <input type="number" name="cantidad_disponible" class="form-control" value="1" min="1" required />
                </div>
                
                <button type="submit" class="btn btn-primary">Guardar Libro</button>
            </form>
        </div>
    </div>
</body>
</html>