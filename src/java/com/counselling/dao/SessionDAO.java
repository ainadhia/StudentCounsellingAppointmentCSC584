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
            }
        }
        return sessions;
    }
}