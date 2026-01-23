package com.counselling.model;

public class Student extends User {
    private String studentID, faculty, program; 
    private String counselorID;
    private String roomNo;
    
    public Student() { 
        super();
    }
    
    public Student(int ID, String userName, String fullName, String userEmail, 
                   String userPassword, String userRole, String userPhoneNum, 
                   String studentID, String faculty, String program) {
        super(ID, userName, fullName, userEmail, userPassword, "student", userPhoneNum);
        this.studentID = studentID;
        this.faculty = faculty;
        this.program = program;
    }
    
    // ========== TAMBAH METHOD INI ==========
    public int getId() {
        return getID();  // Get ID from parent User class
    }
    
    public int getStudentIDAsInt() {
        try {
            return Integer.parseInt(studentID);
        } catch (NumberFormatException e) {
            return 0;
        }
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
    
    public String getCounselorID() {
        return counselorID;
    }
    public void setCounselorID(String counselorID) {
        this.counselorID = counselorID;
    }
    
    public String getRoomNo() {
        return roomNo;
    }
    public void setRoomNo(String roomNo) {
        this.roomNo = roomNo;
    }
    
    public void setId(int id) {
        this.setID(id);
    }
    
    public void setRole(String role) {
        this.setUserRole(role);
    }
    
    public String getRole() {
        return this.getUserRole();
    }
}