package com.counselling.model;

import java.io.Serializable;

public class User implements Serializable {
    private int ID;
    private String userName;
    private String fullName;
    private String userEmail;
    private String userPassword;
    private String userRole; 
    private String userPhoneNum;
    
    public User() {}
    
    public User(int ID, String userName, String fullName, String userEmail, 
                String userPassword, String userRole, String userPhoneNum) {
        this.ID = ID;
        this.userName = userName;
        this.fullName = fullName;
        this.userEmail = userEmail;
        this.userPassword = userPassword;
        this.userRole = userRole;
        this.userPhoneNum = userPhoneNum;
    }
    
    public int getID() { return ID; }
    public void setID(int ID) { this.ID = ID; }
    
    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
    
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    
    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }
    
    public String getUserPassword() { return userPassword; }
    public void setUserPassword(String userPassword) { this.userPassword = userPassword; }
    
    public String getUserRole() { return userRole; }
    public void setUserRole(String userRole) { this.userRole = userRole; }
    
    public String getUserPhoneNum() { return userPhoneNum; }
    public void setUserPhoneNum(String userPhoneNum) { this.userPhoneNum = userPhoneNum; }
}