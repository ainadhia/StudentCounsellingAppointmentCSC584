package com.counselling.controller;

import com.counselling.dao.*;
import com.counselling.model.*;
import com.counselling.util.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AppointmentController")
public class AppointmentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        // IMPROVEMENT: Capture the date parameter sent by the JSP date picker
        String selectedDate = request.getParameter("date");
        if (selectedDate == null || selectedDate.isEmpty()) {
            // Default to TOMORROW's date (not today)
            selectedDate = LocalDate.now().plusDays(1).toString();
        }
        
        // Pass the date back to the JSP to keep the calendar synced
        request.setAttribute("selectedDate", selectedDate);
        request.setAttribute("defaultDate", selectedDate); 

        if ("searchStudent".equals(action)) {
            // Pass the selectedDate into the student search handler
            handleSearchStudent(request, selectedDate);
        }
        
        request.getRequestDispatcher("bookAppointmentCounsellor.jsp").forward(request, response);
    }

    private void handleSearchStudent(HttpServletRequest request, String selectedDate) {
        String studentID = request.getParameter("studentID");
        StudentListDAO sListDAO = new StudentListDAO();

        Student s = sListDAO.getStudentById(studentID);
        if (s == null) {
            request.setAttribute("errorMessage", "Student ID not found in the system!");
            return;
        }

        request.setAttribute("foundStudent", s);

        try (Connection conn = DBConnection.getConnection()) {
            SessionDAO sessDAO = new SessionDAO(conn);
            
            Counselor counselor = (Counselor) request.getSession().getAttribute("user");
            
            if (counselor != null) {
                // Try to get the numeric user ID first (which is used in the SESSION table)
                String userID = counselor.getUserID();
                
                int cID = Integer.parseInt(userID); // Use the numeric user ID, not counselorID
                
                // CONVERT DATE FORMAT
                String dbDateStr = convertToDatabaseFormat(selectedDate);
        
                // IMPROVEMENT: Fetch sessions specifically for this counselor and the picked date
                List<Session> allSessions = sessDAO.getSessionsByDate(cID, dbDateStr);
                request.setAttribute("allSessions", allSessions);
            } else {
                request.setAttribute("errorMessage", "Session expired. Please login again.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database Error: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if ("confirmBooking".equals(action)) {
            handleConfirmBooking(request);
            
            // RE-POPULATE the student and sessions data so the UI doesn't disappear
            String studentID = request.getParameter("studentID");
            String date = request.getParameter("date");
            if (studentID != null && !studentID.isEmpty()) {
                handleSearchStudent(request, date);
            }
        }
        
        request.getRequestDispatcher("bookAppointmentCounsellor.jsp").forward(request, response);
    }

    private void handleConfirmBooking(HttpServletRequest request) {
        String studentID = request.getParameter("studentID");
        String studentInternalID = request.getParameter("studentInternalID");
        String sessionIDStr = request.getParameter("sessionID");
        String description = request.getParameter("description");

        if (studentInternalID == null || sessionIDStr == null || sessionIDStr.isEmpty()) {
            request.setAttribute("errorMessage", "Invalid selection. Please try again.");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false); 
            
            AppointmentDAO appDAO = new AppointmentDAO(conn);
            SessionDAO sessDAO = new SessionDAO(conn);
            
            int sID = Integer.parseInt(sessionIDStr);

            // Get counselor from session
            Counselor counselor = (Counselor) request.getSession().getAttribute("user");
            if (counselor == null) {
                request.setAttribute("errorMessage", "Session expired. Please login again.");
                return;
            }

            Appointment app = new Appointment();
            app.setStudentInternalID(Integer.parseInt(studentInternalID)); // Using the database numeric ID
            app.setCounselorInternalID(Integer.parseInt(counselor.getUserID())); // Set counselor ID from session
            app.setSessionID(sID);
            app.setDescription(description); 
            
            // Atomically create appointment and mark session as unavailable
            if (appDAO.createAppointment(app) && sessDAO.updateSessionStatus(sID, "unavailable")) {
                conn.commit();
                request.setAttribute("successMessage", "Booking successful! Your appointment has been created.");
            } else {
                conn.rollback();
                request.setAttribute("errorMessage", "Booking failed. The slot might have been taken.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "System Error: " + e.getMessage());
        }
    }
    
    // DATE FORMAT CONVERSION
    private String convertToDatabaseFormat(String dateStr) {
        if (dateStr == null || dateStr.isEmpty()) return "";
        
        if (dateStr.contains("/")) {
            // Convert DD/MM/YYYY to YYYY-MM-DD for Database compatibility
            String[] parts = dateStr.split("/");
            if (parts.length == 3) {
                return parts[2] + "-" + parts[1] + "-" + parts[0];
            }
        }
        return dateStr; // Returns YYYY-MM-DD format as required by SessionDAO
    }
}