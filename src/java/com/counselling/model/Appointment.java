package com.counselling.model;

import java.sql.Timestamp;

public class Appointment {
    private int appointmentID;
    private int studentInternalID;
    private int counselorInternalID;
    private int sessionID;
    private Timestamp bookingDate;
    private String description;
    private String status;

    public Appointment() {}

    public int getAppointmentID() { return appointmentID; }
    public void setAppointmentID(int appointmentID) { this.appointmentID = appointmentID; }

    public int getStudentInternalID() { return studentInternalID; }
    public void setStudentInternalID(int studentInternalID) { this.studentInternalID = studentInternalID; }

    public int getCounselorInternalID() { return counselorInternalID; }
    public void setCounselorInternalID(int counselorInternalID) { this.counselorInternalID = counselorInternalID; }

    public int getSessionID() { return sessionID; }
    public void setSessionID(int sessionID) { this.sessionID = sessionID; }

    public Timestamp getBookingDate() { return bookingDate; }
    public void setBookingDate(Timestamp bookingDate) { this.bookingDate = bookingDate; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
