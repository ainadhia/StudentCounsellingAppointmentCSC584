package com.counselling.controller;

import com.counselling.dao.AppointmentDAO;
import com.counselling.dao.SessionDAO;
import com.counselling.dao.UserDAO;
import com.counselling.model.Appointment;
import com.counselling.model.Counselor;
import com.counselling.model.Session;
import com.counselling.model.Student;
import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "AppointmentServlet", urlPatterns = {"/AppointmentServlet"})
public class AppointmentServlet extends HttpServlet {
    
    private AppointmentDAO appointmentDAO;
    
    @Override
    public void init() throws ServletException {
        appointmentDAO = new AppointmentDAO();
    }
    
    private int getCounselorID(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return 0;
        
        Object userObj = session.getAttribute("user");
        if (!(userObj instanceof Counselor)) return 0;
        
        Counselor counselor = (Counselor) userObj;
        return counselor.getID();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null || 
            !(session.getAttribute("user") instanceof Counselor)) {
            response.sendRedirect("login.jsp");
            return;
        }

        int counselorID = getCounselorID(request);
        String action = request.getParameter("action");
        if (action == null) action = "list";

        System.out.println("DEBUG doGet: action = " + action);

        try {
            switch (action) {
                case "list":
                    listAppointments(request, response, counselorID);
                    break;
                case "view":
                    viewAppointment(request, response);
                    break;
                case "showReschedule":
                    showReschedule(request, response);
                    break;
                case "getAvailableSessions":  // PASTIKAN ADA CASE INI
                    getAvailableSessionsAjax(request, response);  // Method untuk AJAX
                    break;
                case "complete":
                    completeAppointment(request, response, counselorID);
                    break;
                case "cancel":
                    cancelAppointment(request, response, counselorID);
                    break;
                default:
                    System.out.println("DEBUG: Unknown action: " + action);
                    listAppointments(request, response, counselorID);
            }
        } catch (Exception e) {
            e.printStackTrace();
            // Untuk AJAX request, jangan forward ke error page
            if ("getAvailableSessions".equals(action)) {
                response.setContentType("application/json");
                response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
            } else {
                request.setAttribute("error", "Error: " + e.getMessage());
                RequestDispatcher rd = request.getRequestDispatcher("error.jsp");
                if (rd != null) rd.forward(request, response);
            }
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        HttpSession httpSession = request.getSession();

        try {
            if ("reschedule".equals(action)) {
                rescheduleAppointment(request, httpSession, response);
                return; 
            }
        } catch (Exception e) {
            e.printStackTrace();
            httpSession.setAttribute("error", "Error: " + e.getMessage());
            response.sendRedirect("AppointmentServlet?action=list");
        }
    }

    private void rescheduleAppointment(HttpServletRequest request, HttpSession httpSession, 
                                       HttpServletResponse response) 
            throws Exception {

        System.out.println("START RESCHEDULE PROCESS");

        // Validate and parse parameters
        String appointmentIDStr = request.getParameter("appointmentID");
        String sessionIDStr = request.getParameter("sessionID");
        String newDate = request.getParameter("newDate");
        String notes = request.getParameter("notes");

        if (appointmentIDStr == null || appointmentIDStr.trim().isEmpty()) {
            throw new Exception("Appointment ID is required");
        }

        if (sessionIDStr == null || sessionIDStr.trim().isEmpty()) {
            throw new Exception("Please select a time slot");
        }

        int appointmentID = Integer.parseInt(appointmentIDStr);
        int newSessionID = Integer.parseInt(sessionIDStr);

        System.out.println("Appointment ID: " + appointmentID);
        System.out.println("New Session ID: " + newSessionID);
        System.out.println("New Date: " + newDate);

        Appointment apt = appointmentDAO.getAppointmentById(appointmentID);
        if (apt == null) {
            throw new Exception("Appointment not found");
        }

        SessionDAO sessionDAO = new SessionDAO();
        com.counselling.model.Session newSession = sessionDAO.getSessionById(newSessionID);
        if (newSession == null) {
            throw new Exception("Selected time slot not found");
        }

        if (!"available".equalsIgnoreCase(newSession.getSessionStatus())) {
            throw new Exception("Selected time slot is no longer available");
        }

        int oldSessionID = apt.getSessionID();
        if (oldSessionID > 0) {
            System.out.println("Freeing old session: " + oldSessionID);
            sessionDAO.updateSessionStatus(oldSessionID, "available");
        }

        if (newDate != null && !newDate.trim().isEmpty()) {
            try {
                java.sql.Date sqlDate = java.sql.Date.valueOf(newDate);
                apt.setBookedDate(sqlDate);
            } catch (IllegalArgumentException e) {
                throw new Exception("Invalid date format. Use YYYY-MM-DD");
            }
        }

        apt.setSessionID(newSessionID);
        apt.setAppointmentStatus("booked");

        if (notes != null && !notes.trim().isEmpty()) {
            apt.setDescription(notes);
        }

        System.out.println("Saving to database...");
        boolean appointmentUpdated = appointmentDAO.updateAppointment(apt);
        boolean sessionUpdated = sessionDAO.updateSessionStatus(newSessionID, "booked");

        if (appointmentUpdated && sessionUpdated) {
            System.out.println("DATABASE UPDATE SUCCESS!");

            httpSession.setAttribute("rescheduleSuccess", "true");

            response.sendRedirect("AppointmentServlet?action=showReschedule&id=" + appointmentID);
        } else {
            System.out.println("DATABASE UPDATE FAILED!");
            throw new Exception("Failed to save changes to database");
        }
    }

    
    private void listAppointments(HttpServletRequest request, HttpServletResponse response, int counselorID) 
        throws SQLException, ServletException, IOException {

    System.out.println("\n========== listAppointments START ==========");
    System.out.println("Counselor ID: " + counselorID);

    String filter = request.getParameter("statusFilter");
    List<Appointment> appointments;

    if (filter != null && !filter.equals("all")) {
        appointments = appointmentDAO.getAppointmentsByStatus(counselorID, filter);
    } else {
        appointments = appointmentDAO.getAllAppointmentsByCounselor(counselorID);
    }

    System.out.println("Found appointments: " + appointments.size());

    UserDAO userDAO = new UserDAO();
    SessionDAO sessionDAO = new SessionDAO();

    Map<Integer, String> userNameMap = new HashMap<>();
    Map<Integer, String> counselorNameMap = new HashMap<>();
    Map<Integer, String> sessionStartTimeMap = new HashMap<>();
    Map<Integer, String> sessionEndTimeMap = new HashMap<>();

    for (Appointment apt : appointments) {
        System.out.println("\n--- Processing Appointment ID: " + apt.getID() + " ---");

        int studentUserId = apt.getStudentID(); 
        
        if (!userNameMap.containsKey(studentUserId)) {
            System.out.println("Looking up student with User ID: " + studentUserId);
            try {
                Student student = userDAO.getStudentByAppointmentId(studentUserId);
                if (student != null && student.getFullName() != null && !student.getFullName().isEmpty()) {
                    userNameMap.put(studentUserId, student.getFullName());
                    System.out.println("✓ Student found: " + student.getFullName());
                } else {
                    userNameMap.put(studentUserId, "Student #" + studentUserId);
                    System.out.println("✗ Student not found");
                }
            } catch (SQLException ex) {
                System.out.println("SQL Error: " + ex.getMessage());
                ex.printStackTrace();
                userNameMap.put(studentUserId, "Error Loading");
            }
        } else {
            System.out.println("Student already in map: " + userNameMap.get(studentUserId));
        }

        int counselorUserId = apt.getCounselorID();
        
        if (!counselorNameMap.containsKey(counselorUserId)) {
            System.out.println("Looking up counselor with User ID: " + counselorUserId);
            try {
                Counselor counselor = userDAO.getCounselorById(counselorUserId);
                if (counselor != null && counselor.getFullName() != null && !counselor.getFullName().isEmpty()) {
                    counselorNameMap.put(counselorUserId, counselor.getFullName());
                    System.out.println("✓ Counselor found: " + counselor.getFullName());
                } else {
                    counselorNameMap.put(counselorUserId, "Counselor #" + counselorUserId);
                    System.out.println("✗ Counselor not found");
                }
            } catch (SQLException ex) {
                System.out.println("SQL Error: " + ex.getMessage());
                ex.printStackTrace();
                counselorNameMap.put(counselorUserId, "Error Loading");
            }
        } else {
            System.out.println("Counselor already in map: " + counselorNameMap.get(counselorUserId));
        }

        if (apt.getSessionID() > 0) {
            try {
                com.counselling.model.Session sessionObj = sessionDAO.getSessionById(apt.getSessionID());
                if (sessionObj != null) {
                    java.text.SimpleDateFormat timeFormat = new java.text.SimpleDateFormat("hh:mm a");
                    sessionStartTimeMap.put(apt.getSessionID(), timeFormat.format(sessionObj.getStartTime()));
                    sessionEndTimeMap.put(apt.getSessionID(), timeFormat.format(sessionObj.getEndTime()));
                    System.out.println("✓ Session time: " + sessionStartTimeMap.get(apt.getSessionID()) + 
                                     " - " + sessionEndTimeMap.get(apt.getSessionID()));
                }
            } catch (SQLException ex) {
                Logger.getLogger(AppointmentServlet.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }

    int todayBooked = 0, weekCount = 0, todayPending = 0, weekCompleted = 0;

    try {
        todayBooked = appointmentDAO.getTodayBookedCount(counselorID);
        weekCount = appointmentDAO.getThisWeekAppointmentCount(counselorID);
        todayPending = appointmentDAO.getTodayPendingCount(counselorID);
        weekCompleted = appointmentDAO.getThisWeekCompletedCount(counselorID);

        System.out.println("\n=== STATISTICS ===");
        System.out.println("Today Booked: " + todayBooked);
        System.out.println("Week Count: " + weekCount);
        System.out.println("Today Pending: " + todayPending);
        System.out.println("Week Completed: " + weekCompleted);

    } catch (Exception e) {
        System.out.println("Error getting stats: " + e.getMessage());
        e.printStackTrace();
    }

    System.out.println("\n=== FINAL MAPS ===");
    System.out.println("userNameMap size: " + userNameMap.size());
    System.out.println("userNameMap content: " + userNameMap);
    System.out.println("counselorNameMap size: " + counselorNameMap.size());

    request.setAttribute("appointments", appointments);
    request.setAttribute("userNameMap", userNameMap);
    request.setAttribute("counselorNameMap", counselorNameMap);
    request.setAttribute("sessionStartTimeMap", sessionStartTimeMap);
    request.setAttribute("sessionEndTimeMap", sessionEndTimeMap);

    request.setAttribute("todayBookedCount", todayBooked);
    request.setAttribute("weekCount", weekCount);
    request.setAttribute("todayPendingCount", todayPending);
    request.setAttribute("weekCompletedCount", weekCompleted);
    request.setAttribute("currentDate", new java.util.Date());

    System.out.println("\n=== ATTRIBUTES SET SUCCESSFULLY ===");
    System.out.println("todayBookedCount: " + request.getAttribute("todayBookedCount"));
    System.out.println("weekCount: " + request.getAttribute("weekCount"));
    System.out.println("========== listAppointments END ==========\n");

    RequestDispatcher rd = request.getRequestDispatcher("cAppointment.jsp");
    rd.forward(request, response);
}
    
    private void viewAppointment(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        Appointment apt = appointmentDAO.getAppointmentById(id);
        
        if (apt != null) {
            request.setAttribute("appointment", apt);
            RequestDispatcher rd = request.getRequestDispatcher("appointmentDetails.jsp");
            rd.forward(request, response);
        } else {
            response.sendRedirect("AppointmentServlet?action=list");
        }
    }
    
    private void showReschedule(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        try {
            String idStr = request.getParameter("id");
            if (idStr == null || idStr.trim().isEmpty()) {
                response.sendRedirect("AppointmentServlet?action=list");
                return;
            }

            int id = Integer.parseInt(idStr);
            System.out.println("DEBUG: showReschedule for appointment ID: " + id);

            Appointment apt = appointmentDAO.getAppointmentById(id);
            System.out.println("DEBUG: Appointment found: " + (apt != null));

            if (apt != null) {
                // Dapatkan counselor dari session
                HttpSession session = request.getSession();
                Counselor counselor = (Counselor) session.getAttribute("user");
                int counselorID = counselor.getID();

                System.out.println("DEBUG: Counselor ID: " + counselorID);
                System.out.println("DEBUG: Appointment counselor ID: " + apt.getCounselorID());

                if (apt.getCounselorID() != counselorID) {
                    response.sendRedirect("AppointmentServlet?action=list");
                    return;
                }

                request.setAttribute("appointment", apt);

                System.out.println("DEBUG: Forwarding to cReschedule.jsp");

                RequestDispatcher rd = request.getRequestDispatcher("cReschedule.jsp");
                rd.forward(request, response);
            } else {
                System.out.println("DEBUG: Appointment not found");
                response.sendRedirect("AppointmentServlet?action=list");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("AppointmentServlet?action=list");
        }
    }

    
    private void completeAppointment(HttpServletRequest request, HttpServletResponse response, int counselorID)
            throws SQLException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        Appointment apt = appointmentDAO.getAppointmentById(id);
        
        if (apt != null && apt.getCounselorID() == counselorID) {
            appointmentDAO.updateAppointmentStatus(id, "complete");
            HttpSession session = request.getSession();
            session.setAttribute("message", "Appointment completed!");
        }
        
        response.sendRedirect("AppointmentServlet?action=list");
    }
    
    private void cancelAppointment(HttpServletRequest request, HttpServletResponse response, int counselorID)
            throws SQLException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        Appointment apt = appointmentDAO.getAppointmentById(id);
        
        if (apt != null && apt.getCounselorID() == counselorID) {
            appointmentDAO.updateAppointmentStatus(id, "cancelled");
            HttpSession session = request.getSession();
            session.setAttribute("message", "Appointment cancelled!");
        }
        
        response.sendRedirect("AppointmentServlet?action=list");
    }
    
    private void getAvailableSessionsAjax(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String dateStr = request.getParameter("date");
            String counselorIDStr = request.getParameter("counselorID");

            if (dateStr == null || counselorIDStr == null) {
                response.getWriter().write("[]");
                return;
            }

            int counselorID = Integer.parseInt(counselorIDStr);

            SessionDAO sessionDAO = new SessionDAO();
            List<Session> availableSessions = sessionDAO.getAvailableSessionsByDate(counselorID, dateStr);

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            java.text.SimpleDateFormat timeFormat = new java.text.SimpleDateFormat("hh:mm a");

            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < availableSessions.size(); i++) {
                Session s = availableSessions.get(i);

                json.append("{")
                    .append("\"sessionID\":").append(s.getSessionID()).append(",")
                    .append("\"startTime\":\"").append(timeFormat.format(s.getStartTime())).append("\",")
                    .append("\"endTime\":\"").append(timeFormat.format(s.getEndTime())).append("\",")
                    .append("\"date\":\"").append(new java.text.SimpleDateFormat("yyyy-MM-dd").format(s.getStartTime())).append("\"");

                if (i < availableSessions.size() - 1) {
                    json.append("},");
                } else {
                    json.append("}");
                }
            }
            json.append("]");

            response.getWriter().write(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
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
