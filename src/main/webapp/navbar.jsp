<%-- 
    Document   : navbar
    Created on : 4 oct 2026, 19:11:11
    Author     : Uptim
--%>


<%--
    Menu superior. Se incluye en todas las paginas con <%@ include file="navbar.jsp" %>.

    Este archivo debe guardarse en UTF-8, que es la codificacion que declaran las paginas
    con pageEncoding="UTF-8" o charset="UTF-8". Si un editor lo guarda en Windows-1252, los
    acentos se ven como Pr?stamos. Ojo: registroEstudiante.jsp, registroPrestamo.jsp,
    controllerLibro.jsp, controllerEstudiante.jsp, controllerPrestamo.jsp,
    devolverPrestamo.jsp y listaPrestamo.jsp tienen acentos en el texto, asi que tambien
    necesitan guardarse en UTF-8.

    Ojo con los nombres de los href: deben coincidir exactamente con el archivo destino.
    Si no coinciden sale un 404, no un error de compilacion, asi que un enlace mal escrito
    no se nota hasta que se navega. Los archivos de listado van en singular:
    listaPrestamo.jsp, no listaPrestamos.jsp.
--%>

<!-- Carga de Bootstrap CSS y JavaScript -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4">
  <div class="container">
    <a class="navbar-brand fw-bold" href="index.jsp">Biblioteca UDB</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav me-auto">
        <li class="nav-item">
          <a class="nav-link" href="registroLibro.jsp">Registrar Libro</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="registroEstudiante.jsp">Registrar Estudiante</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="registroPrestamo.jsp">Nuevo Prestamo</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="listaPrestamo.jsp">Ver Prestamos</a>
        </li>
      </ul>
    </div>
  </div>
</nav>