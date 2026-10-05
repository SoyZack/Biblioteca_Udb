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
// Estudiante: alta y listado.
public class EstudianteBean implements Serializable {
    private int id_estudiante;
    private String carnet;
    private String nombre_estudiante;
    private String carrera;
    private String telefono;
    
    public EstudianteBean() {}
    
    public int getId_estudiante() { return id_estudiante; }
    public void setId_estudiante(int id_estudiante) { this.id_estudiante = id_estudiante; }

    public String getCarnet() { return carnet; }
    public void setCarnet(String carnet) { this.carnet = carnet; }

    public String getNombre_estudiante() { return nombre_estudiante; }
    public void setNombre_estudiante(String nombre_estudiante) { this.nombre_estudiante = nombre_estudiante; }

    public String getCarrera() { return carrera; }
    public void setCarrera(String carrera) { this.carrera = carrera; }

    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }
    
    // Texto del ultimo error de SQL, para que el JSP muestre la causa real.
    private String ultimoError;

    public String getUltimoError() { return ultimoError; }

    // Alta de un estudiante. carnet es unico en la base: un carnet repetido hace fallar
    // el INSERT y devuelve false.
    public boolean guardar() {
        ultimoError = null;
        String sql = "INSERT INTO estudiantes (carnet, nombre_estudiante, carrera, telefono) VALUES (?, ?, ?, ?)";
        try (Connection conn = Conexion.getConexion();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, this.carnet);
            ps.setString(2, this.nombre_estudiante);
            ps.setString(3, this.carrera);
            ps.setString(4, this.telefono);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            ultimoError = e.getMessage();
            e.printStackTrace();
            return false;
        }
    }

    public List<EstudianteBean> getListaEstudiantes() {
        List<EstudianteBean> lista = new ArrayList<>();
        String sql = "SELECT * FROM estudiantes";
        try (Connection conn = Conexion.getConexion();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                EstudianteBean est = new EstudianteBean();
                est.setId_estudiante(rs.getInt("id_estudiante"));
                est.setCarnet(rs.getString("carnet"));
                est.setNombre_estudiante(rs.getString("nombre_estudiante"));
                est.setCarrera(rs.getString("carrera"));
                est.setTelefono(rs.getString("telefono"));
                lista.add(est);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }
}
