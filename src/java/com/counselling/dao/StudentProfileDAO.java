package com.counselling.dao;

import com.counselling.model.Student;
import com.counselling.util.DBConnection;
import java.sql.*;

public class StudentProfileDAO {

    // Constants for column names to avoid typos
    private static final String ID = "ID";
    private static final String USERNAME = "USERNAME";
    private static final String FULLNAME = "FULLNAME";
    private static final String USEREMAIL = "USEREMAIL";
    private static final String USERPASSWORD = "USERPASSWORD";
    private static final String USERROLE = "USERROLE";
    private static final String USERPHONENUM = "USERPHONENUM";
    private static final String STUDENTID = "STUDENTID";
    private static final String FACULTY = "FACULTY";
    private static final String PROGRAM = "PROGRAM";

    /**
     * Retrieves a student by student ID with better error handling
     */
    public Student getStudentByStudentId(String studentId) throws SQLException {
        if (studentId == null || studentId.trim().isEmpty()) {
            throw new IllegalArgumentException("Student ID cannot be null or empty");
        }

        String sql =
            "SELECT u.ID, u.USERNAME, u.FULLNAME, u.USEREMAIL, u.USERPASSWORD, " +
            "       u.USERROLE, u.USERPHONENUM, s.STUDENTID, s.FACULTY, s.PROGRAM " +
            "FROM USERS u " +
            "JOIN STUDENT s ON u.ID = s.ID " +
            "WHERE s.STUDENTID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, studentId.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToStudent(rs);
                }
            }
        }
        return null;
    }

    /**
     * Alternative method to get student by user ID (if needed)
     */
    public Student getStudentById(String userId) throws SQLException {
        String sql =
            "SELECT u.ID, u.USERNAME, u.FULLNAME, u.USEREMAIL, u.USERPASSWORD, " +
            "       u.USERROLE, u.USERPHONENUM, s.STUDENTID, s.FACULTY, s.PROGRAM " +
            "FROM USERS u " +
            "JOIN STUDENT s ON u.ID = s.ID " +
            "WHERE u.ID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToStudent(rs);
                }
            }
        }
        return null;
    }

    /**
     * Updates student profile with validation
     */
    public boolean updateStudentProfile(String studentId,
                                        String fullName,
                                        String userPhoneNum,
                                        String userEmail,
                                        String faculty,
                                        String program) throws SQLException {
        
        // Input validation
        if (studentId == null || studentId.trim().isEmpty()) {
            throw new IllegalArgumentException("Student ID cannot be null or empty");
        }
        
        if (fullName == null || fullName.trim().isEmpty()) {
            throw new IllegalArgumentException("Full name cannot be null or empty");
        }
        
        if (userEmail == null || userEmail.trim().isEmpty()) {
            throw new IllegalArgumentException("Email cannot be null or empty");
        }

        // Email validation (basic)
        if (!isValidEmail(userEmail)) {
            throw new IllegalArgumentException("Invalid email format");
        }

        String sqlUsers =
            "UPDATE USERS u " +
            "SET u.FULLNAME = ?, u.USERPHONENUM = ?, u.USEREMAIL = ? " +
            "WHERE u.ID = (SELECT s.ID FROM STUDENT s WHERE s.STUDENTID = ?)";

        String sqlStudent =
            "UPDATE STUDENT " +
            "SET FACULTY = ?, PROGRAM = ? " +
            "WHERE STUDENTID = ?";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            boolean usersUpdated = false;
            boolean studentUpdated = false;

            // Update USERS table
            try (PreparedStatement ps = conn.prepareStatement(sqlUsers)) {
                ps.setString(1, safe(fullName));
                ps.setString(2, safe(userPhoneNum));
                ps.setString(3, safe(userEmail));
                ps.setString(4, studentId.trim());
                usersUpdated = ps.executeUpdate() > 0;
            }

            // Update STUDENT table
            try (PreparedStatement ps = conn.prepareStatement(sqlStudent)) {
                ps.setString(1, safe(faculty));
                ps.setString(2, safe(program));
                ps.setString(3, studentId.trim());
                studentUpdated = ps.executeUpdate() > 0;
            }

            if (usersUpdated && studentUpdated) {
                conn.commit();
                return true;
            } else {
                conn.rollback();
                return false;
            }
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    // Log rollback error
                    ex.printStackTrace();
                }
            }
            throw e; // Re-throw for higher level handling
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true); // Reset auto-commit
                    conn.close();
                } catch (SQLException e) {
                    // Log closing error
                    e.printStackTrace();
                }
            }
        }
    }

    /**
     * Helper method to map ResultSet to Student object
     */
    private Student mapResultSetToStudent(ResultSet rs) throws SQLException {
        Student student = new Student();
        
        // Set properties from ResultSet
        student.setId(rs.getString(ID));
        student.setUserName(rs.getString(USERNAME));
        student.setFullName(rs.getString(FULLNAME));
        student.setUserEmail(rs.getString(USEREMAIL));
        student.setUserPassword(rs.getString(USERPASSWORD));
        student.setRole(rs.getString(USERROLE));
        student.setUserPhoneNum(rs.getString(USERPHONENUM));
        student.setStudentID(rs.getString(STUDENTID));
        student.setFaculty(rs.getString(FACULTY));
        student.setProgram(rs.getString(PROGRAM));
        
        return student;
    }

    /**
     * Updates only specific fields (partial update)
     */
    public boolean updatePartialProfile(String studentId, 
                                        String fieldName, 
                                        String fieldValue) throws SQLException {
        // Validate input
        if (studentId == null || studentId.trim().isEmpty() || 
            fieldName == null || fieldName.trim().isEmpty()) {
            return false;
        }

        // Determine which table to update based on field name
        String sql;
        if (fieldName.equalsIgnoreCase("FULLNAME") || 
            fieldName.equalsIgnoreCase("USERPHONENUM") || 
            fieldName.equalsIgnoreCase("USEREMAIL")) {
            sql = "UPDATE USERS u SET " + fieldName + " = ? " +
                  "WHERE u.ID = (SELECT s.ID FROM STUDENT s WHERE s.STUDENTID = ?)";
        } else if (fieldName.equalsIgnoreCase("FACULTY") || 
                   fieldName.equalsIgnoreCase("PROGRAM")) {
            sql = "UPDATE STUDENT SET " + fieldName + " = ? WHERE STUDENTID = ?";
        } else {
            throw new IllegalArgumentException("Invalid field name: " + fieldName);
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, safe(fieldValue));
            ps.setString(2, studentId.trim());
            
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Checks if student exists
     */
    public boolean studentExists(String studentId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM STUDENT WHERE STUDENTID = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, studentId.trim());
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    /**
     * Validates email format (basic)
     */
    private boolean isValidEmail(String email) {
        if (email == null) return false;
        String emailRegex = "^[A-Za-z0-9+_.-]+@(.+)$";
        return email.matches(emailRegex);
    }

    /**
     * Sanitizes input strings
     */
    private String safe(String s) {
        if (s == null) return "";
        // Trim and remove extra whitespace
        return s.trim().replaceAll("\\s+", " ");
    }

    /**
     * Gets student ID by username (if needed)
     */
    public String getStudentIdByUsername(String username) throws SQLException {
        String sql = "SELECT s.STUDENTID FROM STUDENT s " +
                     "JOIN USERS u ON s.ID = u.ID WHERE u.USERNAME = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, username);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString(STUDENTID);
                }
            }
        }
        return null;
    }
}