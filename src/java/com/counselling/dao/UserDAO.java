package com.counselling.dao;

import com.counselling.util.DBConnection;
import com.counselling.model.Student;
import java.sql.*;

public class UserDAO {

    // 1. SEMAKAN KETAT: Username Unik
    public boolean isUsernameTaken(String username) throws SQLException {
        String sql = "SELECT 1 FROM USERS WHERE USERNAME = ?";
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next(); // True jika wujud
            }
        }
    }

    // 2. SEMAKAN KETAT: ID (Student/Counselor) Unik
    public boolean isIDTaken(String id, String role) throws SQLException {
        String table = (role.equals("S")) ? "STUDENT" : "COUNSELOR";
        String column = (role.equals("S")) ? "STUDENTID" : "COUNSELORID";
        String sql = "SELECT 1 FROM " + table + " WHERE " + column + " = ?";
        
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // 3. PROSES PENDAFTARAN (Dua Jadual - Transactional)
    public boolean registerUser(Student s) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConnection.createConnection();
            conn.setAutoCommit(false); // Mula transaksi

            // Simpan ke jadual USERS
            String sqlUser = "INSERT INTO USERS (USERNAME, FULLNAME, USEREMAIL, USERPASSWORD, USERROLE, USERPHONENUM) VALUES (?,?,?,?,?,?)";
            PreparedStatement psUser = conn.prepareStatement(sqlUser, Statement.RETURN_GENERATED_KEYS);
            psUser.setString(1, s.getUserName());
            psUser.setString(2, s.getFullName());
            psUser.setString(3, s.getUserEmail());
            psUser.setString(4, s.getUserPassword());
            psUser.setString(5, s.getRole());
            psUser.setString(6, s.getUserPhoneNum());
            psUser.executeUpdate();

            // Dapatkan ID auto-increment yang dijana
            ResultSet rs = psUser.getGeneratedKeys();
            if (rs.next()) {
                int userId = rs.getInt(1);

                if (s.getRole().equals("S")) {
                    // Simpan ke jadual STUDENT
                    String sqlStud = "INSERT INTO STUDENT (ID, STUDENTID, FACULTY, PROGRAM) VALUES (?,?,?,?)";
                    PreparedStatement psS = conn.prepareStatement(sqlStud);
                    psS.setInt(1, userId);
                    psS.setString(2, s.getStudentID());
                    psS.setString(3, s.getFaculty());
                    psS.setString(4, s.getProgram());
                    psS.executeUpdate();
                } else {
                    // Simpan ke jadual COUNSELOR
                    String sqlCouns = "INSERT INTO COUNSELOR (ID, COUNSELORID, ROOMNO) VALUES (?,?,?)";
                    PreparedStatement psC = conn.prepareStatement(sqlCouns);
                    psC.setInt(1, userId);
                    psC.setString(2, s.getCounselorID());
                    psC.setString(3, s.getRoomNo());
                    psC.executeUpdate();
                }
            }

            conn.commit(); // Simpan kekal
            return true;
        } catch (SQLException e) {
            if (conn != null) conn.rollback(); // Batalkan jika gagal
            throw e;
        } finally {
            if (conn != null) conn.close();
        }
    }

    // 4. PROSES LOG MASUK (Authentication dengan JOIN)
    public Student authenticate(String id, String password, String role) throws SQLException {
        Student user = null;
        String table = (role.equals("S")) ? "STUDENT" : "COUNSELOR";
        String idCol = (role.equals("S")) ? "STUDENTID" : "COUNSELORID";
        
        // Query JOIN antara USERS dan (STUDENT/COUNSELOR)
        String sql = "SELECT u.* FROM USERS u " +
                     "JOIN " + table + " t ON u.ID = t.ID " +
                     "WHERE t." + idCol + " = ? AND u.USERPASSWORD = ?";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.setString(2, password);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    user = new Student();
                    user.setUserName(rs.getString("USERNAME"));
                    user.setFullName(rs.getString("FULLNAME"));
                    user.setUserEmail(rs.getString("USEREMAIL"));
                    user.setRole(rs.getString("USERROLE"));
                    user.setUserPhoneNum(rs.getString("USERPHONENUM"));
                    
                    // Set ID semula mengikut role
                    if (role.equals("S")) user.setStudentID(id);
                    else user.setCounselorID(id);
                }
            }
        }
        return user;
    }
}