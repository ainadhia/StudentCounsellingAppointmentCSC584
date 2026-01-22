package com.counselling.dao;

import com.counselling.model.Appointment;
import com.counselling.util.DBConnection;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AppointmentDAO {
    
    public List<Appointment> getAllAppointmentsByCounselor(int counselorID) throws SQLException {
        List<Appointment> appointments = new ArrayList<>();
        String sql = "SELECT * FROM APPOINTMENT WHERE COUNSELORID = ? ORDER BY BOOKEDDATE DESC";
        
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, counselorID);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                appointments.add(mapResultSetToAppointment(rs));
            }
        }
        return appointments;
    }
    
    public Appointment getAppointmentById(int appointmentID) throws SQLException {
        String sql = "SELECT * FROM APPOINTMENT WHERE ID = ?";
        
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, appointmentID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToAppointment(rs);
            }
        }
        return null;
    }
    
    public List<Appointment> getAppointmentsByStatus(int counselorID, String status) throws SQLException {
        List<Appointment> appointments = new ArrayList<>();
        String sql = "SELECT * FROM APPOINTMENT WHERE COUNSELORID = ? AND APPOINTMENTSTATUS = ? ORDER BY BOOKEDDATE DESC";
        
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, counselorID);
            ps.setString(2, status);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                appointments.add(mapResultSetToAppointment(rs));
            }
        }
        return appointments;
    }
    
    public boolean updateAppointment(Appointment appointment) throws SQLException {
        String sql = "UPDATE APPOINTMENT SET APPOINTMENTSTATUS = ?, DESCRIPTION = ?, " +
                    "BOOKEDDATE = ?, SESSIONID = ? WHERE ID = ?";
        
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, appointment.getAppointmentStatus());
            ps.setString(2, appointment.getDescription());
            ps.setDate(3, (Date) appointment.getBookedDate());
            ps.setInt(4, appointment.getSessionID());
            ps.setInt(5, appointment.getID());
            
            return ps.executeUpdate() > 0;
        }
    }
    
    public boolean updateAppointmentStatus(int appointmentID, String status) throws SQLException {
        String sql = "UPDATE APPOINTMENT SET APPOINTMENTSTATUS = ? WHERE ID = ?";
        
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setInt(2, appointmentID);
            
            return ps.executeUpdate() > 0;
        }
    }
    
    public int getTodayBookedCount(int counselorID) throws SQLException {
        String sql = "SELECT COUNT(*) FROM APPOINTMENT WHERE COUNSELORID = ? " +
                    "AND APPOINTMENTSTATUS = 'Booked' AND BOOKEDDATE = CURRENT_DATE";
        
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, counselorID);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }
    
    public int getThisWeekAppointmentCount(int counselorID) throws SQLException {
        String sql = "SELECT COUNT(*) FROM APPOINTMENT WHERE COUNSELORID = ? " +
                      "AND APPOINTMENTSTATUS = 'Pending' " +
                      "AND BOOKEDDATE >= CURRENT_DATE AND BOOKEDDATE < CURRENT_DATE + 5";
        
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, counselorID);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }
    
    public int getTodayPendingCount(int counselorID) throws SQLException {
        String sql = "SELECT COUNT(*) FROM APPOINTMENT WHERE COUNSELORID = ? " +
                    "AND APPOINTMENTSTATUS = 'Pending' AND BOOKEDDATE = CURRENT_DATE";
        
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, counselorID);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }
    
    public int getThisWeekCompletedCount(int counselorID) throws SQLException {
        String sql = "SELECT COUNT(*) FROM APPOINTMENT WHERE COUNSELORID = ? " +
                    "AND APPOINTMENTSTATUS = 'Complete' " +
                    "AND BOOKEDDATE >= CURRENT_DATE AND BOOKEDDATE < CURRENT_DATE + 7";
        
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, counselorID);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }
    
    public int getUniqueStudentCount(int counselorID) throws SQLException {
        String sql = "SELECT COUNT(DISTINCT STUDENTID) FROM APPOINTMENT WHERE COUNSELORID = ?";
        
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, counselorID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
    
    public int getUpcomingAppointmentCount(int counselorID) throws SQLException {
        String sql = "SELECT COUNT(*) FROM APPOINTMENT WHERE COUNSELORID = ? " +
                    "AND APPOINTMENTSTATUS = 'booked' AND BOOKEDDATE >= CURRENT_DATE";
        
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, counselorID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
    
    public int getCompletedSessionCount(int counselorID) throws SQLException {
        String sql = "SELECT COUNT(*) FROM APPOINTMENT WHERE COUNSELORID = ? " +
                    "AND APPOINTMENTSTATUS = 'complete'";
        
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, counselorID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
    
    public int getPendingFollowupCount(int counselorID) throws SQLException {
        String sql = "SELECT COUNT(*) FROM APPOINTMENT WHERE COUNSELORID = ? " +
                    "AND APPOINTMENTSTATUS = 'Pending'";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, counselorID);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
    
    public List<Map<String, Object>> getRecentSessions(int counselorID) throws SQLException {
        List<Map<String, Object>> sessions = new ArrayList<>();

        String sql = "SELECT a.ID, a.STUDENTID, a.BOOKEDDATE, a.APPOINTMENTSTATUS, " +
                    "s.SESSIONID, s.STARTTIME, s.ENDTIME, s.SESSIONSTATUS, " +
                    "u.FULLNAME as STUDENTNAME " +
                    "FROM APPOINTMENT a " +
                    "INNER JOIN SESSION s ON a.SESSIONID = s.SESSIONID " +
                    "LEFT JOIN USERS u ON a.STUDENTID = u.ID " +  
                    "WHERE a.COUNSELORID = ? " +
                    "AND a.SESSIONID IS NOT NULL " +
                    "AND a.BOOKEDDATE = CURRENT_DATE " +
                    "AND s.STARTTIME IS NOT NULL " +
                    "ORDER BY s.STARTTIME ASC";

        System.out.println("getRecentSessions SQL: " + sql);
        System.out.println("CounselorID: " + counselorID);

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, counselorID);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, Object> session = new HashMap<>();
                session.put("ID", rs.getInt("ID"));
                session.put("sessionID", rs.getInt("SESSIONID"));
                session.put("studentID", rs.getInt("STUDENTID"));
                session.put("studentName", rs.getString("STUDENTNAME"));  // ✅ Dari JOIN
                session.put("date", rs.getDate("BOOKEDDATE"));
                session.put("appointmentStatus", rs.getString("APPOINTMENTSTATUS"));
                session.put("sessionStatus", rs.getString("SESSIONSTATUS"));

                // Format waktu
                Time startTime = rs.getTime("STARTTIME");
                Time endTime = rs.getTime("ENDTIME");

                if (startTime != null && endTime != null) {
                    SimpleDateFormat sdf = new SimpleDateFormat("h:mm a");
                    session.put("startTime", sdf.format(startTime));
                    session.put("endTime", sdf.format(endTime));
                    session.put("rawStartTime", startTime.toString());
                    session.put("rawEndTime", endTime.toString());
                }

                System.out.println(" Session found: ID=" + rs.getInt("ID") + 
                                 ", Student=" + rs.getString("STUDENTNAME"));

                sessions.add(session);
            }
        }
        
        System.out.println("Total sessions returned: " + sessions.size());
        return sessions;
    }
    
    public List<Map<String, Object>> getUpcomingAppointments(int counselorID, int limit) throws SQLException {
        List<Map<String, Object>> appointments = new ArrayList<>();
        
        String sql = "SELECT a.ID, a.STUDENTID, a.BOOKEDDATE, a.APPOINTMENTSTATUS, a.DESCRIPTION, " +
                    "u.FULLNAME as STUDENTNAME " +
                    "FROM APPOINTMENT a " +
                    "LEFT JOIN USERS u ON a.STUDENTID = u.ID " +  
                    "WHERE a.COUNSELORID = ? " +
                    "AND a.APPOINTMENTSTATUS IN ('Booked', 'Pending') " +
                    "AND a.BOOKEDDATE >= CURRENT_DATE " +
                    "ORDER BY a.BOOKEDDATE ASC " +
                    "FETCH FIRST ? ROWS ONLY";
        
        System.out.println("getUpcomingAppointments SQL: " + sql);
        
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, counselorID);
            ps.setInt(2, limit);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> appointment = new HashMap<>();
                appointment.put("ID", rs.getInt("ID"));
                appointment.put("STUDENTID", rs.getInt("STUDENTID"));
                appointment.put("STUDENTNAME", rs.getString("STUDENTNAME"));  
                appointment.put("BOOKEDDATE", rs.getDate("BOOKEDDATE"));
                appointment.put("APPOINTMENTSTATUS", rs.getString("APPOINTMENTSTATUS"));
                appointment.put("DESCRIPTION", rs.getString("DESCRIPTION"));
                
                System.out.println("Upcoming: ID=" + rs.getInt("ID") + 
                                 ", Student=" + rs.getString("STUDENTNAME"));
                
                appointments.add(appointment);
            }
        }
        
        System.out.println("Total upcoming appointments: " + appointments.size());
        return appointments;
    }
    
    private Appointment mapResultSetToAppointment(ResultSet rs) throws SQLException {
        Appointment appointment = new Appointment();
        appointment.setID(rs.getInt("ID"));
        appointment.setAppointmentStatus(rs.getString("APPOINTMENTSTATUS"));
        appointment.setDescription(rs.getString("DESCRIPTION"));
        appointment.setBookedDate(rs.getDate("BOOKEDDATE"));
        appointment.setStudentID(rs.getInt("STUDENTID"));
        appointment.setCounselorID(rs.getInt("COUNSELORID"));
        appointment.setSessionID(rs.getInt("SESSIONID"));
        return appointment;
    }
}