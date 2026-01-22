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
    
    public Counselor(int ID, String userName, String fullName, String userEmail,
                    String userPassword, String userPhoneNum, 
                    String counselorID, String roomNo) {
        super(ID, userName, fullName, userEmail, userPassword, "counselor", userPhoneNum);
    public Counselor(String userID, String userName, String fullName, String userEmail,
                    String userPassword, String userPhoneNum, 
                    String counselorID, String roomNo) {
        super(userID, userName, fullName, userEmail, userPassword, "counselor", userPhoneNum);
        this.counselorID = counselorID;
        this.roomNo = roomNo;
    }
    
    public String getCounselorID() { return counselorID; }
    public void setCounselorID(String counselorID) { this.counselorID = counselorID; }
    
    public String getRoomNo() { return roomNo; }
    public void setRoomNo(String roomNo) { this.roomNo = roomNo; }
    
    public int getCounselorIdAsInt() {
        try {
            return Integer.parseInt(counselorID);
        } catch (NumberFormatException e) {
            // Try to extract numbers from string if needed
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
