package com.counselling.model;

import java.util.Date;

public class RecentSession {
    private Date bookedDate;
    private String description;
    private String status;
    private String startTime;
    private String endTime;
    private String counselorId;
    private String roomNo;

    public Date getBookedDate() { return bookedDate; }
    public void setBookedDate(Date bookedDate) { this.bookedDate = bookedDate; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getStartTime() { return startTime; }
    public void setStartTime(String startTime) { this.startTime = startTime; }

    public String getEndTime() { return endTime; }
    public void setEndTime(String endTime) { this.endTime = endTime; }

    public String getCounselorId() { return counselorId; }
    public void setCounselorId(String counselorId) { this.counselorId = counselorId; }

    public String getRoomNo() { return roomNo; }
    public void setRoomNo(String roomNo) { this.roomNo = roomNo; }
}
