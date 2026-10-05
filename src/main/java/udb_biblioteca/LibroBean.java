/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package udb_biblioteca;

import udb_biblioteca.Conexion;
import java.io.Serializable;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;


/**
 *
 * @author Uptim
 */
// Libro: alta y listado.
// Serializable porque un bean de JSP debe poder serializarse entre peticiones.
public class LibroBean implements Serializable {
    private int id_libro;
    private String titulo;
    private String autor;      // texto plano: en esta base no hay tabla de autores
    private String isbn;
    private int id_categoria;
    private int cantidad_disponible;
    private CategoriaBean categoria;

    // Se inicializa aqui y no a null para que getCategoria() nunca devuelva null.
    // Sirve para leer el nombre de la categoria cuando el bean se lleno con un JOIN.
    public LibroBean(){
        this.categoria = new CategoriaBean();
    }
    
    public int getId_Libro() { return id_libro; }
    public void setId_Libro( int id_libro ) { this.id_libro = id_libro; }
    
    public String getTitulo() { return titulo; }
    public void setTitulo(  String titulo ) { this.titulo = titulo; } 
    
    public String getAutor() { return autor; }
    public void setAutor( String autor) { this.autor = autor; }
    
    public String getIsbn() { return isbn; }
    public void setIsbn( String isbn ) { this.isbn = isbn;}
    
    public int getId_categoria() { return id_categoria; }
    public void setId_categoria( int id_categoria )  { this.id_categoria = id_categoria; }
    
    public int getCantidad_disponible() { return cantidad_disponible;}
    public void setCantidad_disponible( int cantidad_disponible ) { this.cantidad_disponible = cantidad_disponible; }
    
    public CategoriaBean getCategoria() { return categoria; }
    public void setCategoria( CategoriaBean categoria ) { this.categoria = categoria; }

    // Texto del ultimo error de SQL, para que el JSP muestre la causa real y no un
    // "error al guardar" generico. Se rellena solo en el catch.
    private String ultimoError;

    public String getUltimoError() { return ultimoError; }

    // Alta de un libro. isbn es unico en la base, asi que un isbn repetido lanza una
    // violacion de clave duplicada y este metodo devuelve false.
    public boolean guardar() {
        ultimoError = null;
        String sql = "INSERT INTO libros (titulo, autor, isbn, id_categoria, cantidad_disponible) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = Conexion.getConexion();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, this.titulo);
            ps.setString(2, this.autor);
            ps.setString(3, this.isbn);
            ps.setInt(4, this.id_categoria);
            ps.setInt(5, this.cantidad_disponible);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            ultimoError = e.getMessage();
            e.printStackTrace();
            return false;
        }
    }

    // Listado de libros con su categoria.
    // INNER JOIN, no LEFT JOIN: un libro con id_categoria inexistente no aparece en la
    // lista. Como la tabla es MyISAM, la clave foranea no se valida al insertar, asi que
    // un libro puede estar guardado y aun asi no salir nunca aqui.
    public List<LibroBean> getListaLibros() {
        List<LibroBean> lista = new ArrayList<>();
        ultimoError = null;
        String sql = "SELECT l.*, c.nombre_categoria FROM libros l INNER JOIN categorias c ON l.id_categoria = c.id_categoria";
        try (Connection conn = Conexion.getConexion();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                LibroBean libro = new LibroBean();
                libro.setId_Libro(rs.getInt("id_libro"));
                libro.setTitulo(rs.getString("titulo"));
                libro.setAutor(rs.getString("autor"));
                libro.setIsbn(rs.getString("isbn"));
                libro.setCantidad_disponible(rs.getInt("cantidad_disponible"));
                libro.setId_categoria(rs.getInt("id_categoria"));
                // El nombre de la categoria viene del JOIN, no de la tabla libros.
                libro.getCategoria().setNombre_categoria(rs.getString("nombre_categoria"));
                lista.add(libro);
            }
        } catch (SQLException e) {
            ultimoError = e.getMessage();
            e.printStackTrace();
        }
        return lista;
    }
} 
