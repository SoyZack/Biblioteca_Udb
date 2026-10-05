<%-- 
    Document   : index
    Created on : 4 oct 2026, 19:03:03
    Author     : Uptim
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    Portada. No toca la base de datos, solo muestra el menu.

    Este archivo debe guardarse en UTF-8, que es lo que declara el pageEncoding de
    arriba. Si un editor lo guarda en Windows-1252, los acentos se ven como Pr?stamos.

    El include de navbar.jsp trae el menu superior que se repite en todas las paginas.
    El include es estatico: el contenido de navbar.jsp se copia dentro de esta pagina al
    compilarse, no se llama en tiempo de ejecucion.
--%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Biblioteca Central UDB</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"> 
    </head>
    <body>
        <%@ include file= "navbar.jsp"%>
        <div class="container text-center mt-5">
            <h1 class="display-4">Sistema de Gestion de Biblioteca UDB</h1>
            <p class="lead">Seleccione una opcion del menu para gestionar libros, estudiamos o prestamos.</p>
        </div>
    </body>
</html>
