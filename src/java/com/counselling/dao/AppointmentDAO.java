package com.counselling.dao;

import com.counselling.model.Appointment;
import java.sql.*;

public class AppointmentDAO {
    private Connection connection;

    public AppointmentDAO(Connection connection) {
        this.connection = connection;
    }

    public boolean createAppointment(Appointment app) throws SQLException {
        // Query updated to match database columns: APPOINTMENTSTATUS, DESCRIPTION, BOOKEDDATE, STUDENTID, COUNSELORID, SESSIONID
        String sql = "INSERT INTO APP.APPOINTMENT (APPOINTMENTSTATUS, DESCRIPTION, BOOKEDDATE, STUDENTID, COUNSELORID, SESSIONID) VALUES (?, ?, CURRENT_DATE, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, "Pending"); // Default status
            ps.setString(2, app.getDescription());
            ps.setInt(3, app.getStudentInternalID()); // Internal numeric ID
            ps.setInt(4, app.getCounselorInternalID()); // Counselor's internal ID
            ps.setInt(5, app.getSessionID());
            return ps.executeUpdate() > 0;
        }
    }
}