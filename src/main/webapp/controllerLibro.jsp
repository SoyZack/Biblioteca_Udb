<%-- 
    Document   : controllerLibro
    Created on : 4 oct 2026, 19:23:16
    Author     : Uptim
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    Procesa el alta de libro. No tiene formulario propio: lee lo que mando
    registroLibro.jsp y guarda en la base.

    El paquete es udb_biblioteca con guion bajo, igual que la carpeta del proyecto.

    No hay que abrir conexion aqui: LibroBean.guardar() abre y cierra la suya. Por eso
    este archivo no incluye conexion.jsp, y no debe volver a hacerlo.
--%>

<%-- scope="request" porque el bean vive solo durante esta peticion. --%>
<jsp:useBean id="libro" class="udb_biblioteca.LibroBean" scope="request" />

<%-- property="*" copia al bean todo parametro del POST que tenga un setter con ese
     nombre: titulo, autor, isbn, id_categoria y cantidad_disponible. Los tipos los
     convierte sola. Un parametro sin setter se ignora en silencio. --%>
<jsp:setProperty name="libro" property="*" />
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title> Procesando Libro </title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body>
       <%@ include file="navbar.jsp" %>
    <div class="container mt-4">
        <%-- guardar() devuelve false si hubo error. Como devuelve false tambien cuando
             el isbn ya existe, el mensaje de abajo se apoya en getUltimoError() para
             decir cual fue la causa. --%>
        <% if (libro.guardar()) { %>
            <div class="alert alert-success">
                <h4>¡Libro registrado exitosamente!</h4>
                <ul>
                    <li><strong>Título:</strong> <jsp:getProperty name="libro" property="titulo" /></li>
                    <li><strong>Autor:</strong> <jsp:getProperty name="libro" property="autor" /></li>
                    <li><strong>ISBN:</strong> <jsp:getProperty name="libro" property="isbn" /></li>
                    <li><strong>Stock:</strong> <jsp:getProperty name="libro" property="cantidad_disponible" /></li>
                </ul>
            </div>
        <% } else { %>
            <div class="alert alert-danger">
                Error al registrar el libro en la base de datos.
                <% if (libro.getUltimoError() != null) { %>
                    <br><small><%= libro.getUltimoError() %></small>
                <% } %>
            </div>
        <% } %>
        <a href="registroLibro.jsp" class="btn btn-secondary">Regresar</a>
    </div>
    </body>
</html>
