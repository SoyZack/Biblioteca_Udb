<%-- 
    Document   : registroEstudiante
    Created on : 4 oct 2026, 19:23:53
    Author     : Uptim
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    Formulario de alta de estudiante. No guarda nada: envia por POST a
    controllerEstudiante.jsp, que es quien procesa los datos.

    No necesita useBean porque no consulta nada de la base. Los datos van en campos
    hidden y cada name coincide con una propiedad de EstudianteBean.
--%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Registro de Estudiante</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body>
       <%@ include file="navbar.jsp" %>
    <div class="container col-md-6">
        <h2 class="mb-4">Registrar Nuevo Estudiante</h2>
        <%-- required en el navegador evita el POST vacio. required="required" tambien
             funciona; required a secas es HTML5. --%>
        <form action="controllerEstudiante.jsp" method="POST">
            <div class="mb-3">
                <label class="form-label">Carnet:</label>
                <%-- El name "carnet" tiene que coincidir exactamente con el setter
                     setCarnet() de EstudianteBean. Si no coincide, <jsp:setProperty
                     property="*"> lo ignora en silencio y el INSERT falla por NOT NULL. --%>
                <input type="text" name="carnet" class="form-control" required />
            </div>
            <div class="mb-3">
                <label class="form-label">Nombre Completo:</label>
                <input type="text" name="nombre_estudiante" class="form-control" required />
            </div>
            <div class="mb-3">
                <label class="form-label">Carrera:</label>
                <input type="text" name="carrera" class="form-control" required />
            </div>
            <div class="mb-3">
                <label class="form-label">Teléfono:</label>
                <%-- Sin required a proposito: telefono es la unica columna de la tabla
             estudiantes que admite NULL. --%>
                <input type="text" name="telefono" class="form-control" />
            </div>
            <button type="submit" class="btn btn-success">Guardar Estudiante</button>
        </form>
    </div>
    </body>
</html>
