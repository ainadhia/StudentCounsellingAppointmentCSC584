package com.counselling.dao;

import com.counselling.model.RecentSession;
import com.counselling.util.DBConnection;

import java.text.SimpleDateFormat;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StudentDashboardDAO {

    public int[] getCounts(String studentId) {
        int[] counts = new int[]{0, 0, 0};

        String getUserIdSql = "SELECT ID FROM USERS WHERE USERNAME = ? OR ID IN (SELECT ID FROM STUDENT WHERE STUDENTID = ?)";
        String countsSql =
                            "SELECT " +
                            "SUM(CASE WHEN APPOINTMENTSTATUS IN ('Pending', 'booked') AND s.STARTTIME >= CURRENT_TIMESTAMP THEN 1 ELSE 0 END) AS UPCOMING, " +
                            "SUM(CASE WHEN APPOINTMENTSTATUS = 'complete' THEN 1 ELSE 0 END) AS COMPLETED, " +
                            "SUM(CASE WHEN APPOINTMENTSTATUS = 'Pending' THEN 1 ELSE 0 END) AS PENDING " +
                            "FROM APPOINTMENT a " +
                            "JOIN SESSION s ON a.SESSIONID = s.SESSIONID " +
                            "WHERE a.STUDENTID = ?";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps1 = conn.prepareStatement(getUserIdSql)) {

            ps1.setString(1, studentId);
            ps1.setString(2, studentId);
            
            try (ResultSet rs1 = ps1.executeQuery()) {
                if (rs1.next()) {
                    int userId = rs1.getInt("ID");
                    
                    try (PreparedStatement ps2 = conn.prepareStatement(countsSql)) {
                        ps2.setInt(1, userId);
                        
                        try (ResultSet rs2 = ps2.executeQuery()) {
                            if (rs2.next()) {
                                counts[0] = rs2.getInt("UPCOMING");
                                counts[1] = rs2.getInt("COMPLETED");
                                counts[2] = rs2.getInt("PENDING");
                            }
                        }
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return counts;
    }

    
    public List<RecentSession> getRecentSessions(String studentId, int limit) {
        List<RecentSession> list = new ArrayList<>();

        
        String getUserIdSql = "SELECT ID FROM USERS WHERE USERNAME = ? OR ID IN (SELECT ID FROM STUDENT WHERE STUDENTID = ?)";
        
        String sql =
        "SELECT a.BOOKEDDATE, a.DESCRIPTION, a.APPOINTMENTSTATUS, " +
        "       s.STARTTIME, " +  
        "       s.ENDTIME, " +    
        "       c.COUNSELORID, c.ROOMNO " +
        "FROM APPOINTMENT a " +
        "LEFT JOIN SESSION s ON a.SESSIONID = s.SESSIONID " +
        "LEFT JOIN COUNSELOR c ON a.COUNSELORID = c.ID " +
        "WHERE a.STUDENTID = ? " +
        "AND UPPER(a.APPOINTMENTSTATUS) = 'COMPLETE' " + 
        "ORDER BY a.BOOKEDDATE DESC";


        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps1 = conn.prepareStatement(getUserIdSql)) {

            ps1.setString(1, studentId);
            ps1.setString(2, studentId);

            try (ResultSet rs1 = ps1.executeQuery()) {
                if (rs1.next()) {
                    int userId = rs1.getInt("ID");
                    
                    try (PreparedStatement ps2 = conn.prepareStatement(sql)) {
                        ps2.setInt(1, userId);
                        
                        try (ResultSet rs2 = ps2.executeQuery()) {
                            int count = 0;
                            while (rs2.next() && count < limit) {
                            RecentSession r = new RecentSession();

                            Timestamp ts = rs2.getTimestamp("BOOKEDDATE");
                            if (ts != null) {
                                r.setBookedDate(new java.util.Date(ts.getTime()));
                            }

                            r.setDescription(rs2.getString("DESCRIPTION"));
                            r.setStatus(rs2.getString("APPOINTMENTSTATUS"));

                            SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");

                            Timestamp startTs = rs2.getTimestamp("STARTTIME");
                            if (startTs != null) {
                                r.setStartTime(timeFormat.format(startTs));
                            } else {
                                r.setStartTime("-");
                            }

                            Timestamp endTs = rs2.getTimestamp("ENDTIME");
                            if (endTs != null) {
                                r.setEndTime(timeFormat.format(endTs));
                            } else {
                                r.setEndTime("-");
                            }

                            r.setCounselorId(rs2.getString("COUNSELORID"));
                            r.setRoomNo(rs2.getString("ROOMNO"));

                            list.add(r);
                            count++;

                            }
                        }
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}