package com.counselling.dao;

import com.counselling.model.Session;
import com.counselling.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SessionDAO {
    private Connection connection;
    private boolean useExternalConnection;
    
    // =================== CONSTRUCTORS ===================
    
    // Constructor 1: With external connection
    public SessionDAO(Connection connection) {
        this.connection = connection;
        this.useExternalConnection = true;
    }
    
    // Constructor 2: Without parameter - uses DBConnection.createConnection()
    public SessionDAO() {
        this.useExternalConnection = false;
    }
    
    // =================== HELPER METHODS ===================
    
    private Connection getConnection() throws SQLException {
        if (useExternalConnection && connection != null) {
            return connection;
        } else {
            return DBConnection.createConnection();
        }
    }
    
    // =================== SESSION MANAGEMENT METHODS ===================
    
    public int getDefaultCounselorID() throws SQLException {
        String sql = "SELECT ID FROM USERS WHERE userRole = 'counselor' FETCH FIRST 1 ROWS ONLY";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("ID");
            }
        }
        return 1; // Default counselor ID jika tak jumpa
    }
    
    // Overloaded method untuk servlet yang tak perlukan counselorID
    public List<Session> getSessionsByDate(String dateStr) throws SQLException {
        int defaultCounselorID = getDefaultCounselorID();
        return getSessionsByDate(defaultCounselorID, dateStr);
    }
    
    // Method utama dengan 2 parameters
    public List<Session> getSessionsByDate(int counselorID, String dateStr) throws SQLException {
        System.out.println("Getting sessions for counselor " + counselorID + " on " + dateStr);
        
        autoMarkPastSessionsUnavailable(counselorID, dateStr);
        List<Session> sessions = new ArrayList<>();
        
        // Check which table/schema to use
        String tableName = "SESSION"; // Default
        String schemaPrefix = ""; // Default empty
        
        // Try to detect database type
        try (Connection conn = getConnection()) {
            DatabaseMetaData meta = conn.getMetaData();
            String dbName = meta.getDatabaseProductName();
            
            if (dbName.contains("Apache Derby") || dbName.contains("Derby")) {
                // For Derby database with APP schema
                tableName = "APP.SESSION";
                schemaPrefix = "APP.";
            }
        } catch (SQLException e) {
            System.out.println("Warning: Could not detect database type, using default table name");
        }
        
        String sql = "SELECT * FROM " + tableName + " WHERE counselorID = ? AND DATE(startTime) = ? ORDER BY startTime";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, counselorID);
            ps.setString(2, dateStr);
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Session session = new Session();
                session.setSessionID(rs.getInt("sessionID"));
                session.setStartTime(rs.getTimestamp("startTime"));
                session.setEndTime(rs.getTimestamp("endTime"));
                session.setSessionStatus(rs.getString("sessionStatus"));
                session.setCounselorID(rs.getInt("counselorID"));
                sessions.add(session);
            }
            
            System.out.println("Found " + sessions.size() + " sessions");
        }
        return sessions;
    }
    
    // Alternative method with quoted column names (for specific database requirements)
    public List<Session> getSessionsByDateQuoted(int counselorID, String dateStr) throws SQLException {
        List<Session> sessions = new ArrayList<>();

        String sql = "SELECT s.\"SESSIONID\", s.\"STARTTIME\", s.\"ENDTIME\", s.\"SESSIONSTATUS\", s.\"COUNSELORID\" " +
            "FROM APP.SESSION s " +
            "WHERE s.\"COUNSELORID\" = ? " +
            "AND CAST(s.\"STARTTIME\" AS DATE) = CAST(? AS DATE) " +
            "ORDER BY s.\"STARTTIME\"";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, counselorID);
            stmt.setString(2, dateStr + " 00:00:00");

            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Session session = new Session();
                session.setSessionID(rs.getInt("SESSIONID"));
                session.setStartTime(rs.getTimestamp("STARTTIME"));
                session.setEndTime(rs.getTimestamp("ENDTIME"));
                session.setSessionStatus(rs.getString("SESSIONSTATUS"));
                session.setCounselorID(rs.getInt("COUNSELORID"));
                sessions.add(session);
            }
        }
        return sessions;
    }
    
    private void autoMarkPastSessionsUnavailable(int counselorID, String dateStr) throws SQLException {
        System.out.println("Auto marking past sessions as unavailable for date: " + dateStr);

        String sql = "UPDATE SESSION SET sessionStatus = 'unavailable' " +
                     "WHERE counselorID = ? " +
                     "AND DATE(startTime) = ? " +
                     "AND endTime < CURRENT_TIMESTAMP " +
                     "AND sessionStatus NOT IN ('booked', 'completed')";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, counselorID);
            ps.setString(2, dateStr);

            int updated = ps.executeUpdate();
            if (updated > 0) {
                System.out.println("Auto-marked " + updated + " past sessions as unavailable");
            }
        }
    }
    
    public boolean generateDailySlots(int counselorID, String dateStr) throws SQLException {
        System.out.println("Generating slots for counselor " + counselorID + " on " + dateStr);
        
        String checkSql = "SELECT COUNT(*) FROM SESSION WHERE counselorID = ? AND DATE(startTime) = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(checkSql)) {
            
            ps.setInt(1, counselorID);
            ps.setString(2, dateStr);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                System.out.println("Slots already exist for this date");
                return false;
            }
        }
        
        String[][] timeSlots = {
            {"08:00:00", "09:00:00"},
            {"09:00:00", "10:00:00"},
            {"10:00:00", "11:00:00"},
            {"11:00:00", "12:00:00"},
            {"14:00:00", "15:00:00"},
            {"15:00:00", "16:00:00"}
        };
        
        String insertSql = "INSERT INTO SESSION (startTime, endTime, sessionStatus, counselorID) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(insertSql)) {
            
            for (String[] slot : timeSlots) {
                Timestamp startTime = Timestamp.valueOf(dateStr + " " + slot[0]);
                Timestamp endTime = Timestamp.valueOf(dateStr + " " + slot[1]);
                
                ps.setTimestamp(1, startTime);
                ps.setTimestamp(2, endTime);
                ps.setString(3, "available");
                ps.setInt(4, counselorID);
                
                ps.addBatch();
            }
            
            int[] results = ps.executeBatch();
            System.out.println("Generated " + results.length + " slots");
            return results.length == timeSlots.length;
        }
    }
    
    // Alternative generate method for specific database
    public void generateDailySlotsAlt(int counselorID, String dateStr) throws SQLException {
        List<Session> existing = getSessionsByDateQuoted(counselorID, dateStr);
        
        if (!existing.isEmpty()) {
            return;
        }
        
        String[][] timeSlots = {
            {"08:00:00", "09:00:00"}, {"09:00:00", "10:00:00"},
            {"10:00:00", "11:00:00"}, {"11:00:00", "12:00:00"},
            {"14:00:00", "15:00:00"}, {"15:00:00", "16:00:00"}
        };
        
        String sql = "INSERT INTO APP.SESSION (\"STARTTIME\", \"ENDTIME\", \"SESSIONSTATUS\", \"COUNSELORID\") VALUES (?, ?, ?, ?)";
        
        try (Connection conn = getConnection()) {
            for (String[] slot : timeSlots) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setTimestamp(1, Timestamp.valueOf(dateStr + " " + slot[0]));
                    ps.setTimestamp(2, Timestamp.valueOf(dateStr + " " + slot[1]));
                    ps.setString(3, "available");
                    ps.setInt(4, counselorID);
                    ps.executeUpdate();
                }
            }
        }
    }
    
    public boolean addSession(Session session) throws SQLException {
        System.out.println("Adding session for counselor " + session.getCounselorID());
        
        String sql = "INSERT INTO SESSION (startTime, endTime, sessionStatus, counselorID) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setTimestamp(1, session.getStartTime());
            ps.setTimestamp(2, session.getEndTime());
            ps.setString(3, session.getSessionStatus());
            ps.setInt(4, session.getCounselorID());
            
            int result = ps.executeUpdate();
            System.out.println("Session added: " + (result > 0));
            return result > 0;
        }
    }
    
    public boolean hasTimeOverlap(int counselorID, String dateStr, String startTimeStr, String endTimeStr) throws SQLException {
        System.out.println("Checking time overlap for " + dateStr + " " + startTimeStr + " - " + endTimeStr);
        
        if (startTimeStr.length() == 5) startTimeStr += ":00";
        if (endTimeStr.length() == 5) endTimeStr += ":00";
        
        String sql = "SELECT COUNT(*) FROM SESSION " +
                    "WHERE counselorID = ? " +
                    "AND DATE(startTime) = ? " +
                    "AND ((startTime < TIMESTAMP(?, ?) AND endTime > TIMESTAMP(?, ?)) " +
                    "OR (startTime >= TIMESTAMP(?, ?) AND startTime < TIMESTAMP(?, ?)))";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, counselorID);
            ps.setString(2, dateStr);
            
            ps.setString(3, dateStr);
            ps.setString(4, endTimeStr);
            ps.setString(5, dateStr);
            ps.setString(6, startTimeStr);
            
            ps.setString(7, dateStr);
            ps.setString(8, startTimeStr);
            ps.setString(9, dateStr);
            ps.setString(10, endTimeStr);
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                boolean hasOverlap = rs.getInt(1) > 0;
                System.out.println("Time overlap: " + hasOverlap);
                return hasOverlap;
            }
        }
        return false;
    }
    
    // Alternative overlap check method
    public boolean hasTimeOverlapAlt(int counselorID, String dateStr, String startTimeStr, String endTimeStr) throws SQLException {
        Timestamp newStart = Timestamp.valueOf(dateStr + " " + (startTimeStr.length() == 5 ? startTimeStr + ":00" : startTimeStr));
        Timestamp newEnd = Timestamp.valueOf(dateStr + " " + (endTimeStr.length() == 5 ? endTimeStr + ":00" : endTimeStr));
        
        String sql = "SELECT COUNT(*) FROM APP.SESSION WHERE \"COUNSELORID\" = ? AND \"SESSIONSTATUS\" != 'cancelled' " +
                     "AND CAST(\"STARTTIME\" AS DATE) = CAST(? AS DATE) " +
                     "AND ((\"STARTTIME\" < ? AND \"ENDTIME\" > ?) OR (\"STARTTIME\" >= ? AND \"STARTTIME\" < ?))";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, counselorID);
            stmt.setString(2, dateStr + " 00:00:00");
            stmt.setTimestamp(3, newEnd);
            stmt.setTimestamp(4, newStart);
            stmt.setTimestamp(5, newStart);
            stmt.setTimestamp(6, newEnd);
            ResultSet rs = stmt.executeQuery();
            return rs.next() && rs.getInt(1) > 0;
        }
    }
    
    public Session getSessionById(int sessionID) throws SQLException {
        String sql = "SELECT * FROM SESSION WHERE sessionID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, sessionID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Session session = new Session();
                session.setSessionID(rs.getInt("sessionID"));
                session.setStartTime(rs.getTimestamp("startTime"));
                session.setEndTime(rs.getTimestamp("endTime"));
                session.setSessionStatus(rs.getString("sessionStatus"));
                session.setCounselorID(rs.getInt("counselorID"));
                return session;
            }
        }
        return null;
    }
    
    public boolean updateSessionStatus(int sessionID, String status) throws SQLException {
        System.out.println("Updating session " + sessionID + " status to " + status);
        
        String sql = "UPDATE SESSION SET sessionStatus = ? WHERE sessionID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setInt(2, sessionID);
            
            int result = ps.executeUpdate();
            System.out.println("Status updated: " + (result > 0));
            return result > 0;
        }
    }
    
    public boolean deleteSession(int sessionID) throws SQLException {
        System.out.println("Deleting session " + sessionID);
        
        String sql = "DELETE FROM SESSION WHERE sessionID = ? AND sessionStatus != 'booked'";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, sessionID);
            int result = ps.executeUpdate();
            System.out.println("Session deleted: " + (result > 0));
            return result > 0;
        }
    }
    
    public List<Map<String, Object>> getRecentSessions(int counselorID, int limit) throws SQLException {
        List<Map<String, Object>> sessions = new ArrayList<>();
        
        String sql = "SELECT s.sessionID, s.startTime, s.endTime, s.sessionStatus, " +
                    "DATE(s.startTime) as sessionDate " +
                    "FROM SESSION s " +
                    "WHERE s.counselorID = ? " +
                    "AND s.startTime < CURRENT_TIMESTAMP " +
                    "ORDER BY s.startTime DESC " +
                    "FETCH FIRST ? ROWS ONLY";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, counselorID);
            ps.setInt(2, limit);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> session = new HashMap<>();
                session.put("sessionID", rs.getInt("sessionID"));
                session.put("startTime", rs.getTime("startTime").toString().substring(0, 5));
                session.put("endTime", rs.getTime("endTime").toString().substring(0, 5));
                session.put("status", rs.getString("sessionStatus"));
                session.put("date", rs.getDate("sessionDate"));
                sessions.add(session);
            }
        }
        return sessions;
    }
    
    public List<Session> getAvailableSessions(int counselorID) throws SQLException {
        List<Session> sessions = new ArrayList<>();
        String sql = "SELECT * FROM SESSION WHERE counselorID = ? " +
                     "AND sessionStatus = 'available' " +
                     "AND startTime >= CURRENT_DATE " +
                     "ORDER BY startTime";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, counselorID);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Session session = new Session();
                session.setSessionID(rs.getInt("sessionID"));
                session.setStartTime(rs.getTimestamp("startTime"));
                session.setEndTime(rs.getTimestamp("endTime"));
                session.setSessionStatus(rs.getString("sessionStatus"));
                session.setCounselorID(rs.getInt("counselorID"));
                sessions.add(session);
            }
        }
        return sessions;
    }
    
    public List<Session> getAvailableSessionsByDate(int counselorID, String dateStr) throws SQLException {
        List<Session> sessions = new ArrayList<>();

        String sql = "SELECT * FROM SESSION WHERE counselorID = ? " +
                     "AND DATE(startTime) = ? " +
                     "AND sessionStatus = 'available' " +
                     "AND startTime >= CURRENT_TIMESTAMP " +
                     "ORDER BY startTime";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, counselorID);
            ps.setString(2, dateStr);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Session session = new Session();
                session.setSessionID(rs.getInt("sessionID"));
                session.setStartTime(rs.getTimestamp("startTime"));
                session.setEndTime(rs.getTimestamp("endTime"));
                session.setSessionStatus(rs.getString("sessionStatus"));
                session.setCounselorID(rs.getInt("counselorID"));
                sessions.add(session);
            }
        }
        return sessions;
    }
    
    // Alternative method for available sessions
    public List<Session> getAvailableSessionsAlt(int counselorID, String dateStr) throws SQLException {
        List<Session> sessions = new ArrayList<>();
        String sql = "SELECT \"SESSIONID\", \"STARTTIME\", \"ENDTIME\", \"SESSIONSTATUS\", \"COUNSELORID\" FROM APP.SESSION " +
                     "WHERE \"COUNSELORID\" = ? " +
                     "AND YEAR(\"STARTTIME\") = ? " +
                     "AND MONTH(\"STARTTIME\") = ? " +
                     "AND DAY(\"STARTTIME\") = ? " +
                     "AND \"SESSIONSTATUS\" = 'available' ORDER BY \"STARTTIME\"";
                     
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            String[] parts = dateStr.split("-");
            
            if (parts.length != 3) {
                return sessions;
            }
            
            int year = Integer.parseInt(parts[0]);
            int month = Integer.parseInt(parts[1]);
            int day = Integer.parseInt(parts[2]);
            
            stmt.setInt(1, counselorID);
            stmt.setInt(2, year);
            stmt.setInt(3, month);
            stmt.setInt(4, day);
            
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Session s = new Session();
                s.setSessionID(rs.getInt("SESSIONID"));
                s.setStartTime(rs.getTimestamp("STARTTIME"));
                s.setEndTime(rs.getTimestamp("ENDTIME"));
                s.setSessionStatus(rs.getString("SESSIONSTATUS"));
                s.setCounselorID(rs.getInt("COUNSELORID"));
                sessions.add(s);
            }
        }
        return sessions;
    }
    
    // =================== CLOSE METHOD (for external connections) ===================
    
    public void close() throws SQLException {
        if (useExternalConnection && connection != null && !connection.isClosed()) {
            connection.close();
        }
    }
}