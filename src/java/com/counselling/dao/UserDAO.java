package com.counselling.dao;

import com.counselling.model.Counselor;
import com.counselling.util.DBConnection;
import com.counselling.model.Student;
import java.sql.*;

public class UserDAO {

    public boolean isUsernameTaken(String username) throws SQLException {
        String sql = "SELECT 1 FROM USERS WHERE USERNAME = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean isIDTaken(String id, String role) throws SQLException {
        String table = (role.equals("S")) ? "STUDENT" : "COUNSELOR";
        String column = (role.equals("S")) ? "STUDENTID" : "COUNSELORID";
        String sql = "SELECT 1 FROM " + table + " WHERE " + column + " = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean registerUser(Student s) throws SQLException {
        Connection conn = null;
        PreparedStatement psUser = null;
        PreparedStatement psS = null;
        PreparedStatement psC = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.createConnection();
            conn.setAutoCommit(false);

            String sqlUser = "INSERT INTO USERS (USERNAME, FULLNAME, USEREMAIL, USERPASSWORD, USERROLE, USERPHONENUM) VALUES (?,?,?,?,?,?)";
            psUser = conn.prepareStatement(sqlUser, Statement.RETURN_GENERATED_KEYS);
            psUser.setString(1, s.getUserName());
            psUser.setString(2, s.getFullName());
            psUser.setString(3, s.getUserEmail());
            psUser.setString(4, s.getUserPassword());
            psUser.setString(5, s.getUserRole());
            psUser.setString(6, s.getUserPhoneNum());
            psUser.executeUpdate();

            rs = psUser.getGeneratedKeys();
            if (rs.next()) {
                int userID = rs.getInt(1);

                if (s.getUserRole().equals("S")) {
                    String sqlStud = "INSERT INTO STUDENT (ID, STUDENTID, FACULTY, PROGRAM) VALUES (?,?,?,?)";
                    psS = conn.prepareStatement(sqlStud);
                    psS.setInt(1, userID);
                    psS.setString(2, s.getStudentID());
                    psS.setString(3, s.getFaculty());
                    psS.setString(4, s.getProgram());
                    psS.executeUpdate();
                } else if (s.getUserRole().equals("C")) {
                    String sqlCouns = "INSERT INTO COUNSELOR (ID, COUNSELORID, ROOMNO) VALUES (?,?,?)";
                    psC = conn.prepareStatement(sqlCouns);
                    psC.setInt(1, userID);
                    psC.setString(2, s.getCounselorID());
                    psC.setString(3, s.getRoomNo());
                    psC.executeUpdate();
                }
            }

            conn.commit();
            return true;
            
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            throw e;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (psS != null) try { psS.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (psC != null) try { psC.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (psUser != null) try { psUser.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    public Student authenticate(String id, String password, String role) throws SQLException {
        Student user = null;
        String table = (role.equals("S")) ? "STUDENT" : "COUNSELOR";
        String idCol = (role.equals("S")) ? "STUDENTID" : "COUNSELORID";
        
        String sql = "SELECT u.ID, u.USERNAME, u.FULLNAME, u.USEREMAIL, u.USERPASSWORD, u.USERROLE, u.USERPHONENUM";
        
        if (role.equals("S")) {
            sql += ", s.STUDENTID, s.FACULTY, s.PROGRAM " +
                   "FROM USERS u " +
                   "JOIN STUDENT s ON u.ID = s.ID " +
                   "WHERE s.STUDENTID = ? AND u.USERPASSWORD = ?";
        } else {
            sql += ", c.COUNSELORID, c.ROOMNO " +
                   "FROM USERS u " +
                   "JOIN COUNSELOR c ON u.ID = c.ID " +
                   "WHERE c.COUNSELORID = ? AND u.USERPASSWORD = ?";
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.setString(2, password);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    user = new Student();
                    user.setID(rs.getInt("ID"));
                    user.setUserName(rs.getString("USERNAME"));
                    user.setFullName(rs.getString("FULLNAME"));
                    user.setUserEmail(rs.getString("USEREMAIL"));
                    user.setUserRole(rs.getString("USERROLE"));
                    user.setUserPhoneNum(rs.getString("USERPHONENUM"));
                    
                    if (role.equals("S")) {
                        user.setStudentID(rs.getString("STUDENTID"));
                        user.setFaculty(rs.getString("FACULTY"));
                        user.setProgram(rs.getString("PROGRAM"));
                    } else {
                        user.setCounselorID(rs.getString("COUNSELORID"));
                        user.setRoomNo(rs.getString("ROOMNO"));
                    }
                }
            }
        }
        return user;
    }
       
    public Counselor authenticateCounselor(String id, String password) throws SQLException {
        String sql = "SELECT u.ID, u.USERNAME, u.FULLNAME, u.USEREMAIL, u.USERPASSWORD, u.USERPHONENUM, " +
                     "c.ROOMNO, c.COUNSELORID " +
                     "FROM USERS u " +
                     "JOIN COUNSELOR c ON u.ID = c.ID " +
                     "WHERE c.COUNSELORID = ? AND u.USERPASSWORD = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Counselor counselor = new Counselor();
                    counselor.setID(rs.getInt("ID"));
                    counselor.setUserName(rs.getString("USERNAME"));
                    counselor.setFullName(rs.getString("FULLNAME"));
                    counselor.setUserEmail(rs.getString("USEREMAIL"));
                    counselor.setUserPassword(rs.getString("USERPASSWORD"));
                    counselor.setUserPhoneNum(rs.getString("USERPHONENUM"));
                    counselor.setCounselorID(rs.getString("COUNSELORID"));
                    counselor.setRoomNo(rs.getString("ROOMNO"));
                    return counselor;
                }
            }
        }
        return null;
    }

    public Student getStudentByAppointmentId(int studentId) throws SQLException {
        System.out.println("Looking for Student with ID = " + studentId);

        String sql = "SELECT u.ID, u.FULLNAME, u.USEREMAIL, u.USERPHONENUM, " +
                    "s.STUDENTID, s.FACULTY, s.PROGRAM " +
                    "FROM USERS u " +
                    "INNER JOIN STUDENT s ON u.ID = s.ID " +
                    "WHERE u.ID = ?";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, studentId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Student student = new Student();
                student.setID(rs.getInt("ID"));
                student.setFullName(rs.getString("FULLNAME"));
                student.setUserEmail(rs.getString("USEREMAIL"));
                student.setUserPhoneNum(rs.getString("USERPHONENUM"));
                student.setStudentID(rs.getString("STUDENTID"));
                student.setFaculty(rs.getString("FACULTY"));
                student.setProgram(rs.getString("PROGRAM"));
                
                System.out.println("FOUND: " + student.getFullName());
                return student;
            } else {
                System.out.println("NOT FOUND");
                return null;
            }
        }
    }

    public Counselor getCounselorById(int counselorId) throws SQLException {
        System.out.println("Looking for Counselor with ID = " + counselorId);

        String sql = "SELECT u.ID, u.FULLNAME, u.USEREMAIL, u.USERPHONENUM, " +
                    "c.COUNSELORID, c.ROOMNO " +
                    "FROM USERS u " +
                    "INNER JOIN COUNSELOR c ON u.ID = c.ID " +
                    "WHERE u.ID = ?";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, counselorId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Counselor counselor = new Counselor();
                counselor.setID(rs.getInt("ID"));
                counselor.setFullName(rs.getString("FULLNAME"));
                counselor.setUserEmail(rs.getString("USEREMAIL"));
                counselor.setUserPhoneNum(rs.getString("USERPHONENUM"));
                counselor.setCounselorID(rs.getString("COUNSELORID"));
                counselor.setRoomNo(rs.getString("ROOMNO"));
                
                System.out.println("FOUND: " + counselor.getFullName());
                return counselor;
            } else {
                System.out.println("NOT FOUND");
                return null;
            }
        }
    }
}