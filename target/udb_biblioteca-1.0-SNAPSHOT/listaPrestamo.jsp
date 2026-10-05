<%-- 
    Document   : listaPrestamo
    Created on : 4 oct 2026, 19:25:37
    Author     : Uptim
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    Listado de prestamos con el boton de devolucion.

    El nombre de este archivo va en singular. El menu lo enlaza asi y el boton de
    controllerPrestamo.jsp tambien: si alguien lo renombra a listaPrestamos.jsp hay que
    actualizar los dos href, o el enlace daria 404.
--%>
<jsp:useBean id="pDao" class="udb_biblioteca.PrestamoBean" scope="page" />
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Listado de Préstamos</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body>
        <%@ include file="navbar.jsp" %>
    <div class="container mt-4">
        <%-- El tipo va completo porque esta pagina no importa udb_biblioteca.PrestamoBean.
             getListaPrestamos() hace dos INNER JOIN, asi que un prestamo cuyo estudiante
             o libro no exista no sale en la tabla. --%>
        <% java.util.List<udb_biblioteca.PrestamoBean> prestamos = pDao.getListaPrestamos(); %>
        <h2 class="mb-4">Préstamos Registrados</h2>
        <%-- El aviso de error llega como parametro GET desde devolverPrestamo.jsp, que
             hace un redirect con ?error=... cuando la devolucion falla. --%>
        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-danger"><%= request.getParameter("error") %></div>
        <% } %>
        <% if (prestamos.isEmpty()) { %>
            <div class="alert alert-warning">No hay préstamos registrados.</div>
        <% } %>
        <table class="table table-striped table-bordered">
            <thead class="table-dark">
                <tr>
                    <th>#</th>
                    <th>Estudiante</th>
                    <th>Libro</th>
                    <th>Fecha Préstamo</th>
                    <th>Fecha Devolución</th>
                    <th>Estado Real / Calculado</th>
                    <th>Acción</th>
                </tr>
            </thead>
            <tbody>
                <% for (udb_biblioteca.PrestamoBean p : prestamos) { %>
                <tr>
                    <td><%= p.getId_prestamo() %></td>
                    <td><%= p.getEstudiante().getCarnet() %> - <%= p.getEstudiante().getNombre_estudiante() %></td>
                    <td><%= p.getLibro().getTitulo() %></td>
                    <td><%= p.getFecha_prestamo() %></td>
                    <td><%= p.getFecha_devolucion() %></td>
                    <td>
                        <%-- El color sale de dos metodos distintos:
                             getEstado()      es lo guardado en la base (Activo / Devuelto)
                             getEstadoCalculado() es Vigente / Vencido / Devuelto, y compara
                                                  la fecha limite con la fecha de hoy
                             Por eso un prestamo vencido se pinta en rojo aunque en la base
                             siga como Activo. Los equals van del literal constante para que
                             un null no rompa el if. --%>
                        <span class="badge <%= "Devuelto".equals(p.getEstado()) ? "bg-secondary" : ("Vencido".equals(p.getEstadoCalculado()) ? "bg-danger" : "bg-success") %>">
                            <%= p.getEstadoCalculado() %>
                        </span>
                    </td>
                    <td>
                        <%-- El boton solo aparece si el estado guardado no es Devuelto.
                             Esto evita el error de llamar dos veces a devolverPrestamo(),
                             que sumaria dos unidades al stock. Aun asi la comprobacion
                             esta en la pagina y no en el bean: si se llama al bean por
                             otra via, el stock se duplicaria. --%>
                        <% if (!"Devuelto".equalsIgnoreCase(p.getEstado())) { %>
                            <%-- form dentro de la celda para no perder la tabla. Los dos
                                 hidden viajan por POST a devolverPrestamo.jsp:
                                   id_prestamo  cambia el estado a Devuelto
                                   id_libro     es por donde se suma el ejemplar al stock
                                 Si id_libro faltara, el prestamo se devolveria pero el
                                 stock no se corregiria. --%>
                            <form action="devolverPrestamo.jsp" method="POST" style="display:inline;">
                                <input type="hidden" name="id_prestamo" value="<%= p.getId_prestamo() %>" />
                                <input type="hidden" name="id_libro" value="<%= p.getId_libro() %>" />
                                <button type="submit" class="btn btn-sm btn-outline-success">Devolver</button>
                            </form>
                        <% } else { %>
                            <span class="text-muted">Procesado</span>
                        <% } %>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
    </body>
</html>
