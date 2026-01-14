package com.counselling.dao;

import com.counselling.model.Session;
import com.counselling.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SessionDAO {

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
}