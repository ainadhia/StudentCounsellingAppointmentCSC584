package com.counselling.dao;

import com.counselling.model.Session;
<<<<<<< HEAD
import com.counselling.util.DBConnection;
=======
>>>>>>> cfe4021dbeaf489fd67b19fec1c67eb660810512
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SessionDAO {
<<<<<<< HEAD

    public boolean addSession(Session session) {
        Connection conn = null;
        PreparedStatement ps = null;
        boolean result = false;
        try {
            conn = DBConnection.createConnection();
            // SESSIONID tidak dimasukkan kerana ia AUTO_INCREMENT (INTEGER)
            String sql = "INSERT INTO SESSION (STARTTIME, ENDTIME, SESSIONSTATUS, COUNSELORID, SESSIONDATE) VALUES (?, ?, ?, ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setString(1, session.getStartTime());
            ps.setString(2, session.getEndTime());
            ps.setString(3, "Available");
            ps.setString(4, session.getCounselorID());
            ps.setString(5, session.getSessionDate());
            
            int row = ps.executeUpdate();
            if (row > 0) result = true;
        } catch (SQLException e) {
        } finally {
            try { if (ps != null) ps.close(); if (conn != null) conn.close(); } catch (SQLException e) {}
        }
        return result;
    }

    public List<Session> getSessionsByDate(String date, String counselorID) {
        List<Session> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.createConnection();
            String sql = "SELECT * FROM SESSION WHERE SESSIONDATE = ? AND COUNSELORID = ? ORDER BY STARTTIME ASC";
            ps = conn.prepareStatement(sql);
            ps.setString(1, date);
            ps.setString(2, counselorID);
            rs = ps.executeQuery();
            while (rs.next()) {
                Session s = new Session();
                s.setSessionID(rs.getInt("SESSIONID"));
                s.setStartTime(rs.getString("STARTTIME"));
                s.setEndTime(rs.getString("ENDTIME"));
                s.setSessionStatus(rs.getString("SESSIONSTATUS"));
                s.setSessionDate(rs.getString("SESSIONDATE"));
                list.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (conn != null) conn.close(); } catch (SQLException e) {}
        }
        return list;
    }
=======
    private Connection connection;
    
    public SessionDAO(Connection connection) {
        this.connection = connection;
    }
    
    public void generateDailySlots(int counselorID, String dateStr) throws SQLException {
        System.out.println("=== GENERATE DAILY SLOTS ===");
        System.out.println("CounselorID (int): " + counselorID);
        System.out.println("Date: " + dateStr);
        
        List<Session> existing = getSessionsByDate(counselorID, dateStr);
        System.out.println("Existing slots: " + existing.size());
        
        if (!existing.isEmpty()) {
            System.out.println("Slots dah wujud, skip generation");
            return;
        }
        
        String[][] timeSlots = {
            {"08:00:00", "09:00:00"},
            {"09:00:00", "10:00:00"},
            {"10:00:00", "11:00:00"},
            {"11:00:00", "12:00:00"},
            {"14:00:00", "15:00:00"},
            {"15:00:00", "16:00:00"}
        };
        
        String sql = "INSERT INTO SESSION (startTime, endTime, sessionStatus, counselorID) " +
                     "VALUES (?, ?, ?, ?)";
        
        for (String[] slot : timeSlots) {
            try (PreparedStatement ps = connection.prepareStatement(sql)) {

                Timestamp startTime = Timestamp.valueOf(dateStr + " " + slot[0]);
                Timestamp endTime = Timestamp.valueOf(dateStr + " " + slot[1]);
                
                ps.setTimestamp(1, startTime);
                ps.setTimestamp(2, endTime);
                ps.setString(3, "available");
                ps.setInt(4, counselorID);
                
                int rows = ps.executeUpdate();
                System.out.println("✓ Slot created: " + slot[0].substring(0,5) + "-" + 
                                 slot[1].substring(0,5) + " (" + rows + " row)");
            } catch (SQLException e) {
                System.err.println("✗ Error creating slot: " + slot[0] + "-" + slot[1]);
                e.printStackTrace();
            }
        }
        System.out.println("=== GENERATION COMPLETE ===\n");
    }
    
    public boolean addSession(Session session) throws SQLException {
        System.out.println("=== DAO: ADD SESSION ===");
        System.out.println("CounselorID (int): " + session.getCounselorID());
        
        String sql = "INSERT INTO SESSION (startTime, endTime, sessionStatus, counselorID) " +
                     "VALUES (?, ?, ?, ?)";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setTimestamp(1, session.getStartTime());
            stmt.setTimestamp(2, session.getEndTime());
            stmt.setString(3, session.getSessionStatus());
            stmt.setInt(4, session.getCounselorID());
            
            int rows = stmt.executeUpdate();
            System.out.println("Rows inserted: " + rows);
            return rows > 0;
        }
    }
    
    public List<Session> getSessionsByDate(int counselorID, String dateStr) throws SQLException {
        List<Session> sessions = new ArrayList<>();

        String sql = "SELECT s.sessionID, s.startTime, s.endTime, s.sessionStatus, " +
                    "s.counselorID " +  
                    "FROM SESSION s " +
                    "WHERE s.counselorID = ? " +
                    "AND DATE(s.startTime) = ? " +  
                    "ORDER BY s.startTime";

        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, counselorID);
            stmt.setString(2, dateStr); 

            System.out.println("DEBUG: Executing query: " + sql);
            System.out.println("DEBUG: Params - counselorID=" + counselorID + ", date=" + dateStr);

            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Session session = new Session();
                
                int sessionId = rs.getInt("sessionID");
                session.setSessionID(rs.wasNull() ? 0 : sessionId);
                
                session.setStartTime(rs.getTimestamp("startTime"));
                session.setEndTime(rs.getTimestamp("endTime"));
                
                String status = rs.getString("sessionStatus");
                session.setSessionStatus(status != null ? status : "unknown");
                
                int cId = rs.getInt("counselorID");
                session.setCounselorID(rs.wasNull() ? 0 : cId);
                
                sessions.add(session);

                System.out.println("DEBUG: Loaded session - ID=" + session.getSessionID() + 
                    ", Time=" + (session.getStartTime() != null ? session.getStartTime().toString() : "null") + 
                    ", Status=" + session.getSessionStatus());
            }

            System.out.println("DEBUG: Total sessions retrieved: " + sessions.size());
        } catch (SQLException e) {
            System.err.println("ERROR in getSessionsByDate: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }

        return sessions;
    }
    
    public boolean hasTimeOverlap(int counselorID, String dateStr, 
                                  String startTimeStr, String endTimeStr) throws SQLException {

        if (!startTimeStr.contains(":")) startTimeStr += ":00:00";
        else if (startTimeStr.split(":").length == 2) startTimeStr += ":00";
        
        if (!endTimeStr.contains(":")) endTimeStr += ":00:00";
        else if (endTimeStr.split(":").length == 2) endTimeStr += ":00";
        
        Timestamp newStart = Timestamp.valueOf(dateStr + " " + startTimeStr);
        Timestamp newEnd = Timestamp.valueOf(dateStr + " " + endTimeStr);
        
        String sql = "SELECT COUNT(*) FROM SESSION " +
                     "WHERE counselorID = ? " +
                     "AND sessionStatus != 'cancelled' " +
                     "AND DATE(startTime) = ? " +
                     "AND (" +
                     "  (startTime < ? AND endTime > ?) " +
                     "  OR (startTime >= ? AND startTime < ?)" +
                     ")";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, counselorID);
            stmt.setString(2, dateStr);
            stmt.setTimestamp(3, newEnd);
            stmt.setTimestamp(4, newStart);
            stmt.setTimestamp(5, newStart);
            stmt.setTimestamp(6, newEnd);
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("Overlap check: " + count + " conflicting sessions found");
                return count > 0;
            }
        }
        return false;
    }
    
    public Session getSessionById(int sessionID) throws SQLException {
        String sql = "SELECT * FROM SESSION WHERE sessionID = ?";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, sessionID);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Session session = new Session();
                
                int sId = rs.getInt("sessionID");
                session.setSessionID(rs.wasNull() ? 0 : sId);
                
                session.setStartTime(rs.getTimestamp("startTime"));
                session.setEndTime(rs.getTimestamp("endTime"));
                
                String status = rs.getString("sessionStatus");
                session.setSessionStatus(status != null ? status : "unknown");
                
                int cId = rs.getInt("counselorID");
                session.setCounselorID(rs.wasNull() ? 0 : cId);
                
                return session;
            }
        }
        return null;
    }
    
    public boolean updateSessionStatus(int sessionID, String status) throws SQLException {
        String sql = "UPDATE SESSION SET sessionStatus = ? WHERE sessionID = ?";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, status != null ? status : "unknown");
            stmt.setInt(2, sessionID);
            return stmt.executeUpdate() > 0;
        }
    }
    
    public boolean deleteSession(int sessionID) throws SQLException {
        String sql = "DELETE FROM SESSION WHERE sessionID = ? AND sessionStatus = 'available'";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, sessionID);
            return stmt.executeUpdate() > 0;
        }
    }
    
    public List<Session> getSessionsByCounselor(int counselorID) throws SQLException {
        List<Session> sessions = new ArrayList<>();
        
        String sql = "SELECT * FROM SESSION WHERE counselorID = ? ORDER BY startTime";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, counselorID);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Session session = new Session();
                
                int sId = rs.getInt("sessionID");
                session.setSessionID(rs.wasNull() ? 0 : sId);
                
                session.setStartTime(rs.getTimestamp("startTime"));
                session.setEndTime(rs.getTimestamp("endTime"));
                
                String status = rs.getString("sessionStatus");
                session.setSessionStatus(status != null ? status : "unknown");
                
                int cId = rs.getInt("counselorID");
                session.setCounselorID(rs.wasNull() ? 0 : cId);
                
                sessions.add(session);
            }
        }
        return sessions;
    }
    
    public List<Session> getAvailableSessions(int counselorID, String dateStr) throws SQLException {
        List<Session> sessions = new ArrayList<>();
        
        String sql = "SELECT * FROM SESSION " +
                     "WHERE counselorID = ? " +
                     "AND DATE(startTime) = ? " +
                     "AND sessionStatus = 'available' " +
                     "AND startTime > CURRENT_TIMESTAMP " +
                     "ORDER BY startTime";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, counselorID);
            stmt.setString(2, dateStr);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Session session = new Session();
                
                int sId = rs.getInt("sessionID");
                session.setSessionID(rs.wasNull() ? 0 : sId);
                
                session.setStartTime(rs.getTimestamp("startTime"));
                session.setEndTime(rs.getTimestamp("endTime"));
                
                String status = rs.getString("sessionStatus");
                session.setSessionStatus(status != null ? status : "unknown");
                
                int cId = rs.getInt("counselorID");
                session.setCounselorID(rs.wasNull() ? 0 : cId);
                
                sessions.add(session);
            }
        }
        return sessions;
    }
    
>>>>>>> cfe4021dbeaf489fd67b19fec1c67eb660810512
}