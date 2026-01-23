package com.counselling.model;

import java.sql.Date;
import java.sql.Timestamp;

public class Appointment {
    // New naming (currently active)
    private int appointmentID;
    private int studentInternalID;
    private int counselorInternalID;
    private int sessionID;
    private Timestamp bookingDate;
    private String description;
    private String status;

    public Appointment() {}

    // NEW getters/setters
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

    // ========== COMPATIBILITY METHODS (untuk DAO lama) ==========
    // Ni untuk support old code yang still guna nama lama
    public int getID() { return appointmentID; }
    public void setID(int id) { this.appointmentID = id; }
    
    public String getAppointmentStatus() { return status; }
    public void setAppointmentStatus(String status) { this.status = status; }
    
    public Date getBookedDate() { 
        return bookingDate != null ? new Date(bookingDate.getTime()) : null; 
    }
    public void setBookedDate(Date date) { 
        this.bookingDate = date != null ? new Timestamp(date.getTime()) : null;
    }
    
    public int getStudentID() { return studentInternalID; }
    public void setStudentID(int studentID) { this.studentInternalID = studentID; }
    
    public int getCounselorID() { return counselorInternalID; }
    public void setCounselorID(int counselorID) { this.counselorInternalID = counselorID; }
    
    @Override
    public String toString() {
        return "Appointment{" +
                "appointmentID=" + appointmentID +
                ", status='" + status + '\'' +
                ", description='" + description + '\'' +
                ", bookingDate=" + bookingDate +
                ", studentInternalID=" + studentInternalID +
                ", counselorInternalID=" + counselorInternalID +
                ", sessionID=" + sessionID +
                '}';
    }
}