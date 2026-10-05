<%-- 
    Document   : devolverPrestamo
    Created on : 4 oct 2026, 19:25:58
    Author     : Uptim
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    Procesa la devolucion. No muestra HTML: al final siempre hace un redirect al listado.

    Recibe id_prestamo e id_libro por POST desde el boton Devolver de listaPrestamo.jsp.
    El paquete es udb_biblioteca con guion bajo.
--%>
<jsp:useBean id="pBean" class="udb_biblioteca.PrestamoBean" scope="page" />
<%
    // Los parametros llegan como texto, no como numero, por eso hay que convertirlos.
    String paramP = request.getParameter("id_prestamo");
    String paramL = request.getParameter("id_libro");

    // Si falta alguno no se invoca al bean: un id en 0 o null haria que el UPDATE
    // afectara filas equivocadas. Se comprueba antes de convertir.
    if (paramP == null || paramL == null) {
        response.sendRedirect("listaPrestamo.jsp?error=Faltan+datos+del+prestamo");
        return;
    }
    // trim() quita espacios; sin el, Integer.parseInt fallaria con un valor como " 5 ".
    // El catch es separado del if anterior porque aqui el problema es otro: el parametro
    // existe pero no es un numero.
    int idP, idL;
    try {
        idP = Integer.parseInt(paramP.trim());
        idL = Integer.parseInt(paramL.trim());
    } catch (NumberFormatException e) {
        response.sendRedirect("listaPrestamo.jsp?error=Parametros+no+numericos");
        return;
    }
    // El bean suma una unidad al stock del id_libro recibido y pone el prestamo en
    // estado Devuelto.
    boolean ok = pBean.devolverPrestamo(idP, idL);

    // Redirect y no solo print: el redirect cambia el POST por un GET, asi que pulsar
    // F5 no vuelve a ejecutar la devolucion y sumar stock otra vez. El error viaja como
    // parametro GET y listaPrestamo.jsp lo pinta al principio de la tabla.
    // Los "+" en vez de espacios evitan que el navegador los codifique.
    response.sendRedirect("listaPrestamo.jsp" + (ok ? "" : "?error=No+se+pudo+registrar+la+devolucion"));
%>