package com.counselling.model;

public class Student extends User {
    private String studentID, faculty, program; 

    // Constructor Kosong
    public Student() { 
        super();
    }
    
    public Student(int ID, String userName, String fullName, String userEmail, String userPassword, String userRole, String userPhoneNum, String studentID, String faculty, String program) 
    {
        super(ID, userName, fullName, userEmail, userPassword, "student", userPhoneNum);
        this.studentID = studentID;
        this.faculty = faculty;
        this.program = program;
    }

    // Getter & Setter 
    public String getStudentID() {
        return studentID;
    }

    public void setStudentID(String studentID) {
        this.studentID = studentID;
    }

    public String getFaculty() {
        return faculty;
    }

    public void setFaculty(String faculty) {
        this.faculty = faculty;
    }

    public String getProgram() {
        return program;
    }

    public void setProgram(String program) {
        this.program = program;
    }
}