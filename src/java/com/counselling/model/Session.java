package com.counselling.model;

import java.sql.Timestamp;

public class Session {
    private int sessionID;
    private Timestamp startTime;      
    private Timestamp endTime;        
    private String sessionStatus;     
    private int counselorID;
    private int studentID;         
    
    // Constructors
    public Session() {}
    
    public Session(int sessionID, Timestamp startTime, Timestamp endTime, 
                   String sessionStatus, int counselorID) {
        this.sessionID = sessionID;
        this.startTime = startTime;
        this.endTime = endTime;
        this.sessionStatus = sessionStatus;
        this.counselorID = counselorID;
    }
    
    // Getters and Setters
    public int getSessionID() {
        return sessionID;
    }
    
    public void setSessionID(int sessionID) {
        this.sessionID = sessionID;
    }
    
    public Timestamp getStartTime() {
        return startTime;
    }
    
    public void setStartTime(Timestamp startTime) {
        this.startTime = startTime;
    }
    
    public Timestamp getEndTime() {
        return endTime;
    }
    
    public void setEndTime(Timestamp endTime) {
        this.endTime = endTime;
    }
    
    public String getSessionStatus() {
        return sessionStatus;
    }
    
    public void setSessionStatus(String sessionStatus) {
        this.sessionStatus = sessionStatus;
    }
    
    public int getCounselorID() {
        return counselorID;
    }
    
    public void setCounselorID(int counselorID) {
        this.counselorID = counselorID;
    }
    
    public int getStudentID() {
        return studentID;
    }
    
    public void setStudentID(int studentID) {
        this.studentID = studentID;
    }
    
    public String getFormattedStartTime() {
        if (startTime == null) return "";
        return startTime.toString().substring(11, 16);
    }
    
    public String getFormattedEndTime() {
        if (endTime == null) return "";
        return endTime.toString().substring(11, 16);
    }
    
    public String getFormattedDate() {
        if (startTime == null) return "";
        return startTime.toString().substring(0, 10);
    }
    
    public String getDuration() {
        if (startTime == null || endTime == null) return "";
        
        long diff = endTime.getTime() - startTime.getTime();
        long hours = diff / (60 * 60 * 1000);
        long minutes = (diff % (60 * 60 * 1000)) / (60 * 1000);
        
        if (hours > 0 && minutes > 0) {
            return hours + " hour" + (hours > 1 ? "s" : "") + " and " + 
                   minutes + " minute" + (minutes > 1 ? "s" : "");
        } else if (hours > 0) {
            return hours + " hour" + (hours > 1 ? "s" : "");
        } else {
            return minutes + " minute" + (minutes > 1 ? "s" : "");
        }
    }
    
    @Override
    public String toString() {
        return "Session [sessionID=" + sessionID +
               ", startTime=" + startTime + ", endTime=" + endTime + 
               ", sessionStatus=" + sessionStatus + ", counselorID=" + counselorID + 
               ", studentID=" + studentID + "]";
    }
}