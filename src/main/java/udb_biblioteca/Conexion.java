/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package udb_biblioteca;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 *
 * @author Uptim
 */
// Conexion JDBC a MySQL. Esta aplicacion no usa JNDI ni un DataSource del contenedor:
// cada bean abre y cierra su propia conexion con try-with-resources.
public class Conexion {
    // Parametros de la URL:
    //   useSSL=false               evita el aviso de conexion sin cifrar en local
    //   allowPublicKeyRetrieval    necesario con MySQL 8 para caching_sha2_password
    //   serverTimezone=UTC         fija la zona y evita el error de zona desconocida
    // El nombre de la base y las credenciales estan aqui, en un solo archivo, para que
    // cambiarlas no obligue a tocar los beans.
    private static final String URL = "jdbc:mysql://localhost:3306/bibliotecaudb?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String USER = "root";
    private static final String PASSWORD = "";

    // A diferencia del Conexion del proyecto BibliotecaPoo, este lanza SQLException en
    // vez de devolver null. Por eso los beans que devuelven texto pueden poner el motivo
    // en el mensaje que ve el usuario, y los que devuelven listas lo silencian.
    public static Connection getConexion() throws SQLException {
        try{
            // El driver se carga solo con JDBC 4, pero forzarlo aqui convierte un driver
            // faltante en un ClassNotFoundException claro en vez de un error difuso.
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager .getConnection(URL, USER, PASSWORD);
        }catch (ClassNotFoundException e){
            throw new SQLException("Driver MySQL no encontrado", e);
        }           
    }
}
