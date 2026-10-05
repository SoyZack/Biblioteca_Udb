package udb_biblioteca;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */


import java.io.Serializable;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Uptim
 */
// Categoria: solo lectura, esta clase no tiene metodo de alta.
public class CategoriaBean implements Serializable {
  private int id_categoria;
    private String nombre_categoria;

    public CategoriaBean() {}

    public int getId_categoria() { return id_categoria; }
    public void setId_categoria(int id_categoria) { this.id_categoria = id_categoria; }

    public String getNombre_categoria() { return nombre_categoria; }
    public void setNombre_categoria(String nombre_categoria) { this.nombre_categoria = nombre_categoria; }

    // Todas las categorias. Se usa para llenar el desplegable de registroLibro.jsp.
    // Si la consulta falla devuelve lista vacia y el error queda en la consola del
    // servidor: el JSP no puede distinguir "no hay categorias" de "fallo la consulta".
    public List<CategoriaBean> getListaCategorias() {
        List<CategoriaBean> lista = new ArrayList<>();
        String sql = "SELECT * FROM categorias";
        try (Connection conn = Conexion.getConexion();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                CategoriaBean cat = new CategoriaBean();
                cat.setId_categoria(rs.getInt("id_categoria"));
                cat.setNombre_categoria(rs.getString("nombre_categoria"));
                lista.add(cat);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

}
