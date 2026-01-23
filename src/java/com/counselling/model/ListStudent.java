/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.counselling.model;

/**
 *
 * @author User
 */
public class ListStudent {
    private String studentID;
    private String fullname;

    public ListStudent(String studentID, String fullname) {
        this.studentID = studentID;
        this.fullname = fullname;
    }

    public String getStudentID() { return studentID; }
    public String getFullname() { return fullname; }
    
    public void setStudentID(String studentID) { this.studentID = studentID; }
    public void setFullname(String fullname) { this.fullname = fullname; }
}
