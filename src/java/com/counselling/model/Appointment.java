/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.counselling.model;

import java.util.Date;

/**
 *
 * @author Aina
 */
public class Appointment {
    private int ID;
    private String appointmentStatus;
    private String description;
    private Date bookedDate;
    private int studentID;
    private int counselorID;    
    private int sessionID;
    
    public Appointment() {
    }
    
    public Appointment(int ID, String appointmentStatus, String description, Date bookedDate, 
                      int studentID, int counselorID, int sessionID) {
        this.ID = ID;
        this.appointmentStatus = appointmentStatus;
        this.description = description;
        this.bookedDate = bookedDate;
        this.studentID = studentID;
        this.counselorID = counselorID;
        this.sessionID = sessionID;
    }
    
    // Getters and Setters
    public int getID() {
        return ID;
    }
    
    public void setID(int ID) {
        this.ID = ID;
    }
    
    public String getAppointmentStatus() {
        return appointmentStatus;
    }
    
    public void setAppointmentStatus(String appointmentStatus) {
        this.appointmentStatus = appointmentStatus;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public Date getBookedDate() {
        return bookedDate;
    }
    
    public void setBookedDate(Date bookedDate) {
        this.bookedDate = bookedDate;
    }
    
    public int getStudentID() {
        return studentID;
    }
    
    public void setStudentID(int studentID) {
        this.studentID = studentID;
    }
    
    public int getCounselorID() {
        return counselorID;
    }
    
    public void setCounselorID(int counselorID) {
        this.counselorID = counselorID;
    }
    
    public int getSessionID() {
        return sessionID;
    }
    
    public void setSessionID(int sessionID) {
        this.sessionID = sessionID;
    }
    
    @Override
    public String toString() {
        return "Appointment{" +
                "ID=" + ID +
                ", appointmentStatus='" + appointmentStatus + '\'' +
                ", description='" + description + '\'' +
                ", bookedDate=" + bookedDate +
                ", studentID=" + studentID +
                ", counselorID=" + counselorID +
                ", sessionID=" + sessionID +
                '}';
    }
}