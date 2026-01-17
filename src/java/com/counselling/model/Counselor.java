/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.counselling.model;

/**
 *
 * @author Aina
 */
public class Counselor extends User {
    private String counselorID;
    private String roomNo;
    
    // Constructors
    public Counselor() {
        super();
    }
    
    public Counselor(String userID, String userName, String fullName, String userEmail,
                    String userPassword, String userPhoneNum, 
                    String counselorID, String roomNo) {
        super(userID, userName, fullName, userEmail, userPassword, "counselor", userPhoneNum);
        this.counselorID = counselorID;
        this.roomNo = roomNo;
    }
    
    // Getters and Setters
    public String getCounselorID() { return counselorID; }
    public void setCounselorID(String counselorID) { this.counselorID = counselorID; }
    
    public String getRoomNo() { return roomNo; }
    public void setRoomNo(String roomNo) { this.roomNo = roomNo; }
}
