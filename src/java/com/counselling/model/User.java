<<<<<<< HEAD
package com.counselling.model;

import java.io.Serializable;

// Serializable diperlukan supaya objek ini boleh disimpan dalam Session
public class User implements Serializable {
    private int id;
=======
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
public class User {
    private String userID;
>>>>>>> cfe4021dbeaf489fd67b19fec1c67eb660810512
    private String userName;
    private String fullName;
    private String userEmail;
    private String userPassword;
<<<<<<< HEAD
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
=======
    private String userRole; 
    private String userPhoneNum;
    
    // Constructors
    public User() {}
    
    public User(String userID, String userName, String fullName, String userEmail, 
                String userPassword, String userRole, String userPhoneNum) {
        this.userID = userID;
        this.userName = userName;
        this.fullName = fullName;
        this.userEmail = userEmail;
        this.userPassword = userPassword;
        this.userRole = userRole;
        this.userPhoneNum = userPhoneNum;
    }
    
    // Getters and Setters
    public String getUserID() { return userID; }
    public void setUserID(String userID) { this.userID = userID; }
    
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
>>>>>>> cfe4021dbeaf489fd67b19fec1c67eb660810512
