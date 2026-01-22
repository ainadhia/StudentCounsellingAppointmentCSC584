/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.counselling.dao;

import com.counselling.model.Student;
import com.counselling.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 *
 * @author Aina
 */
public class StudentDAO {
    
    public List<Student> getStudentsByCounselor(String counselorID) throws SQLException {
        List<Student> students = new ArrayList<>();
        String sql = "SELECT s.*, u.userName, u.fullName, u.userEmail, u.userPhoneNum " +
                    "FROM Student s " +
                    "JOIN User u ON s.userID = u.userID " +
                    "WHERE s.assignedCounselorID = ? " +
                    "ORDER BY u.fullName";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, counselorID);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                students.add(extractStudentFromResultSet(rs));
            }
        }
        return students;
    }
    
    public Student getStudentById(String studentID, String counselorID) throws SQLException {
        String sql = "SELECT s.*, u.userName, u.fullName, u.userEmail, u.userPhoneNum " +
                    "FROM Student s " +
                    "JOIN User u ON s.userID = u.userID " +
                    "WHERE s.studentID = ? AND s.assignedCounselorID = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, studentID);
            ps.setString(2, counselorID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return extractStudentFromResultSet(rs);
            }
        }
        return null;
    }
    
    public Student getStudentById(String studentId) throws SQLException {
        Student student = null;
        String query = "SELECT s.*, u.fullName, u.userEmail, u.userPhoneNum FROM student s " +
                       "JOIN user u ON s.userID = u.userID " +
                       "WHERE s.studentID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, studentId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                student = new Student();
                student.setStudentID(rs.getString("studentID"));
                student.setID(rs.getInt("userID"));
                student.setFullName(rs.getString("fullName"));
                student.setUserEmail(rs.getString("userEmail"));
                student.setUserPhoneNum(rs.getString("userPhoneNum"));
                return student;
            }
        }
        return student;
    }
    
    public List<Student> searchStudents(String counselorID, String keyword) throws SQLException {
        List<Student> students = new ArrayList<>();
        String sql = "SELECT s.*, u.userName, u.fullName, u.userEmail, u.userPhoneNum " +
                    "FROM Student s " +
                    "JOIN User u ON s.userID = u.userID " +
                    "WHERE s.assignedCounselorID = ? " +
                    "AND (u.fullName LIKE ? OR s.studentID LIKE ? OR s.program LIKE ?) " +
                    "ORDER BY u.fullName";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, counselorID);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                students.add(extractStudentFromResultSet(rs));
            }
        }
        return students;
    }
    
    public List<Student> getStudentsByFaculty(String counselorID, String faculty) throws SQLException {
        List<Student> students = new ArrayList<>();
        String sql = "SELECT s.*, u.userName, u.fullName, u.userEmail, u.userPhoneNum " +
                    "FROM Student s " +
                    "JOIN User u ON s.userID = u.userID " +
                    "WHERE s.assignedCounselorID = ? AND s.faculty = ? " +
                    "ORDER BY u.fullName";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, counselorID);
            ps.setString(2, faculty);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                students.add(extractStudentFromResultSet(rs));
            }
        }
        return students;
    }
    
    public List<Student> getStudentsByProgram(String counselorID, String program) throws SQLException {
        List<Student> students = new ArrayList<>();
        String sql = "SELECT s.*, u.userName, u.fullName, u.userEmail, u.userPhoneNum " +
                    "FROM Student s " +
                    "JOIN User u ON s.userID = u.userID " +
                    "WHERE s.assignedCounselorID = ? AND s.program = ? " +
                    "ORDER BY u.fullName";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, counselorID);
            ps.setString(2, program);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                students.add(extractStudentFromResultSet(rs));
            }
        }
        return students;
    }
    
    public int getStudentCount(String counselorID) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Student WHERE assignedCounselorID = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, counselorID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
    
    public boolean assignStudentToCounselor(String studentID, String counselorID) throws SQLException {
        String sql = "UPDATE Student SET assignedCounselorID = ? WHERE studentID = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, counselorID);
            ps.setString(2, studentID);
            
            int rows = ps.executeUpdate();
            return rows > 0;
        }
    }
    
    public int getStudentAppointmentCount(String studentID) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Appointment WHERE studentID = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, studentID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
    
    
    public Date getStudentLastAppointmentDate(String studentID) throws SQLException {
        String sql = "SELECT MAX(bookedDate) FROM Appointment WHERE studentID = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, studentID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getDate(1);
            }
        }
        return null;
    }
    
    private Student extractStudentFromResultSet(ResultSet rs) throws SQLException {
        Student student = new Student();
        
        student.setStudentID(rs.getString("userID"));
        student.setUserName(rs.getString("userName"));
        student.setFullName(rs.getString("fullName"));
        student.setUserEmail(rs.getString("userEmail"));
        student.setUserPhoneNum(rs.getString("userPhoneNum"));
        student.setUserRole("student");
        
        student.setStudentID(rs.getString("studentID"));
        student.setFaculty(rs.getString("faculty"));
        student.setProgram(rs.getString("program"));
        
        return student;
    }
    
    public List<String> getDistinctFaculties(String counselorID) throws SQLException {
        List<String> faculties = new ArrayList<>();
        String sql = "SELECT DISTINCT faculty FROM Student " +
                    "WHERE assignedCounselorID = ? AND faculty IS NOT NULL " +
                    "ORDER BY faculty";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, counselorID);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                faculties.add(rs.getString("faculty"));
            }
        }
        return faculties;
    }
    
    public List<String> getDistinctPrograms(String counselorID) throws SQLException {
        List<String> programs = new ArrayList<>();
        String sql = "SELECT DISTINCT program FROM Student " +
                    "WHERE assignedCounselorID = ? AND program IS NOT NULL " +
                    "ORDER BY program";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, counselorID);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                programs.add(rs.getString("program"));
            }
        }
        return programs;
    }
    
    public int getTotalStudents() throws SQLException {
        String sql = "SELECT COUNT(*) FROM STUDENT";
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
}
