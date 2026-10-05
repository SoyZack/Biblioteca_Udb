<%-- 
    Document   : regitroPrestamo
    Created on : 4 oct 2026, 19:24:56
    Author     : Uptim
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    Formulario de prestamo. No guarda nada: llena los dos desplegables y envia por POST a
    controllerPrestamo.jsp.

    Son dos useBean porque hacen falta dos listados distintos, uno de estudiantes y otro
    de libros. Los dos con scope="page", ya que solo se usan mientras se dibuja la pagina.

    Ojo: los tipos de los bucles de abajo deben escribirse con el nombre completo
    udb_biblioteca.LibroBean. El nombre corto solo funciona si hay un import.
--%>
<jsp:useBean id="estBean" class="udb_biblioteca.EstudianteBean" scope="page" />
<jsp:useBean id="libBean" class="udb_biblioteca.LibroBean" scope="page" />
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Registro de Préstamo</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body>
       <%@ include file="navbar.jsp" %>
    <div class="container col-md-6">
        <h2 class="mb-4">Registrar Préstamo de Libro</h2>
        <%-- Los nombres del form son id_estudiante, id_libro, fecha_prestamo y
             fecha_devolucion, y tienen que coincidir con las propiedades de
             PrestamoBean. No hay campo de estado: lo pone el SQL con 'Activo'. --%>
        <form action="controllerPrestamo.jsp" method="POST">
            <div class="mb-3">
                <label class="form-label">Estudiante:</label>
                <select name="id_estudiante" class="form-select" required>
                    <option value="">-- Seleccionar Estudiante --</option>
                    <%-- El value es el id del estudiante, no el carnet: el prestamo guarda
                         una clave numerica que apunta a la tabla estudiantes. El carnet
                         solo se muestra como texto. --%>
                    <% for(udb_biblioteca.EstudianteBean e : estBean.getListaEstudiantes()) { %>
                        <option value="<%= e.getId_estudiante() %>"><%= e.getCarnet() %> - <%= e.getNombre_estudiante() %></option>
                    <% } %>
                </select>
            </div>
            <div class="mb-3">
                <label class="form-label">Libro:</label>
                <select name="id_libro" class="form-select" required>
                    <option value="">-- Seleccionar Libro --</option>
                    <%-- getListaLibros() hace INNER JOIN con categorias, asi que un libro
                         con categoria inexistente no sale en este desplegable aunque este
                         guardado. El metodo del getter es getId_Libro con L mayuscula:
                         getId_libro en minuscula no existe y daria error 500. --%>
                    <% for(udb_biblioteca.LibroBean l : libBean.getListaLibros()) { %>
                        <option value="<%= l.getId_Libro() %>">
                            <%= l.getTitulo() %> (Disponibles: <%= l.getCantidad_disponible() %>)
                        </option>
                    <% } %>
                </select>
            </div>
            <div class="mb-3">
                <label class="form-label">Fecha de Préstamo:</label>
                <%-- input type="date" entrega el valor en formato aaaa-mm-dd, que es el
                     que MySQL acepta en un campo DATE. Por eso PrestamoBean guarda las
                     fechas como texto y no necesita convertirlas. --%>
                <input type="date" name="fecha_prestamo" class="form-control" required />
            </div>
            <div class="mb-3">
                <label class="form-label">Fecha de Devolución:</label>
                <%-- Esta fecha no es la de devolucion real: es la fecha limite. El estado
                     Devuelto solo se escribe cuando alguien pulsa el boton Devolver.
                     El valor calculado Vencido sale de comparar esta fecha con hoy. --%>
                <input type="date" name="fecha_devolucion" class="form-control" required />
            </div>
            <button type="submit" class="btn btn-warning">Registrar Préstamo</button>
        </form>
    </div>
    </body>
</html>
