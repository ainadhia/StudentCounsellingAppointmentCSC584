package com.counselling.controller;

import com.counselling.dao.SessionDAO;
import com.counselling.model.Session;
<<<<<<< HEAD
import com.counselling.model.Student; // Guna model user anda
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/SessionServlet")
public class SessionServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession sessionObj = request.getSession();
        Student counselor = (Student) sessionObj.getAttribute("user");
        
        if (counselor == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String startTime = request.getParameter("startTime");
        String endTime = request.getParameter("endTime");
        
        Session newSession = new Session();
        newSession.setStartTime(startTime);
        newSession.setEndTime(endTime);
        newSession.setCounselorId(counselor.getCounselorID());

        SessionDAO dao = new SessionDAO();
        try {
            if (dao.addSession(newSession)) {
                response.sendRedirect("manageSessions.jsp?success=added");
            } else {
                response.sendRedirect("manageSessions.jsp?error=failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("manageSessions.jsp?error=exception");
        }
    }
=======
import com.counselling.model.Counselor;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/SessionServlet")
public class SessionServlet extends HttpServlet {
    private SessionDAO sessionDAO;
    
    @Override
    public void init() throws ServletException {
        try {
            Connection conn = getConnection();
            sessionDAO = new SessionDAO(conn);
            System.out.println("SessionServlet initialized successfully!");
        } catch (Exception e) {
            throw new ServletException("Error initializing SessionDAO", e);
        }
    }
    
    private Connection getConnection() throws SQLException {
        try {
            Class.forName("org.apache.derby.jdbc.ClientDriver");
            return DriverManager.getConnection(
                "jdbc:derby://localhost:1527/CounsellingDB",
                "app",
                "app"
            );
        } catch (ClassNotFoundException e) {
            throw new SQLException("Derby Driver not found", e);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        String action = request.getParameter("action");
        HttpSession httpSession = request.getSession();
        Counselor counselor = (Counselor) httpSession.getAttribute("user");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        System.out.println("=== SESSION ATTRIBUTES ===");
        java.util.Enumeration<String> attributeNames = httpSession.getAttributeNames();
        while (attributeNames.hasMoreElements()) {
            String name = attributeNames.nextElement();
            Object value = httpSession.getAttribute(name);
            System.out.println(name + " = " + value);
        }
        System.out.println("=========================");


        try {
            if (counselor == null) {
                response.getWriter().write("{\"error\": \"Not authenticated\"}");
                return;
            }
            
            int counselorID;
            try {
                counselorID = Integer.parseInt(counselor.getUserID());  
                System.out.println("DEBUG - UserID (int): " + counselorID);
            } catch (NumberFormatException e) {
                System.err.println("ERROR: Cannot parse userID to int: " + counselor.getUserID());
                response.getWriter().write("{\"error\": \"Invalid user ID format\"}");
                return;
            }

            if ("getSessionsByDate".equals(action)) {
                getSessionsByDate(request, response, counselorID);
            } else if ("checkOverlap".equals(action)) {
                checkTimeOverlap(request, response, counselorID);
            } else {
                response.getWriter().write("{\"error\": \"Invalid action: " + action + "\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        String action = request.getParameter("action");
        HttpSession httpSession = request.getSession();
        Counselor counselor = (Counselor) httpSession.getAttribute("user");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        System.out.println("DEBUG doPost - counselor from session: " + (counselor != null ? counselor.getUserName() : "null"));
        System.out.println("DEBUG doPost - action: " + action);
        
        try {
            if (counselor == null) {
                response.getWriter().write("{\"success\": false, \"message\": \"Not authenticated\"}");
                return;
            }
            
            int counselorID;
            try {
                counselorID = Integer.parseInt(counselor.getUserID());
                System.out.println("DEBUG - UserID for POST (int): " + counselorID);
            } catch (NumberFormatException e) {
                System.err.println("ERROR: Cannot parse userID to int: " + counselor.getUserID());
                response.getWriter().write("{\"success\": false, \"message\": \"Invalid user ID format\"}");
                return;
            }
            
            if ("addSession".equals(action)) {
                addSession(request, response, counselorID);
            } else if ("updateStatus".equals(action)) {
                updateSessionStatus(request, response, counselorID);
            } else if ("generateSlots".equals(action)) {
                generateDailySlots(request, response, counselorID);
            } else if ("deleteSession".equals(action)) {
                deleteSession(request, response, counselorID);
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"Invalid action: " + action + "\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        }
    }
    
    private void getSessionsByDate(HttpServletRequest request, HttpServletResponse response, int counselorID) 
            throws Exception {

        String dateStr = request.getParameter("date");
        System.out.println("\n=== GET SESSIONS BY DATE ===");
        System.out.println("Date requested: " + dateStr);
        System.out.println("CounselorID (int - USER.ID): " + counselorID);

        try {
            sessionDAO.generateDailySlots(counselorID, dateStr);

            List<Session> sessions = sessionDAO.getSessionsByDate(counselorID, dateStr);

            System.out.println("Sessions retrieved: " + sessions.size());

            StringBuilder json = new StringBuilder("[");

            for (int i = 0; i < sessions.size(); i++) {
                if (i > 0) json.append(",");

                Session s = sessions.get(i);
                String displayStatus = determineStatus(s);

                System.out.println("Session " + (i+1) + ": " + 
                    s.getFormattedStartTime() + "-" + s.getFormattedEndTime() + 
                    " | Status: " + s.getSessionStatus() + 
                    " | Display: " + displayStatus);

                json.append("{");
                json.append("\"sessionID\":").append(s.getSessionID()).append(",");
                json.append("\"startTime\":\"").append(s.getFormattedStartTime()).append("\",");
                json.append("\"endTime\":\"").append(s.getFormattedEndTime()).append("\",");
                json.append("\"sessionStatus\":\"").append(s.getSessionStatus()).append("\",");
                json.append("\"displayStatus\":\"").append(displayStatus).append("\",");
                json.append("\"counselorID\":").append(s.getCounselorID());
                json.append("}");
            }

            json.append("]");

            String jsonString = json.toString();
            System.out.println("JSON Response: " + jsonString);
            System.out.println("=== END GET SESSIONS ===\n");

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(jsonString);

        } catch (Exception e) {
            System.err.println("ERROR in getSessionsByDate:");
            e.printStackTrace();

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }
    
    private void addSession(HttpServletRequest request, HttpServletResponse response, int counselorID)
            throws Exception {
        
        System.out.println("\n=== ADD MANUAL SESSION ===");
        System.out.println("CounselorID (int - USER.ID): " + counselorID);
        
        String dateStr = request.getParameter("date");
        String startTimeStr = request.getParameter("startTime");
        String endTimeStr = request.getParameter("endTime");
        
        System.out.println("Date: " + dateStr);
        System.out.println("Start: " + startTimeStr);
        System.out.println("End: " + endTimeStr);
        
        if (dateStr == null || startTimeStr == null || endTimeStr == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Missing parameters\"}");
            return;
        }
        
        if (startTimeStr.compareTo(endTimeStr) >= 0) {
            response.getWriter().write("{\"success\":false,\"message\":\"Start time must be before end time\"}");
            return;
        }
        
        boolean hasOverlap = sessionDAO.hasTimeOverlap(counselorID, dateStr, startTimeStr, endTimeStr);
        if (hasOverlap) {
            response.getWriter().write("{\"success\":false,\"message\":\"Time slot overlaps\"}");
            return;
        }
        
        Timestamp startTimestamp = Timestamp.valueOf(dateStr + " " + startTimeStr + ":00");
        Timestamp endTimestamp = Timestamp.valueOf(dateStr + " " + endTimeStr + ":00");
        
        Session session = new Session();
        session.setStartTime(startTimestamp);
        session.setEndTime(endTimestamp);
        session.setSessionStatus("available");
        session.setCounselorID(counselorID);  
        
        boolean success = sessionDAO.addSession(session);
        
        if (success) {
            response.getWriter().write("{\"success\":true,\"message\":\"Session added successfully\"}");
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"Failed to add session\"}");
        }
    }
    
    private void updateSessionStatus(HttpServletRequest request, HttpServletResponse response, int counselorID) 
            throws Exception {
        
        System.out.println("\n=== UPDATE SESSION STATUS ===");
        
        String sessionIDStr = request.getParameter("sessionID");
        String status = request.getParameter("status");
        
        System.out.println("SessionID: " + sessionIDStr);
        System.out.println("New Status: " + status);
        
        if (sessionIDStr == null || status == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Missing parameters\"}");
            return;
        }
        
        try {
            int sessionID = Integer.parseInt(sessionIDStr);
            
            // Validate status (only allow available/unavailable)
            if (!"available".equalsIgnoreCase(status) && !"unavailable".equalsIgnoreCase(status)) {
                response.getWriter().write("{\"success\":false,\"message\":\"Invalid status. Only 'available' or 'unavailable' allowed\"}");
                return;
            }
            
            // First check if session belongs to this counselor
            Session session = sessionDAO.getSessionById(sessionID);
            if (session == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"Session not found\"}");
                return;
            }
            
            if (session.getCounselorID() != counselorID) {
                response.getWriter().write("{\"success\":false,\"message\":\"Unauthorized - This session does not belong to you\"}");
                return;
            }
            
            // Check if session is booked - cannot change status if booked
            if ("booked".equalsIgnoreCase(session.getSessionStatus())) {
                response.getWriter().write("{\"success\":false,\"message\":\"Cannot change status of a booked session\"}");
                return;
            }
            
            // Update the status
            boolean success = sessionDAO.updateSessionStatus(sessionID, status.toLowerCase());
            
            if (success) {
                response.getWriter().write("{\"success\":true,\"message\":\"Status updated to " + status + "\"}");
                System.out.println("✓ Status updated successfully for session " + sessionID);
            } else {
                response.getWriter().write("{\"success\":false,\"message\":\"Failed to update status\"}");
                System.out.println("✗ Failed to update status for session " + sessionID);
            }
            
        } catch (NumberFormatException e) {
            response.getWriter().write("{\"success\":false,\"message\":\"Invalid session ID format\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"Server error: " + e.getMessage() + "\"}");
        }
    }
    
    private void generateDailySlots(HttpServletRequest request, HttpServletResponse response, int counselorID) 
            throws Exception {
        
        System.out.println("\n=== GENERATE DAILY SLOTS (via Servlet) ===");
        
        String dateStr = request.getParameter("date");
        System.out.println("Date: " + dateStr);
        System.out.println("CounselorID: " + counselorID);
        
        if (dateStr == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Date parameter missing\"}");
            return;
        }
        
        try {
            // Check if slots already exist for this date
            List<Session> existing = sessionDAO.getSessionsByDate(counselorID, dateStr);
            
            if (!existing.isEmpty()) {
                response.getWriter().write("{\"success\":true,\"message\":\"Slots already exist for this date\"}");
                return;
            }
            
            // Generate slots using DAO
            sessionDAO.generateDailySlots(counselorID, dateStr);
            response.getWriter().write("{\"success\":true,\"message\":\"Daily slots generated successfully\"}");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"Error generating slots: " + e.getMessage() + "\"}");
        }
    }
    
    private void deleteSession(HttpServletRequest request, HttpServletResponse response, int counselorID) 
            throws Exception {
        
        System.out.println("\n=== DELETE SESSION ===");
        
        String sessionIDStr = request.getParameter("sessionID");
        System.out.println("SessionID: " + sessionIDStr);
        
        if (sessionIDStr == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Session ID missing\"}");
            return;
        }
        
        try {
            int sessionID = Integer.parseInt(sessionIDStr);
            
            // Check if session belongs to this counselor
            Session session = sessionDAO.getSessionById(sessionID);
            if (session == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"Session not found\"}");
                return;
            }
            
            if (session.getCounselorID() != counselorID) {
                response.getWriter().write("{\"success\":false,\"message\":\"Unauthorized - This session does not belong to you\"}");
                return;
            }
            
            // Check if session is booked - cannot delete booked sessions
            if ("booked".equalsIgnoreCase(session.getSessionStatus())) {
                response.getWriter().write("{\"success\":false,\"message\":\"Cannot delete a booked session\"}");
                return;
            }
            
            // Delete the session
            boolean success = sessionDAO.deleteSession(sessionID);
            
            if (success) {
                response.getWriter().write("{\"success\":true,\"message\":\"Session deleted successfully\"}");
                System.out.println("✓ Session " + sessionID + " deleted successfully");
            } else {
                response.getWriter().write("{\"success\":false,\"message\":\"Failed to delete session\"}");
                System.out.println("✗ Failed to delete session " + sessionID);
            }
            
        } catch (NumberFormatException e) {
            response.getWriter().write("{\"success\":false,\"message\":\"Invalid session ID format\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"Server error: " + e.getMessage() + "\"}");
        }
    }
    
    private void checkTimeOverlap(HttpServletRequest request, HttpServletResponse response, int counselorID) 
            throws Exception {
        
        String dateStr = request.getParameter("date");
        String startTimeStr = request.getParameter("startTime");
        String endTimeStr = request.getParameter("endTime");
        
        boolean hasOverlap = sessionDAO.hasTimeOverlap(counselorID, dateStr, startTimeStr, endTimeStr);
        response.getWriter().write("{\"hasOverlap\": " + hasOverlap + "}");
    }
    
    private String determineStatus(Session session) {
        Timestamp now = new Timestamp(System.currentTimeMillis());
        
        if (session.getEndTime().before(now)) return "past";
        if ("booked".equals(session.getSessionStatus())) return "booked";
        if ("unavailable".equals(session.getSessionStatus())) return "unavailable";
        return "available";
    }
    
    @Override
    public void destroy() {
        System.out.println("SessionServlet destroyed");
    }
>>>>>>> cfe4021dbeaf489fd67b19fec1c67eb660810512
}