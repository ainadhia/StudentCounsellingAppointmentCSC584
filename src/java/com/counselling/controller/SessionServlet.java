package com.counselling.controller;

import com.counselling.dao.AppointmentDAO;
import com.counselling.dao.SessionDAO;
import com.counselling.model.Appointment;
import com.counselling.model.Session;
import com.counselling.model.Counselor;
import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "SessionServlet", urlPatterns = {"/SessionServlet"})
public class SessionServlet extends HttpServlet {
    
    private SessionDAO sessionDAO;
    
    @Override
    public void init() throws ServletException {
        sessionDAO = new SessionDAO();
        System.out.println("SessionServlet INITIALIZED");
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("\n=== SessionServlet doGet ===");

        HttpSession httpSession = request.getSession(false);

        if (httpSession == null || httpSession.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        if (!(httpSession.getAttribute("user") instanceof Counselor)) {
            response.sendRedirect("unauthorized.jsp");
            return;
        }

        Counselor counselor = (Counselor) httpSession.getAttribute("user");
        int counselorID = counselor.getID();

        String appointmentIDStr = request.getParameter("appointmentID");
        if (appointmentIDStr != null) {
            try {
                int appointmentID = Integer.parseInt(appointmentIDStr);
                AppointmentDAO appointmentDAO = new AppointmentDAO();
                Appointment appointment = appointmentDAO.getAppointmentById(appointmentID);

                if (appointment != null && appointment.getCounselorID() == counselorID) {
                    response.sendRedirect("AppointmentServlet?action=view&id=" + appointmentID);
                    return;
                } else {
                    response.sendRedirect("SessionServlet?action=viewPage");
                    return;
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("SessionServlet?action=viewPage");
                return;
            }
        }

        String dateStr = request.getParameter("date");

        if (dateStr == null || dateStr.trim().isEmpty()) {
            Date tomorrow = new Date(System.currentTimeMillis() + 86400000);
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            dateStr = sdf.format(tomorrow);
        }

        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date selectedDate = sdf.parse(dateStr);
            Date today = new Date();

            today = sdf.parse(sdf.format(today));

            if (selectedDate.before(today)) {
                String todayStr = sdf.format(new Date());
                response.sendRedirect("SessionServlet?action=viewPage&date=" + todayStr);
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        List<Session> sessions = null;
        try {
            sessions = sessionDAO.getSessionsByDate(counselorID, dateStr);
        } catch (SQLException ex) {
            Logger.getLogger(SessionServlet.class.getName()).log(Level.SEVERE, null, ex);
        }

        String displayDate;
        try {
            SimpleDateFormat displayFormat = new SimpleDateFormat("EEEE, MMMM d, yyyy");
            Date displayDateObj = new SimpleDateFormat("yyyy-MM-dd").parse(dateStr);
            displayDate = displayFormat.format(displayDateObj);
        } catch (Exception e) {
            displayDate = dateStr;
        }

        request.setAttribute("sessions", sessions);
        request.setAttribute("selectedDate", dateStr);
        request.setAttribute("displayDate", displayDate);
        request.setAttribute("counselor", counselor);

        request.getRequestDispatcher("sessionEditCounsellor.jsp")
               .forward(request, response);
    }

    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("\n=== SessionServlet doPost ===");
        
        HttpSession httpSession = request.getSession(false);
        if (httpSession == null || httpSession.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        Counselor counselor = (Counselor) httpSession.getAttribute("user");
        int counselorID = counselor.getID();
        
        String action = request.getParameter("action");
        String dateStr = request.getParameter("date");
        
        System.out.println("POST Action: " + action);
        System.out.println("Date: " + dateStr);
        System.out.println("Counselor ID: " + counselorID);
        
        try {
            if ("addSession".equals(action)) {
                String startTime = request.getParameter("startTime");
                String endTime = request.getParameter("endTime");
                
                System.out.println("Adding session: " + startTime + " to " + endTime);
                
                Timestamp start = Timestamp.valueOf(dateStr + " " + startTime + ":00");
                Timestamp end = Timestamp.valueOf(dateStr + " " + endTime + ":00");
                
                Session session = new Session();
                session.setStartTime(start);
                session.setEndTime(end);
                session.setSessionStatus("available");
                session.setCounselorID(counselorID);
                
                boolean success = sessionDAO.addSession(session);
                
                if (success) {
                    httpSession.setAttribute("message", "✓ Session added successfully!");
                } else {
                    httpSession.setAttribute("error", "✗ Failed to add session. Time slot may be overlapping.");
                }
                
            } else if ("updateStatus".equals(action)) {
                int sessionID = Integer.parseInt(request.getParameter("sessionID"));
                String status = request.getParameter("status");
                
                System.out.println("Updating session " + sessionID + " to status: " + status);
                
                boolean success = sessionDAO.updateSessionStatus(sessionID, status);
                
                if (success) {
                    httpSession.setAttribute("message", "Session status updated to " + status + "!");
                } else {
                    httpSession.setAttribute("error", "Failed to update session status.");
                }
                
            } else if ("generateSlots".equals(action)) {
                System.out.println("Generating default slots for: " + dateStr);
                
                boolean success = sessionDAO.generateDailySlots(counselorID, dateStr);
                
                if (success) {
                    httpSession.setAttribute("message", "efault time slots generated successfully!");
                } else {
                    httpSession.setAttribute("message", "ℹ Slots already exist for this date.");
                }
                
            } else if ("deleteSession".equals(action)) {
                int sessionID = Integer.parseInt(request.getParameter("sessionID"));
                
                System.out.println("Deleting session: " + sessionID);
                
                boolean success = sessionDAO.deleteSession(sessionID);
                
                if (success) {
                    httpSession.setAttribute("message", "Session deleted successfully!");
                } else {
                    httpSession.setAttribute("error", "Cannot delete session. It may be booked or doesn't exist.");
                }
            }
            
        } catch (Exception e) {
            System.err.println("Error in POST: " + e.getMessage());
            e.printStackTrace();
            httpSession.setAttribute("error", "Error: " + e.getMessage());
        }
        
        response.sendRedirect("SessionServlet?action=viewPage&date=" + (dateStr != null ? dateStr : ""));
    }
}