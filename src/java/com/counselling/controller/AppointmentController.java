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
public class AppointmentController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        String selectedDate = request.getParameter("date");
        if (selectedDate == null || selectedDate.isEmpty()) {
            selectedDate = LocalDate.now().plusDays(1).toString();
        }
        
        request.setAttribute("selectedDate", selectedDate);
        request.setAttribute("defaultDate", selectedDate);

        if ("searchStudent".equals(action)) {
            handleSearchStudent(request, response, selectedDate);
        } else {
            request.getRequestDispatcher("bookAppointmentCounsellor.jsp").forward(request, response);
        }
    }

    private void handleSearchStudent(HttpServletRequest request, HttpServletResponse response, String selectedDate) 
            throws ServletException, IOException {
        
        String studentID = request.getParameter("studentID");
        
        StudentListDAO studentDAO = new StudentListDAO();

        try {
            Student s = studentDAO.getStudentById(studentID);
            if (s == null) {
                request.setAttribute("errorMessage", "Student ID not found in the system!");
                request.getRequestDispatcher("bookAppointmentCounsellor.jsp").forward(request, response);
                return;
            }

            request.setAttribute("foundStudent", s);

            HttpSession session = request.getSession();
            Counselor counselor = (Counselor) session.getAttribute("user");
            
            if (counselor != null) {
                int counselorID = counselor.getID();
                
                SessionDAO sessDAO = new SessionDAO();
                
                String dbDateStr = convertToDatabaseFormat(selectedDate);
        
                List<Session> allSessions = sessDAO.getSessionsByDate(counselorID, dbDateStr);
                request.setAttribute("allSessions", allSessions);
            } else {
                request.setAttribute("errorMessage", "Session expired. Please login again.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database Error: " + e.getMessage());
        }
        
        request.getRequestDispatcher("bookAppointmentCounsellor.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if ("confirmBooking".equals(action)) {
            try {
                handleConfirmBooking(request, response);
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("errorMessage", "System Error: " + e.getMessage());
                request.getRequestDispatcher("bookAppointmentCounsellor.jsp").forward(request, response);
            }
        } else {
            request.getRequestDispatcher("bookAppointmentCounsellor.jsp").forward(request, response);
        }
    }

    private void handleConfirmBooking(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        String studentID = request.getParameter("studentID");
        String studentInternalID = request.getParameter("studentInternalID");
        String sessionIDStr = request.getParameter("sessionID");
        String description = request.getParameter("description");
        String date = request.getParameter("date");

        if (studentInternalID == null || studentInternalID.isEmpty() || 
            sessionIDStr == null || sessionIDStr.isEmpty()) {
            request.setAttribute("errorMessage", "Invalid selection. Please try again.");
            request.getRequestDispatcher("bookAppointmentCounsellor.jsp").forward(request, response);
            return;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            AppointmentDAO appDAO = new AppointmentDAO(conn);
            SessionDAO sessDAO = new SessionDAO();
            
            int sID = Integer.parseInt(sessionIDStr);

            HttpSession session = request.getSession();
            Counselor counselor = (Counselor) session.getAttribute("user");
            if (counselor == null) {
                request.setAttribute("errorMessage", "Session expired. Please login again.");
                request.getRequestDispatcher("bookAppointmentCounsellor.jsp").forward(request, response);
                return;
            }

            Appointment app = new Appointment();
            app.setStudentInternalID(Integer.parseInt(studentInternalID));
            
            app.setCounselorInternalID(counselor.getID());
            
            app.setSessionID(sID);
            app.setDescription(description != null ? description : "");
            app.setAppointmentStatus("Pending");
            
            boolean appointmentCreated = appDAO.createAppointment(app);
            
            boolean sessionUpdated = sessDAO.updateSessionStatus(sID, "unavailable");
            
            if (appointmentCreated && sessionUpdated) {
                conn.commit();
                request.setAttribute("successMessage", "Booking successful! Your appointment has been created.");
                
                StudentListDAO studentDAO = new StudentListDAO();
                Student student = studentDAO.getStudentById(studentID);
                if (student != null) {
                    request.setAttribute("foundStudent", student);
                    
                    String dbDateStr = convertToDatabaseFormat(date);
                    List<Session> allSessions = sessDAO.getSessionsByDate(counselor.getID(), dbDateStr);
                    request.setAttribute("allSessions", allSessions);
                    request.setAttribute("selectedDate", date);
                }
            } else {
                conn.rollback();
                request.setAttribute("errorMessage", "Booking failed. The slot might have been taken.");
            }
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            throw e;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        
        request.getRequestDispatcher("bookAppointmentCounsellor.jsp").forward(request, response);
    }
    
    private String convertToDatabaseFormat(String dateStr) {
        if (dateStr == null || dateStr.isEmpty()) return "";
        
        if (dateStr.contains("/")) {
            String[] parts = dateStr.split("/");
            if (parts.length == 3) {
                return parts[2] + "-" + parts[1] + "-" + parts[0];
            }
        }
        return dateStr;
    }
}