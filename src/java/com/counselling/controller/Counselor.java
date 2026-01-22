package com.counselling.model;

public class Counselor extends User {
    private String counselorID;
    private String roomNo;

    public Counselor() {
        super();
    }

    public String getCounselorID() { return counselorID; }
    public void setCounselorID(String counselorID) { this.counselorID = counselorID; }

    public String getRoomNo() { return roomNo; }
    public void setRoomNo(String roomNo) { this.roomNo = roomNo; }
}