package com.counselling.model;

import java.io.Serializable;

// Serializable diperlukan supaya objek ini boleh disimpan dalam Session
public class User implements Serializable {
    private int id;
    private String userName;
    private String fullName;
    private String userEmail;
    private String userPassword;
    private String userRole; // 'S' untuk Student, 'C' untuk Counselor
    private String userPhoneNum;

    public User() {}

    //Getter and Setter
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

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