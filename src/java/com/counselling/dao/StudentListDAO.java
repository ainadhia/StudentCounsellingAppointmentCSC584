package com.counselling.dao;

import com.counselling.model.ListStudent;
import com.counselling.model.Student;
import com.counselling.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StudentListDAO {

    // 1. Method untuk senarai semua pelajar (DIPANGGIL OLEH StudentServlet)
    public List<ListStudent> getAllStudents() {
        List<ListStudent> studentList = new ArrayList<>();
        // Query menggunakan schema APP seperti dalam database anda
        String sql = "SELECT s.STUDENTID, u.FULLNAME FROM APP.STUDENT s " +
                     "JOIN APP.USERS u ON s.ID = u.ID";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String id = rs.getString("STUDENTID");
                String name = rs.getString("FULLNAME");
                studentList.add(new ListStudent(id, name));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return studentList;
    }

    // 2. Method untuk profil pelajar (DIPANGGIL OLEH ViewStudentServlet)
    public Student getStudentById(String studentID) {
        Student s = null;
        String sql = "SELECT s.ID, s.STUDENTID, u.FULLNAME, u.USEREMAIL, u.USERPHONENUM, s.FACULTY, s.PROGRAM " +
                     "FROM APP.STUDENT s JOIN APP.USERS u ON s.ID = u.ID " +
                     "WHERE s.STUDENTID = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, studentID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    s = new Student();
                    s.setId(rs.getInt("ID"));
                    s.setStudentID(rs.getString("STUDENTID"));
                    s.setFullName(rs.getString("FULLNAME"));
                    s.setUserEmail(rs.getString("USEREMAIL"));
                    s.setUserPhoneNum(rs.getString("USERPHONENUM"));
                    s.setFaculty(rs.getString("FACULTY"));
                    s.setProgram(rs.getString("PROGRAM"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return s;
    }
}