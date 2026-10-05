<%-- 
    Document   : controllerPrestamo
    Created on : 4 oct 2026, 19:25:23
    Author     : Uptim
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    Procesa el alta de prestamo. Lee el POST de registroPrestamo.jsp y lo registra.

    El paquete es udb_biblioteca con guion bajo.

    No abre conexion: PrestamoBean.registrarPrestamo() abre y cierra la suya.
--%>

<%-- scope="request" porque el bean solo se usa en esta peticion. --%>
<jsp:useBean id="prestamo" class="udb_biblioteca.PrestamoBean" scope="request" />

<%-- property="*" mapea id_estudiante, id_libro, fecha_prestamo y fecha_devolucion.
     El estado NO viene del formulario: lo pone el propio SQL de registrarPrestamo()
     con el valor fijo 'Activo'. Por eso no hay un campo de estado en el formulario. --%>
<jsp:setProperty name="prestamo" property="*" />
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Procesando Préstamo</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body>
        <%@ include file="navbar.jsp" %>
    <div class="container mt-4">
        <%-- registrarPrestamo() devuelve "OK" o el texto del error. Se compara con
             "OK".equals(res) y no con res.equals("OK") para no romper si res llega null.
             El boton de abajo apunta a listaPrestamo.jsp en singular: el archivo se llama
             asi, y con una s de mas el enlace daria 404. --%>
        <% 
            String res = prestamo.registrarPrestamo();
            if ("OK".equals(res)) { 
        %>
            <div class="alert alert-success">
                <h4>¡Préstamo registrado exitosamente!</h4>
                <p>El libro ha sido asignado y el stock actualizado.</p>
            </div>
        <% } else { %>
            <div class="alert alert-danger"><%= res %></div>
        <% } %>
        <a href="listaPrestamo.jsp" class="btn btn-primary">Ver Todos los Préstamos</a>
    </div>
    </body>
</html>
