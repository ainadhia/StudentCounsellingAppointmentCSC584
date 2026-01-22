package com.counselling.dao;

import com.counselling.model.Session;
import com.counselling.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SessionDAO {
    
    public boolean generateDailySlots(int counselorID, String dateStr) throws SQLException {
        System.out.println("Generating slots for counselor " + counselorID + " on " + dateStr);
        
        // Check if slots already exist
        String checkSql = "SELECT COUNT(*) FROM SESSION WHERE counselorID = ? AND DATE(startTime) = ?";
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(checkSql)) {
            
            ps.setInt(1, counselorID);
            ps.setString(2, dateStr);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                System.out.println("Slots already exist for this date");
                return false;
            }
        }
        
        // Generate default time slots
        String[][] timeSlots = {
            {"08:00:00", "09:00:00"},
            {"09:00:00", "10:00:00"},
            {"10:00:00", "11:00:00"},
            {"11:00:00", "12:00:00"},
            {"14:00:00", "15:00:00"},
            {"15:00:00", "16:00:00"}
        };
        
        String insertSql = "INSERT INTO SESSION (startTime, endTime, sessionStatus, counselorID) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.createConnection();
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
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SessionDAO {
    private Connection connection;
    
    public SessionDAO(Connection connection) {
        this.connection = connection;
    }
    
    public void generateDailySlots(int counselorID, String dateStr) throws SQLException {
        List<Session> existing = getSessionsByDate(counselorID, dateStr);
        
        if (!existing.isEmpty()) {
            return;
        }
        
        String[][] timeSlots = {
            {"08:00:00", "09:00:00"}, {"09:00:00", "10:00:00"},
            {"10:00:00", "11:00:00"}, {"11:00:00", "12:00:00"},
            {"14:00:00", "15:00:00"}, {"15:00:00", "16:00:00"}
        };
        
        String sql = "INSERT INTO APP.SESSION (\"STARTTIME\", \"ENDTIME\", \"SESSIONSTATUS\", \"COUNSELORID\") VALUES (?, ?, ?, ?)";
        
        for (String[] slot : timeSlots) {
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setTimestamp(1, Timestamp.valueOf(dateStr + " " + slot[0]));
                ps.setTimestamp(2, Timestamp.valueOf(dateStr + " " + slot[1]));
                ps.setString(3, "available");
                ps.setInt(4, counselorID);
                ps.executeUpdate();
            }
        }
    }
    
    public boolean addSession(Session session) throws SQLException {
        System.out.println("Adding session for counselor " + session.getCounselorID());
        
        String sql = "INSERT INTO SESSION (startTime, endTime, sessionStatus, counselorID) " +
                     "VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.createConnection();
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
    
    public List<Session> getSessionsByDate(int counselorID, String dateStr) throws SQLException {
        System.out.println("Getting sessions for counselor " + counselorID + " on " + dateStr);
        
        autoMarkPastSessionsUnavailable(counselorID, dateStr);
        List<Session> sessions = new ArrayList<>();
        String sql = "SELECT * FROM SESSION WHERE counselorID = ? " +
                     "AND DATE(startTime) = ? ORDER BY startTime";
        
        try (Connection conn = DBConnection.createConnection();
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
        String sql = "INSERT INTO APP.SESSION (\"STARTTIME\", \"ENDTIME\", \"SESSIONSTATUS\", \"COUNSELORID\") VALUES (?, ?, ?, ?)";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setTimestamp(1, session.getStartTime());
            stmt.setTimestamp(2, session.getEndTime());
            stmt.setString(3, session.getSessionStatus());
            stmt.setInt(4, session.getCounselorID());
            return stmt.executeUpdate() > 0;
        }
    }
    
    // IMPROVED: Now handles all 4 parameters and database column name casing
    public List<Session> getSessionsByDate(int counselorID, String dateStr) throws SQLException {
        List<Session> sessions = new ArrayList<>();

        // Use simple date comparison instead of YEAR/MONTH/DAY functions for better performance
        String sql = "SELECT s.\"SESSIONID\", s.\"STARTTIME\", s.\"ENDTIME\", s.\"SESSIONSTATUS\", s.\"COUNSELORID\" " +
            "FROM APP.SESSION s " +
            "WHERE s.\"COUNSELORID\" = ? " +
            "AND CAST(s.\"STARTTIME\" AS DATE) = CAST(? AS DATE) " +
            "ORDER BY s.\"STARTTIME\"";

        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
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

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, counselorID);
            ps.setString(2, dateStr);

            int updated = ps.executeUpdate();
            if (updated > 0) {
                System.out.println("Auto-marked " + updated + " past sessions as unavailable");
            }
        }
    }
    
    public boolean hasTimeOverlap(int counselorID, String dateStr, String startTimeStr, String endTimeStr) throws SQLException {
        System.out.println("Checking time overlap for " + dateStr + " " + startTimeStr + " - " + endTimeStr);
        
        // Ensure proper time format
        if (startTimeStr.length() == 5) startTimeStr += ":00";
        if (endTimeStr.length() == 5) endTimeStr += ":00";
        
        String sql = "SELECT COUNT(*) FROM SESSION " +
                    "WHERE counselorID = ? " +
                    "AND DATE(startTime) = ? " +
                    "AND ((startTime < TIMESTAMP(?, ?) AND endTime > TIMESTAMP(?, ?)) " +
                    "OR (startTime >= TIMESTAMP(?, ?) AND startTime < TIMESTAMP(?, ?)))";
        
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, counselorID);
            ps.setString(2, dateStr);
            
            // Parameters for first condition
            ps.setString(3, dateStr);
            ps.setString(4, endTimeStr);
            ps.setString(5, dateStr);
            ps.setString(6, startTimeStr);
            
            // Parameters for second condition
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
    
    public Session getSessionById(int sessionID) throws SQLException {
        String sql = "SELECT * FROM SESSION WHERE sessionID = ?";
        
        try (Connection conn = DBConnection.createConnection();
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
    public boolean hasTimeOverlap(int counselorID, String dateStr, String startTimeStr, String endTimeStr) throws SQLException {
        Timestamp newStart = Timestamp.valueOf(dateStr + " " + (startTimeStr.length() == 5 ? startTimeStr + ":00" : startTimeStr));
        Timestamp newEnd = Timestamp.valueOf(dateStr + " " + (endTimeStr.length() == 5 ? endTimeStr + ":00" : endTimeStr));
        
        String sql = "SELECT COUNT(*) FROM APP.SESSION WHERE \"COUNSELORID\" = ? AND \"SESSIONSTATUS\" != 'cancelled' " +
                     "AND CAST(\"STARTTIME\" AS DATE) = CAST(? AS DATE) " +
                     "AND ((\"STARTTIME\" < ? AND \"ENDTIME\" > ?) OR (\"STARTTIME\" >= ? AND \"STARTTIME\" < ?))";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
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
        String sql = "SELECT \"SESSIONID\", \"STARTTIME\", \"ENDTIME\", \"SESSIONSTATUS\", \"COUNSELORID\" FROM APP.SESSION WHERE \"SESSIONID\" = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, sessionID);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Session s = new Session();
                s.setSessionID(rs.getInt("SESSIONID"));
                s.setStartTime(rs.getTimestamp("STARTTIME"));
                s.setEndTime(rs.getTimestamp("ENDTIME"));
                s.setSessionStatus(rs.getString("SESSIONSTATUS"));
                s.setCounselorID(rs.getInt("COUNSELORID"));
                return s;
            }
        }
        return null;
    }
    
    public boolean updateSessionStatus(int sessionID, String status) throws SQLException {
        System.out.println("Updating session " + sessionID + " status to " + status);
        
        String sql = "UPDATE SESSION SET sessionStatus = ? WHERE sessionID = ?";
        
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setInt(2, sessionID);
            
            int result = ps.executeUpdate();
            System.out.println("Status updated: " + (result > 0));
            return result > 0;
        String sql = "UPDATE APP.SESSION SET \"SESSIONSTATUS\" = ? WHERE \"SESSIONID\" = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setInt(2, sessionID);
            return stmt.executeUpdate() > 0;
        }
    }
    
    public boolean deleteSession(int sessionID) throws SQLException {
        System.out.println("Deleting session " + sessionID);
        
        String sql = "DELETE FROM SESSION WHERE sessionID = ? AND sessionStatus != 'booked'";
        
        try (Connection conn = DBConnection.createConnection();
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
        
        try (Connection conn = DBConnection.createConnection();
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
        
        try (Connection conn = DBConnection.createConnection();
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
                     "AND startTime >= CURRENT_TIMESTAMP " +  // Pastikan masa belum berlalu
                     "ORDER BY startTime";

        try (Connection conn = DBConnection.createConnection();
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
        String sql = "DELETE FROM APP.SESSION WHERE \"SESSIONID\" = ? AND \"SESSIONSTATUS\" = 'available'";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, sessionID);
            return stmt.executeUpdate() > 0;
        }
    }

    // IMPROVED: Updated to use robust date filtering and result mapping
    public List<Session> getAvailableSessions(int counselorID, String dateStr) throws SQLException {
        List<Session> sessions = new ArrayList<>();
        String sql = "SELECT \"SESSIONID\", \"STARTTIME\", \"ENDTIME\", \"SESSIONSTATUS\", \"COUNSELORID\" FROM APP.SESSION " +
                     "WHERE \"COUNSELORID\" = ? " +
                     "AND YEAR(\"STARTTIME\") = ? " +
                     "AND MONTH(\"STARTTIME\") = ? " +
                     "AND DAY(\"STARTTIME\") = ? " +
                     "AND \"SESSIONSTATUS\" = 'available' ORDER BY \"STARTTIME\"";
                     
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            String[] parts = dateStr.split("-");
            
            if (parts.length != 3) {
                return sessions; // Return empty list if date format is invalid
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
}
