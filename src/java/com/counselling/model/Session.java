package com.counselling.model;

<<<<<<< HEAD
import java.io.Serializable;

public class Session implements Serializable {
    private int sessionId;
    private String startTime;
    private String endTime;
    private String sessionStatus; // 'Available' or 'Booked'
    private String counselorId;
    private String sessionDate; // Tarikh sesi tersebut

    public Session() {}

    // Getters and Setters
    public int getSessionId() { return sessionId; }
    public void setSessionId(int sessionId) { this.sessionId = sessionId; }
    public String getStartTime() { return startTime; }
    public void setStartTime(String startTime) { this.startTime = startTime; }
    public String getEndTime() { return endTime; }
    public void setEndTime(String endTime) { this.endTime = endTime; }
    public String getSessionStatus() { return sessionStatus; }
    public void setSessionStatus(String sessionStatus) { this.sessionStatus = sessionStatus; }
    public String getCounselorId() { return counselorId; }
    public void setCounselorId(String counselorId) { this.counselorId = counselorId; }
    public String getSessionDate() { return sessionDate; }
    public void setSessionDate(String sessionDate) { this.sessionDate = sessionDate; }

    public void setSessionID(int aInt) {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    public String getCounselorID() {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
=======
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
>>>>>>> cfe4021dbeaf489fd67b19fec1c67eb660810512
    }
}