package com.counselling.dao;

import com.counselling.model.RecentSession;
import com.counselling.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StudentDashboardDAO {

    // counts[0]=upcoming, counts[1]=completed, counts[2]=pending
    public int[] getCounts(String studentId) {
        int[] counts = new int[]{0, 0, 0};

        String sql =
            "SELECT " +
            "SUM(CASE WHEN APPOINTMENTSTATUS = 'Upcoming' OR APPOINTMENTSTATUS = 'Pending' THEN 1 ELSE 0 END) AS UPCOMING, " +
            "SUM(CASE WHEN APPOINTMENTSTATUS = 'completed' THEN 1 ELSE 0 END) AS COMPLETED, " +
            "SUM(CASE WHEN APPOINTMENTSTATUS = 'Pending' THEN 1 ELSE 0 END) AS Pending " +
            "FROM APPOINTMENT WHERE STUDENTID = ?";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    counts[0] = rs.getInt("UPCOMING");
                    counts[1] = rs.getInt("completed");
                    counts[2] = rs.getInt("Pending");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return counts;
    }

    public List<RecentSession> getRecentSessions(String studentId, int limit) {
    List<RecentSession> list = new ArrayList<>();

    String sql =
        "SELECT a.BOOKEDDATE, a.DESCRIPTION, a.APPOINTMENTSTATUS, " +
        "       s.STARTTIME, s.ENDTIME, c.COUNSELORID, c.ROOMNO " +
        "FROM APPOINTMENT a " +
        "LEFT JOIN SESSION s ON a.SESSIONID = s.SESSIONID " +
        "LEFT JOIN COUNSELOR c ON a.COUNSELORID = c.COUNSELORID " +
        "WHERE a.STUDENTID = ? " +
        "AND TRUNC(a.BOOKEDDATE) = TRUNC(SYSDATE) " +
        "ORDER BY a.BOOKEDDATE ASC";

    try (Connection conn = DBConnection.createConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setString(1, studentId);

        try (ResultSet rs = ps.executeQuery()) {
            int count = 0;
            while (rs.next() && count < limit) {
                RecentSession r = new RecentSession();

                Timestamp ts = rs.getTimestamp("BOOKEDDATE");
                if (ts != null) r.setBookedDate(new java.util.Date(ts.getTime()));

                r.setDescription(rs.getString("DESCRIPTION"));
                r.setStatus(rs.getString("APPOINTMENTSTATUS"));

                r.setStartTime(rs.getString("STARTTIME"));
                r.setEndTime(rs.getString("ENDTIME"));

                r.setCounselorId(rs.getString("COUNSELORID"));
                r.setRoomNo(rs.getString("ROOMNO"));

                list.add(r);
                count++;
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    return list;
}

}
