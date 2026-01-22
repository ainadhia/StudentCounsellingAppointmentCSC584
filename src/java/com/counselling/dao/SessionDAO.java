package com.counselling.dao;

import com.counselling.model.Session;
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
        String sql = "UPDATE APP.SESSION SET \"SESSIONSTATUS\" = ? WHERE \"SESSIONID\" = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setInt(2, sessionID);
            return stmt.executeUpdate() > 0;
        }
    }
    
    public boolean deleteSession(int sessionID) throws SQLException {
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