<%-- 
    Document   : controllerEstudiante
    Created on : 4 oct 2026, 19:24:29
    Author     : Uptim
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    Procesa el alta de estudiante. Lee el POST de registroEstudiante.jsp y guarda.

    El paquete es udb_biblioteca con guion bajo.

    No abre conexion: EstudianteBean.guardar() abre y cierra la suya.
--%>

<%-- scope="request" porque el bean solo se necesita durante esta peticion. --%>
<jsp:useBean id="estudiante" class="udb_biblioteca.EstudianteBean" scope="request" />

<%-- property="*" mapea carnet, nombre_estudiante, carrera y telefono a sus setters.
     telefono no es NOT NULL en la base, asi que puede llegar vacio sin problema. --%>
<jsp:setProperty name="estudiante" property="*" />
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Procesando Estudiante</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body>
        <%@ include file="navbar.jsp" %>
    <div class="container mt-4">
        <%-- El mensaje menciona el carnet duplicado porque es la causa mas frecuente:
             la columna carnet tiene indice unico. getUltimoError() muestra el detalle
             real de MySQL. --%>
        <% if (estudiante.guardar()) { %>
            <div class="alert alert-success">
                <h4>¡Estudiante registrado exitosamente!</h4>
                <ul>
                    <li><strong>Carnet:</strong> <jsp:getProperty name="estudiante" property="carnet" /></li>
                    <li><strong>Nombre:</strong> <jsp:getProperty name="estudiante" property="nombre_estudiante" /></li>
                    <li><strong>Carrera:</strong> <jsp:getProperty name="estudiante" property="carrera" /></li>
                </ul>
            </div>
        <% } else { %>
            <div class="alert alert-danger">
                Error al registrar el estudiante. Verifique que el carnet no esté duplicado.
                <% if (estudiante.getUltimoError() != null) { %>
                    <br><small><%= estudiante.getUltimoError() %></small>
                <% } %>
            </div>
        <% } %>
        <a href="registroEstudiante.jsp" class="btn btn-secondary">Regresar</a>
    </div>
    </body>
</html>
