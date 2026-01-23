package com.counselling.model;

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
