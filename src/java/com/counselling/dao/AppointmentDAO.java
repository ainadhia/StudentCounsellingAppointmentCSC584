package com.counselling.dao;

import com.counselling.model.Appointment;
import com.counselling.model.AppointmentView;
import com.counselling.model.Session;
import com.counselling.model.AppointmentStats;
import com.counselling.util.DBConnection;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AppointmentDAO {
    private Connection connection;

    public AppointmentDAO(Connection connection) {
        this.connection = connection;
    }

    // =================== STUDENT-RELATED METHODS ===================

    // History list with optional search (counselor name, status, description)
    public List<AppointmentView> getAllAppointmentsForStudent(int studentInternalID, String search) throws SQLException {
        List<AppointmentView> list = new ArrayList<>();
        boolean hasSearch = search != null && !search.trim().isEmpty();

        String sql = "SELECT a.SESSIONID, a.APPOINTMENTSTATUS, a.DESCRIPTION, " +
                "s.STARTTIME, s.ENDTIME, u.FULLNAME AS COUNSELORNAME " +
                "FROM APP.APPOINTMENT a " +
                "JOIN APP.SESSION s ON a.SESSIONID = s.SESSIONID " +
                "LEFT JOIN APP.USERS u ON a.COUNSELORID = u.ID " +
                "WHERE a.STUDENTID = ? " +
                (hasSearch ? "AND (LOWER(u.FULLNAME) LIKE ? OR LOWER(a.APPOINTMENTSTATUS) LIKE ? OR LOWER(a.DESCRIPTION) LIKE ?) " : "") +
                "ORDER BY s.STARTTIME DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, studentInternalID);
            if (hasSearch) {
                String like = "%" + search.toLowerCase() + "%";
                ps.setString(2, like);
                ps.setString(3, like);
                ps.setString(4, like);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                AppointmentView view = new AppointmentView();
                int sessionId = rs.getInt("SESSIONID");
                view.setAppointmentID(sessionId);
                view.setSessionID(sessionId);
                view.setStatus(rs.getString("APPOINTMENTSTATUS"));
                view.setDescription(rs.getString("DESCRIPTION"));
                view.setStartTime(rs.getTimestamp("STARTTIME"));
                view.setEndTime(rs.getTimestamp("ENDTIME"));
                view.setCounselorName(rs.getString("COUNSELORNAME"));
                list.add(view);
            }
        }
        return list;
    }

    // Stats cards for student
    public AppointmentStats getAppointmentStatsForStudent(int studentInternalID) throws SQLException {
        AppointmentStats stats = new AppointmentStats();
        String sql = "SELECT " +
                "COUNT(*) AS total, " +
                "SUM(CASE WHEN a.APPOINTMENTSTATUS = 'Completed' THEN 1 ELSE 0 END) AS completed, " +
                "SUM(CASE WHEN a.APPOINTMENTSTATUS <> 'Cancelled' AND s.STARTTIME >= CURRENT_TIMESTAMP THEN 1 ELSE 0 END) AS upcoming, " +
                "SUM(CASE WHEN a.APPOINTMENTSTATUS = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled " +
                "FROM APP.APPOINTMENT a " +
                "JOIN APP.SESSION s ON a.SESSIONID = s.SESSIONID " +
                "WHERE a.STUDENTID = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, studentInternalID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                stats.setTotal(rs.getInt("total"));
                stats.setCompleted(rs.getInt("completed"));
                stats.setUpcoming(rs.getInt("upcoming"));
                stats.setCancelled(rs.getInt("cancelled"));
            }
        }
        return stats;
    }

    // Get upcoming appointments for a student (future sessions, excluding cancelled)
    public List<AppointmentView> getUpcomingAppointmentsForStudent(int studentInternalID) throws SQLException {
        List<AppointmentView> list = new ArrayList<>();

        String sql = "SELECT a.SESSIONID, a.APPOINTMENTSTATUS, a.DESCRIPTION, " +
            "s.STARTTIME, s.ENDTIME, u.FULLNAME AS COUNSELORNAME " +
                "FROM APP.APPOINTMENT a " +
                "JOIN APP.SESSION s ON a.SESSIONID = s.SESSIONID " +
                "LEFT JOIN APP.USERS u ON a.COUNSELORID = u.ID " +
                "WHERE a.STUDENTID = ? AND a.APPOINTMENTSTATUS <> 'Cancelled' " +
                "AND s.STARTTIME >= CURRENT_TIMESTAMP " +
                "ORDER BY s.STARTTIME";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, studentInternalID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                AppointmentView view = new AppointmentView();
                int sessionId = rs.getInt("SESSIONID");
                view.setAppointmentID(sessionId);
                view.setSessionID(sessionId);
                view.setStatus(rs.getString("APPOINTMENTSTATUS"));
                view.setDescription(rs.getString("DESCRIPTION"));
                view.setStartTime(rs.getTimestamp("STARTTIME"));
                view.setEndTime(rs.getTimestamp("ENDTIME"));
                view.setCounselorName(rs.getString("COUNSELORNAME"));
                list.add(view);
            }
        }
        return list;
    }

    // Cancel an appointment (and free the session)
    public boolean cancelAppointment(int appointmentID, int studentInternalID, int sessionID, SessionDAO sessionDAO) throws SQLException {
        connection.setAutoCommit(false);
        try (PreparedStatement ps = connection.prepareStatement(
                "UPDATE APP.APPOINTMENT SET APPOINTMENTSTATUS='Cancelled' WHERE SESSIONID=? AND STUDENTID=?")) {
            ps.setInt(1, appointmentID);
            ps.setInt(2, studentInternalID);
            int updated = ps.executeUpdate();
            if (updated > 0) {
                sessionDAO.updateSessionStatus(sessionID, "available");
                connection.commit();
                return true;
            }
            connection.rollback();
            return false;
        } catch (SQLException e) {
            connection.rollback();
            throw e;
        } finally {
            connection.setAutoCommit(true);
        }
    }

    // Hard delete an appointment (identified by sessionID + student) and free the session
    public boolean deleteAppointment(int sessionID, int studentInternalID, SessionDAO sessionDAO) throws SQLException {
        connection.setAutoCommit(false);
        try (PreparedStatement ps = connection.prepareStatement(
                "DELETE FROM APP.APPOINTMENT WHERE SESSIONID=? AND STUDENTID=?")) {
            ps.setInt(1, sessionID);
            ps.setInt(2, studentInternalID);
            int deleted = ps.executeUpdate();
            if (deleted > 0) {
                sessionDAO.updateSessionStatus(sessionID, "available");
                connection.commit();
                return true;
            }
            connection.rollback();
            return false;
        } catch (SQLException e) {
            connection.rollback();
            throw e;
        } finally {
            connection.setAutoCommit(true);
        }
    }

    // Reschedule: move appointment to a new session and update session availability
    public boolean rescheduleAppointment(int appointmentID, int studentInternalID, int oldSessionID, int newSessionID, SessionDAO sessionDAO) throws SQLException {
        connection.setAutoCommit(false);
        try {
            // Ensure new session is available
            Session newSession = sessionDAO.getSessionById(newSessionID);
            if (newSession == null || newSession.getSessionStatus() == null ||
                !"available".equalsIgnoreCase(newSession.getSessionStatus())) {
                connection.rollback();
                return false;
            }

            // Update appointment (identified by old session ID + student)
            try (PreparedStatement ps = connection.prepareStatement(
                    "UPDATE APP.APPOINTMENT SET SESSIONID=?, APPOINTMENTSTATUS='Pending' WHERE SESSIONID=? AND STUDENTID=?")) {
                ps.setInt(1, newSessionID);
                ps.setInt(2, oldSessionID);
                ps.setInt(3, studentInternalID);
                int updated = ps.executeUpdate();
                if (updated == 0) {
                    connection.rollback();
                    return false;
                }
            }

            // Mark sessions: new unavailable, old available
            sessionDAO.updateSessionStatus(newSessionID, "unavailable");
            sessionDAO.updateSessionStatus(oldSessionID, "available");

            connection.commit();
            return true;
        } catch (SQLException e) {
            connection.rollback();
            throw e;
        } finally {
            connection.setAutoCommit(true);
        }
    }

    // =================== COUNSELOR-RELATED METHODS ===================

    public List<Appointment> getAllAppointmentsByCounselor(int counselorID) throws SQLException {
        List<Appointment> appointments = new ArrayList<>();
        String sql = "SELECT * FROM APPOINTMENT WHERE COUNSELORID = ? ORDER BY BOOKEDDATE DESC";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
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
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
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
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, counselorID);
            ps.setString(2, status);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                appointments.add(mapResultSetToAppointment(rs));
            }
        }
        return appointments;
    }
    
    // =================== DUPLICATE METHODS (RENAMED) ===================

    // Renamed to createAppointment2 to avoid conflict with student version
    public boolean createAppointment2(Appointment app) throws SQLException {
        String sql = "INSERT INTO APPOINTMENT (APPOINTMENTSTATUS, DESCRIPTION, BOOKEDDATE, STUDENTID, COUNSELORID, SESSIONID) " +
                     "VALUES (?, ?, CURRENT_DATE, ?, ?, ?)";
        
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, "Pending");
            ps.setString(2, app.getDescription());
            ps.setInt(3, app.getStudentID());
            ps.setInt(4, app.getCounselorID());
            ps.setInt(5, app.getSessionID());
            
            int result = ps.executeUpdate();
            
            if (result > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    app.setID(rs.getInt(1));
                }
                return true;
            }
            return false;
        }
    }
    
    // Student version - keep original name
    public boolean createAppointment(Appointment app) throws SQLException {
        String sql = "INSERT INTO APP.APPOINTMENT (APPOINTMENTSTATUS, DESCRIPTION, BOOKEDDATE, STUDENTID, COUNSELORID, SESSIONID) VALUES (?, ?, CURRENT_DATE, ?, ?, ?)";
        
        System.out.println("DEBUG AppointmentDAO: Creating appointment");
        System.out.println("DEBUG AppointmentDAO: studentInternalID=" + app.getStudentInternalID());
        System.out.println("DEBUG AppointmentDAO: counselorInternalID=" + app.getCounselorInternalID());
        System.out.println("DEBUG AppointmentDAO: sessionID=" + app.getSessionID());
        System.out.println("DEBUG AppointmentDAO: description=" + app.getDescription());
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, "Pending");
            ps.setString(2, app.getDescription());
            ps.setInt(3, app.getStudentInternalID());
            ps.setInt(4, app.getCounselorInternalID());
            ps.setInt(5, app.getSessionID());
            
            System.out.println("DEBUG AppointmentDAO: Executing insert...");
            int result = ps.executeUpdate();
            System.out.println("DEBUG AppointmentDAO: Insert result=" + result);
            
            return result > 0;
        } catch (SQLException e) {
            System.out.println("DEBUG AppointmentDAO: SQL Error - " + e.getMessage());
            System.out.println("DEBUG AppointmentDAO: Error Code - " + e.getErrorCode());
            throw e;
        }
    }
    
    public boolean updateAppointment(Appointment appointment) throws SQLException {
        String sql = "UPDATE APPOINTMENT SET APPOINTMENTSTATUS = ?, DESCRIPTION = ?, " +
                    "BOOKEDDATE = ?, SESSIONID = ? WHERE ID = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            
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
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setInt(2, appointmentID);
            
            return ps.executeUpdate() > 0;
        }
    }
    
    // =================== STATISTICS METHODS ===================

    public int getTodayBookedCount(int counselorID) throws SQLException {
        String sql = "SELECT COUNT(*) FROM APPOINTMENT WHERE COUNSELORID = ? " +
                    "AND APPOINTMENTSTATUS = 'Pending' AND BOOKEDDATE = CURRENT_DATE";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, counselorID);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }
    
    public int getThisWeekAppointmentCount(int counselorID) throws SQLException {
        String sql = "SELECT COUNT(*) FROM APPOINTMENT WHERE COUNSELORID = ? " +
                      "AND APPOINTMENTSTATUS = 'Pending' " +
                      "AND BOOKEDDATE >= CURRENT_DATE AND BOOKEDDATE < CURRENT_DATE + 5";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, counselorID);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }
    
    public int getTodayPendingCount(int counselorID) throws SQLException {
        String sql = "SELECT COUNT(*) FROM APPOINTMENT WHERE COUNSELORID = ? " +
                    "AND APPOINTMENTSTATUS = 'Pending' AND BOOKEDDATE = CURRENT_DATE";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, counselorID);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }
    
    public int getThisWeekCompletedCount(int counselorID) throws SQLException {
        String sql = "SELECT COUNT(*) FROM APPOINTMENT WHERE COUNSELORID = ? " +
                    "AND APPOINTMENTSTATUS = 'Complete' " +
                    "AND BOOKEDDATE >= CURRENT_DATE AND BOOKEDDATE < CURRENT_DATE + 7";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, counselorID);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }
    
    public int getUniqueStudentCount(int counselorID) throws SQLException {
        String sql = "SELECT COUNT(DISTINCT STUDENTID) FROM APPOINTMENT WHERE COUNSELORID = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
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
                    "AND APPOINTMENTSTATUS = 'Pending' AND BOOKEDDATE >= CURRENT_DATE";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
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
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
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

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, counselorID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
    
    // =================== DASHBOARD METHODS ===================

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

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, counselorID);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, Object> session = new HashMap<>();
                session.put("ID", rs.getInt("ID"));
                session.put("sessionID", rs.getInt("SESSIONID"));
                session.put("studentID", rs.getInt("STUDENTID"));
                session.put("studentName", rs.getString("STUDENTNAME"));
                session.put("date", rs.getDate("BOOKEDDATE"));
                session.put("appointmentStatus", rs.getString("APPOINTMENTSTATUS"));
                session.put("sessionStatus", rs.getString("SESSIONSTATUS"));

                Time startTime = rs.getTime("STARTTIME");
                Time endTime = rs.getTime("ENDTIME");

                if (startTime != null && endTime != null) {
                    SimpleDateFormat sdf = new SimpleDateFormat("h:mm a");
                    session.put("startTime", sdf.format(startTime));
                    session.put("endTime", sdf.format(endTime));
                    session.put("rawStartTime", startTime.toString());
                    session.put("rawEndTime", endTime.toString());
                }

                System.out.println("Session found: ID=" + rs.getInt("ID") + 
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
                    "AND a.APPOINTMENTSTATUS IN ('Pending', 'Pending') " +
                    "AND a.BOOKEDDATE >= CURRENT_DATE " +
                    "ORDER BY a.BOOKEDDATE ASC " +
                    "FETCH FIRST ? ROWS ONLY";
        
        System.out.println("getUpcomingAppointments SQL: " + sql);
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
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
    
    // =================== HELPER METHODS ===================

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