package com.counselling.model;

public class Counselor extends User {
    private String counselorID;
    private String roomNo;
    
    // Constructors
    public Counselor() {
        super();
    }
    
    public Counselor(int ID, String userName, String fullName, String userEmail,
                    String userPassword, String userPhoneNum, 
                    String counselorID, String roomNo) {
        super(ID, userName, fullName, userEmail, userPassword, "counselor", userPhoneNum);
        this.counselorID = counselorID;
        this.roomNo = roomNo;
    }
    
    public String getCounselorID() { return counselorID; }
    public void setCounselorID(String counselorID) { this.counselorID = counselorID; }
    
    public String getRoomNo() { return roomNo; }
    public void setRoomNo(String roomNo) { this.roomNo = roomNo; }
    
    // TAMBAH ni - untuk fix error setId(String)
    public void setId(String id) {
        try {
            this.setID(Integer.parseInt(id));
        } catch (NumberFormatException e) {
            System.err.println("Invalid ID format: " + id);
        }
    }
    
    public int getCounselorIdAsInt() {
        try {
            return Integer.parseInt(counselorID);
        } catch (NumberFormatException e) {
            if (counselorID != null && counselorID.matches(".*\\d+.*")) {
                String numbers = counselorID.replaceAll("\\D+", "");
                try {
                    return Integer.parseInt(numbers);
                } catch (NumberFormatException ex) {
                    return 0;
                }
            }
            return 0;
        }
    }
    
    public int getCounselorIDAsInt() {
        return getCounselorIdAsInt();
    }
}