package com.counselling.controller;

import com.counselling.dao.AppointmentDAO;
import com.counselling.dao.SessionDAO;
import com.counselling.model.Appointment;
import com.counselling.model.Session;
import com.counselling.model.AppointmentView;
import com.counselling.model.AppointmentStats;
import com.counselling.model.Student;
import com.counselling.util.DBConnection;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.sql.Connection;
import java.io.PrintWriter;

@WebServlet("/StudentAppointmentServlet")
public class StudentAppointmentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null || !"S".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        
        if ("loadSessions".equals(action)) {
            loadSessions(request, response);
        } else if ("manage".equals(action)) {
            showManageAppointments(request, response, session);
        } else if ("availableSessions".equals(action)) {
            sendAvailableSessionsJson(request, response);
        } else if ("history".equals(action)) {
            showHistory(request, response, session);
        } else {
            response.sendRedirect("bookAppointmentStudent.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null || !"S".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        
        if ("bookAppointment".equals(action)) {
            bookAppointment(request, response, session);
        } else if ("cancelAppointment".equals(action)) {
            cancelAppointment(request, response, session);
        } else if ("rescheduleAppointment".equals(action)) {
            rescheduleAppointment(request, response, session);
        } else if ("deleteAppointment".equals(action)) {
            deleteAppointment(request, response, session);
        }
    }

    private Student getStudentFromSession(HttpSession session) {
        return (Student) session.getAttribute("user");
    }

    private void showManageAppointments(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        try {
            Student student = getStudentFromSession(session);
            Connection conn = DBConnection.getConnection();
            AppointmentDAO appointmentDAO = new AppointmentDAO(conn);
            // FIXED: Gunakan getStudentIDAsInt() bukan getId()
            List<AppointmentView> appointments = appointmentDAO.getUpcomingAppointmentsForStudent(student.getStudentIDAsInt());
            request.setAttribute("appointments", appointments);
            request.getRequestDispatcher("manageAppointmentStudent.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading appointments: " + e.getMessage());
            request.getRequestDispatcher("manageAppointmentStudent.jsp").forward(request, response);
        }
    }

    private void showHistory(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        try {
            Student student = getStudentFromSession(session);
            String search = request.getParameter("q");
            Connection conn = DBConnection.getConnection();
            AppointmentDAO appointmentDAO = new AppointmentDAO(conn);
            // FIXED: Gunakan getStudentIDAsInt() bukan getId()
            List<AppointmentView> history = appointmentDAO.getAllAppointmentsForStudent(student.getStudentIDAsInt(), search);
            // FIXED: Gunakan getStudentIDAsInt() bukan getId()
            AppointmentStats stats = appointmentDAO.getAppointmentStatsForStudent(student.getStudentIDAsInt());
            request.setAttribute("history", history);
            request.setAttribute("stats", stats);
            request.setAttribute("query", search);
            request.getRequestDispatcher("historyStudent.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading history: " + e.getMessage());
            request.getRequestDispatcher("historyStudent.jsp").forward(request, response);
        }
    }

    private void loadSessions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String date = request.getParameter("date");
        
        if (date == null || date.isEmpty()) {
            request.setAttribute("errorMessage", "Please select a valid date");
            request.getRequestDispatcher("bookAppointmentStudent.jsp").forward(request, response);
            return;
        }

        try {
            // FIXED: Constructor tanpa parameter
            SessionDAO sessionDAO = new SessionDAO();
            // FIXED: Gunakan method baru yang tak perlukan counselorID
            List<Session> sessions = sessionDAO.getSessionsByDate(date);
            
            request.setAttribute("selectedDate", date);
            request.setAttribute("allSessions", sessions);
            request.getRequestDispatcher("bookAppointmentStudent.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading sessions: " + e.getMessage());
            request.getRequestDispatcher("bookAppointmentStudent.jsp").forward(request, response);
        }
    }

    private void bookAppointment(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        try {
            String studentID = request.getParameter("studentID");
            String studentInternalIDStr = request.getParameter("studentInternalID");
            String sessionIDStr = request.getParameter("sessionID");
            String date = request.getParameter("date");
            String reason = request.getParameter("reason");
            
            System.out.println("DEBUG StudentAppointmentController: bookAppointment called");
            System.out.println("DEBUG StudentAppointmentController: studentID=" + studentID);
            System.out.println("DEBUG StudentAppointmentController: studentInternalIDStr=" + studentInternalIDStr);
            System.out.println("DEBUG StudentAppointmentController: sessionIDStr=" + sessionIDStr);
            System.out.println("DEBUG StudentAppointmentController: date=" + date);
            System.out.println("DEBUG StudentAppointmentController: reason=" + reason);

            if (reason == null || reason.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Please provide a reason for your appointment");
                loadSessions(request, response);
                return;
            }

            int studentInternalID = Integer.parseInt(studentInternalIDStr);
            int sessionID = Integer.parseInt(sessionIDStr);

            // FIXED: Constructor tanpa parameter
            SessionDAO sessionDAO = new SessionDAO();
            Session selectedSession = sessionDAO.getSessionById(sessionID);

            if (selectedSession == null || !"available".equalsIgnoreCase(selectedSession.getSessionStatus())) {
                request.setAttribute("errorMessage", "Selected session is not available");
                loadSessions(request, response);
                return;
            }

            // Get counselor ID from the session
            int counselorInternalID = selectedSession.getCounselorID();
            
            System.out.println("DEBUG StudentAppointmentController: studentInternalID=" + studentInternalID);
            System.out.println("DEBUG StudentAppointmentController: sessionID=" + sessionID);
            System.out.println("DEBUG StudentAppointmentController: counselorInternalID from session=" + counselorInternalID);
            
            // FIXED: Gunakan method yang sudah ditambah
            if (counselorInternalID == 0) {
                counselorInternalID = sessionDAO.getDefaultCounselorID();
                System.out.println("DEBUG StudentAppointmentController: Using default counselorID=" + counselorInternalID);
            }
            
            if (counselorInternalID == 0) {
                request.setAttribute("errorMessage", "No counselors available in the system. Please contact administrator.");
                loadSessions(request, response);
                return;
            }

            // Create appointment
            Appointment appointment = new Appointment();
            appointment.setStudentInternalID(studentInternalID);
            appointment.setSessionID(sessionID);
            appointment.setCounselorInternalID(counselorInternalID);
            appointment.setBookingDate(new java.sql.Timestamp(System.currentTimeMillis()));
            appointment.setDescription(reason);
            appointment.setAppointmentStatus("Pending");

            Connection conn = DBConnection.getConnection();
            AppointmentDAO appointmentDAO = new AppointmentDAO(conn);
            boolean success = appointmentDAO.createAppointment(appointment);

            if (success) {
                // Update session status to unavailable
                sessionDAO.updateSessionStatus(sessionID, "unavailable");

                request.setAttribute("successMessage", "Your appointment has been successfully booked! You will receive confirmation from your counselor soon.");
                request.getRequestDispatcher("bookAppointmentStudent.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", "Failed to create appointment. Please try again.");
                loadSessions(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid input format");
            try {
                loadSessions(request, response);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error booking appointment: " + e.getMessage());
            try {
                loadSessions(request, response);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    private void cancelAppointment(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        try {
            int appointmentID = Integer.parseInt(request.getParameter("appointmentID"));
            int sessionID = Integer.parseInt(request.getParameter("sessionID"));
            Student student = getStudentFromSession(session);

            Connection conn = DBConnection.getConnection();
            AppointmentDAO appointmentDAO = new AppointmentDAO(conn);
            // FIXED: Constructor tanpa parameter
            SessionDAO sessionDAO = new SessionDAO();

            // FIXED: Gunakan getStudentIDAsInt() bukan getId()
            boolean success = appointmentDAO.cancelAppointment(appointmentID, student.getStudentIDAsInt(), sessionID, sessionDAO);
            if (success) {
                request.setAttribute("successMessage", "Appointment cancelled successfully.");
            } else {
                request.setAttribute("errorMessage", "Unable to cancel appointment. Please try again.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error cancelling appointment: " + e.getMessage());
        }
        showManageAppointments(request, response, session);
    }

    private void rescheduleAppointment(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        try {
            int appointmentID = Integer.parseInt(request.getParameter("appointmentID"));
            int oldSessionID = Integer.parseInt(request.getParameter("oldSessionID"));
            int newSessionID = Integer.parseInt(request.getParameter("newSessionID"));
            Student student = getStudentFromSession(session);

            Connection conn = DBConnection.getConnection();
            AppointmentDAO appointmentDAO = new AppointmentDAO(conn);
            // FIXED: Constructor tanpa parameter
            SessionDAO sessionDAO = new SessionDAO();

            // FIXED: Gunakan getStudentIDAsInt() bukan getId()
            boolean success = appointmentDAO.rescheduleAppointment(appointmentID, student.getStudentIDAsInt(), oldSessionID, newSessionID, sessionDAO);
            if (success) {
                request.setAttribute("successMessage", "Appointment rescheduled.");
            } else {
                request.setAttribute("errorMessage", "Unable to reschedule. Please pick another slot.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error rescheduling appointment: " + e.getMessage());
        }
        showManageAppointments(request, response, session);
    }

    private void deleteAppointment(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        try {
            int sessionID = Integer.parseInt(request.getParameter("sessionID"));
            Student student = getStudentFromSession(session);

            Connection conn = DBConnection.getConnection();
            AppointmentDAO appointmentDAO = new AppointmentDAO(conn);
            // FIXED: Constructor tanpa parameter
            SessionDAO sessionDAO = new SessionDAO();

            // FIXED: Gunakan getStudentIDAsInt() bukan getId()
            boolean success = appointmentDAO.deleteAppointment(sessionID, student.getStudentIDAsInt(), sessionDAO);
            if (success) {
                request.setAttribute("successMessage", "Appointment deleted.");
            } else {
                request.setAttribute("errorMessage", "Unable to delete appointment.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error deleting appointment: " + e.getMessage());
        }
        showHistory(request, response, session);
    }

    // JSON endpoint for available sessions on a given date
    private void sendAvailableSessionsJson(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String date = request.getParameter("date");
        response.setContentType("application/json");
        try (PrintWriter out = response.getWriter()) {
            if (date == null || date.isEmpty()) {
                out.write("[]");
                return;
            }
            // FIXED: Constructor tanpa parameter
            SessionDAO SessionDAO = new SessionDAO();
            // FIXED: Gunakan method baru yang tak perlukan counselorID
            List<Session> sessions = SessionDAO.getSessionsByDate(date);
            StringBuilder sb = new StringBuilder();
            sb.append("[");
            boolean first = true;
            for (Session s : sessions) {
                if (!"available".equalsIgnoreCase(s.getSessionStatus())) continue;
                if (!first) sb.append(",");
                first = false;
                sb.append("{");
                sb.append("\"sessionID\":").append(s.getSessionID()).append(",");
                sb.append("\"start\":\"").append(s.getStartTime()).append("\",");
                sb.append("\"end\":\"").append(s.getEndTime()).append("\"}");
            }
            sb.append("]");
            out.write(sb.toString());
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("[]");
        }
    }
}