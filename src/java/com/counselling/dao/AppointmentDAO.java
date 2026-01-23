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



    // =================== STUDENT-RELATED METHODS (FIXED) ===================



    /**

     * FIXED: Get all appointments for history with proper column mapping

     */

    public List<AppointmentView> getAllAppointmentsForStudent(int studentInternalID, String search) throws SQLException {

        List<AppointmentView> list = new ArrayList<>();

        boolean hasSearch = search != null && !search.trim().isEmpty();



        String sql = "SELECT a.ID as APPOINTMENT_ID, a.SESSIONID, a.APPOINTMENTSTATUS, a.DESCRIPTION, " +

                "s.STARTTIME, s.ENDTIME, u.FULLNAME AS COUNSELORNAME " +

                "FROM APPOINTMENT a " +

                "JOIN SESSION s ON a.SESSIONID = s.SESSIONID " +

                "LEFT JOIN USERS u ON a.COUNSELORID = u.ID " +

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

                view.setAppointmentID(rs.getInt("APPOINTMENT_ID"));

                view.setSessionID(rs.getInt("SESSIONID"));

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



    /**

     * FIXED: Get appointment stats with proper counting

     */

    public AppointmentStats getAppointmentStatsForStudent(int studentInternalID) throws SQLException {

        AppointmentStats stats = new AppointmentStats();

        String sql = "SELECT " +

                "COUNT(*) AS total, " +

                "SUM(CASE WHEN a.APPOINTMENTSTATUS = 'complete' THEN 1 ELSE 0 END) AS completed, " +

                "SUM(CASE WHEN a.APPOINTMENTSTATUS IN ('Pending', 'booked') AND s.STARTTIME >= CURRENT_TIMESTAMP THEN 1 ELSE 0 END) AS upcoming, " +

                "SUM(CASE WHEN a.APPOINTMENTSTATUS = 'cancelled' THEN 1 ELSE 0 END) AS cancelled " +

                "FROM APPOINTMENT a " +

                "JOIN SESSION s ON a.SESSIONID = s.SESSIONID " +

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



    /**

     * FIXED: Get upcoming appointments with proper ID mapping

     */

    public List<AppointmentView> getUpcomingAppointmentsForStudent(int studentInternalID) throws SQLException {

        List<AppointmentView> list = new ArrayList<>();



        String sql = "SELECT a.ID as APPOINTMENT_ID, a.SESSIONID, a.APPOINTMENTSTATUS, a.DESCRIPTION, " +

                "s.STARTTIME, s.ENDTIME, u.FULLNAME AS COUNSELORNAME " +

                "FROM APPOINTMENT a " +

                "JOIN SESSION s ON a.SESSIONID = s.SESSIONID " +

                "LEFT JOIN USERS u ON a.COUNSELORID = u.ID " +

                "WHERE a.STUDENTID = ? AND a.APPOINTMENTSTATUS NOT IN ('cancelled', 'complete') " +

                "AND s.STARTTIME >= CURRENT_TIMESTAMP " +

                "ORDER BY s.STARTTIME";



        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, studentInternalID);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                AppointmentView view = new AppointmentView();

                view.setAppointmentID(rs.getInt("APPOINTMENT_ID"));

                view.setSessionID(rs.getInt("SESSIONID"));

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



    /**

     * FIXED: Cancel appointment with proper ID handling

     */

    public boolean cancelAppointment(int appointmentID, int studentInternalID, int sessionID, SessionDAO sessionDAO) throws SQLException {

        connection.setAutoCommit(false);

        try (PreparedStatement ps = connection.prepareStatement(

                "UPDATE APPOINTMENT SET APPOINTMENTSTATUS='cancelled' WHERE ID=? AND STUDENTID=?")) {

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



    /**

     * FIXED: Delete appointment with proper ID handling

     */

    public boolean deleteAppointment(int sessionID, int studentInternalID, SessionDAO sessionDAO) throws SQLException {

        connection.setAutoCommit(false);

        try (PreparedStatement ps = connection.prepareStatement(

                "DELETE FROM APPOINTMENT WHERE SESSIONID=? AND STUDENTID=?")) {

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



    /**

     * FIXED: Reschedule with proper status updates

     */

    public boolean rescheduleAppointment(int appointmentID, int studentInternalID, int oldSessionID, int newSessionID, SessionDAO sessionDAO) throws SQLException {

        connection.setAutoCommit(false);

        try {

            Session newSession = sessionDAO.getSessionById(newSessionID);

            if (newSession == null || !"available".equalsIgnoreCase(newSession.getSessionStatus())) {

                connection.rollback();

                return false;

            }



            try (PreparedStatement ps = connection.prepareStatement(

                    "UPDATE APPOINTMENT SET SESSIONID=?, APPOINTMENTSTATUS='Pending' WHERE ID=? AND STUDENTID=?")) {

                ps.setInt(1, newSessionID);

                ps.setInt(2, appointmentID);

                ps.setInt(3, studentInternalID);

                int updated = ps.executeUpdate();

                if (updated == 0) {

                    connection.rollback();

                    return false;

                }

            }



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



    /**

     * FIXED: Create appointment with proper column names and transaction

     */

    public boolean createAppointment(Appointment app) throws SQLException {

        String sql = "INSERT INTO APPOINTMENT (APPOINTMENTSTATUS, DESCRIPTION, BOOKEDDATE, STUDENTID, COUNSELORID, SESSIONID) " +

                     "VALUES (?, ?, CURRENT_DATE, ?, ?, ?)";

       

        connection.setAutoCommit(false);

        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, "Pending");

            ps.setString(2, app.getDescription());

            ps.setInt(3, app.getStudentInternalID());

            ps.setInt(4, app.getCounselorInternalID());

            ps.setInt(5, app.getSessionID());

           

            int result = ps.executeUpdate();

           

            if (result > 0) {

                ResultSet rs = ps.getGeneratedKeys();

                if (rs.next()) {

                    app.setID(rs.getInt(1));

                }

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

                      "AND BOOKEDDATE >= CURRENT_DATE AND BOOKEDDATE < CURRENT_DATE + 7";

       

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

                    "AND APPOINTMENTSTATUS = 'complete' " +

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

            return rs.next() ? rs.getInt(1) : 0;

        }

    }

   

    public int getUpcomingAppointmentCount(int counselorID) throws SQLException {

        String sql = "SELECT COUNT(*) FROM APPOINTMENT WHERE COUNSELORID = ? " +

                    "AND APPOINTMENTSTATUS = 'Pending' AND BOOKEDDATE >= CURRENT_DATE";

       

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, counselorID);

            ResultSet rs = ps.executeQuery();

            return rs.next() ? rs.getInt(1) : 0;

        }

    }

   

    public int getCompletedSessionCount(int counselorID) throws SQLException {

        String sql = "SELECT COUNT(*) FROM APPOINTMENT WHERE COUNSELORID = ? " +

                    "AND APPOINTMENTSTATUS = 'complete'";

       

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, counselorID);

            ResultSet rs = ps.executeQuery();

            return rs.next() ? rs.getInt(1) : 0;

        }

    }

   

    public int getPendingFollowupCount(int counselorID) throws SQLException {

        String sql = "SELECT COUNT(*) FROM APPOINTMENT WHERE COUNSELORID = ? " +

                    "AND APPOINTMENTSTATUS = 'Pending'";



        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, counselorID);

            ResultSet rs = ps.executeQuery();

            return rs.next() ? rs.getInt(1) : 0;

        }

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



                sessions.add(session);

            }

        }

       

        return sessions;

    }

   

    public List<Map<String, Object>> getUpcomingAppointments(int counselorID, int limit) throws SQLException {

        List<Map<String, Object>> appointments = new ArrayList<>();

       

        String sql = "SELECT a.ID, a.STUDENTID, a.BOOKEDDATE, a.APPOINTMENTSTATUS, a.DESCRIPTION, " +

                    "u.FULLNAME as STUDENTNAME " +

                    "FROM APPOINTMENT a " +

                    "LEFT JOIN USERS u ON a.STUDENTID = u.ID " +

                    "WHERE a.COUNSELORID = ? " +

                    "AND a.APPOINTMENTSTATUS IN ('Pending', 'booked') " +

                    "AND a.BOOKEDDATE >= CURRENT_DATE " +

                    "ORDER BY a.BOOKEDDATE ASC " +

                    "FETCH FIRST ? ROWS ONLY";

       

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

               

                appointments.add(appointment);

            }

        }

       

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