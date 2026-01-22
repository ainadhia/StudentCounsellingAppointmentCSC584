<%@page import="com.counselling.util.DBConnection"%>
<%@page import="com.counselling.model.Counselor"%>
<%@page import="com.counselling.dao.AppointmentDAO"%>
<%@page import="com.counselling.dao.SessionDAO"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    Object userObj = session.getAttribute("user");
    if(userObj == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    if(!(userObj instanceof Counselor)) {
        response.sendRedirect("unauthorized.jsp");
        return;
    }

    Counselor counselor = (Counselor) userObj;
    String fullName = counselor.getFullName();
    int counselorID = counselor.getID();
    
    AppointmentDAO appointmentDAO = new AppointmentDAO(DBConnection.createConnection());
    
    int totalStudents = 0;
    int upcomingAppointments = 0;
    int completedSessions = 0;
    int pendingFollowups = 0;
    
    if (counselorID > 0) {
        try {
            totalStudents = appointmentDAO.getUniqueStudentCount(counselorID);
            upcomingAppointments = appointmentDAO.getTodayBookedCount(counselorID);
            completedSessions = appointmentDAO.getCompletedSessionCount(counselorID);
            pendingFollowups = appointmentDAO.getPendingFollowupCount(counselorID);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Counselor Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="global-style.css">
</head>
    <body>
        <nav class="navbar">
            <div class="navbar-logo"><span class="logo-text">COUNSELOR</span></div>
            <ul class="navbar-menu">
                <li class="active"><a href="counselorDashboard.jsp"><i class="fas fa-home"></i> Dashboard</a></li>
                <li><a href="listOfStudent.jsp"><i class="fas fa-users"></i> List of Students</a></li>
                <li><a href="AppointmentServlet?action=list"><i class="fas fa-calendar-check"></i> Appointment</a></li>
                <li><a href="SessionServlet?action=viewPage"><i class="fas fa-clock"></i> Session</a></li>
                <li class="logout"><a href="LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </nav>

        <div class="main-content">
            <div class="main-header">
                <div class="header-left">
                    <h1>Welcome back, <%= fullName %>!</h1>
                    <p class="welcome-subtitle">Here's what's happening with your counseling activities</p>
                </div>
                <div class="header-date" id="currentDate">
                    <%= new java.text.SimpleDateFormat("EEEE, MMMM d, yyyy").format(new java.util.Date()) %>
                </div>
            </div>

            <div class="cards">
                <div class="card">
                    <div class="card-content">
                        <h3><i class="fas fa-users"></i> Total Students</h3>
                        <div class="card-number"><%= totalStudents %></div>
                        <p class="card-detail">Students assisted</p>
                    </div>
                </div>

                <div class="card">
                    <div class="card-content">
                        <h3><i class="fas fa-calendar-check"></i> Upcoming</h3>
                        <div class="card-number"><%= upcomingAppointments %></div>
                        <p class="card-detail">Appointments scheduled</p>
                    </div>
                </div>

                <div class="card">
                    <div class="card-content">
                        <h3><i class="fas fa-check-circle"></i> Completed</h3>
                        <div class="card-number"><%= completedSessions %></div>
                        <p class="card-detail">Sessions completed</p>
                    </div>
                </div>

                <div class="card">
                    <div class="card-content">
                        <h3><i class="fas fa-clock"></i> Pending</h3>
                        <div class="card-number"><%= pendingFollowups %></div>
                        <p class="card-detail">Need counselling</p>
                    </div>
                </div>
            </div>

            <div class="content-section">
                <div class="section-header">
                    <h2><i class="fas fa-calendar-day"></i> Today's Sessions</h2>
                    <span class="badge"><%= new java.text.SimpleDateFormat("EEEE, dd MMM yyyy").format(new java.util.Date()) %></span>
                </div>
                <div class="session-history">
                    <%
                        List<Map<String, Object>> todaysSessions = null;
                        try {
                            todaysSessions = appointmentDAO.getRecentSessions(counselorID);
                            System.out.println("Dashboard - Total sessions: " + (todaysSessions != null ? todaysSessions.size() : 0));
                        } catch (Exception e) {
                            e.printStackTrace();
                        }

                        if (todaysSessions != null && !todaysSessions.isEmpty()) {
                            int sessionCount = 0;
                            for (Map<String, Object> sess : todaysSessions) {
                                String appointmentStatus = (String) sess.get("appointmentStatus");
                                String sessionStatus = (String) sess.get("sessionStatus");

                                if ("cancelled".equalsIgnoreCase(appointmentStatus)) {
                                    continue;
                                }

                                sessionCount++;

                                String studentName = (String) sess.get("studentName");
                                Integer studentID = (Integer) sess.get("studentID");

                                System.out.println("Display Session - Student: " + studentName + ", ID: " + studentID);
                    %>
                    <div class="session-item">
                        <div class="session-time-badge">
                            <i class="fas fa-clock"></i>
                            <span><%= sess.get("startTime") %></span>
                        </div>
                        <div class="session-details">
                            <div class="session-header">
                                <h4>
                                    <i class="fas fa-user"></i> 
                                    <%= studentName != null && !studentName.isEmpty() ? studentName : "Student #" + studentID %>
                                </h4>
                                <span class="session-status-badge 
                                    <%= "Pending".equalsIgnoreCase(appointmentStatus) ? "status-booked" : 
                                       "completed".equalsIgnoreCase(appointmentStatus) ? "status-completed" : 
                                       "available".equalsIgnoreCase(sessionStatus) ? "status-available" : "status-other" %>">
                                    <%= 
                                        "Pending".equalsIgnoreCase(appointmentStatus) ? "PENDING" :
                                        "completed".equalsIgnoreCase(appointmentStatus) ? "COMPLETED" :
                                        "available".equalsIgnoreCase(sessionStatus) ? "AVAILABLE" :
                                        appointmentStatus != null ? appointmentStatus.toUpperCase() : "SCHEDULED"
                                    %>
                                </span>
                            </div>

                            <div class="session-info">
                                <p><i class="far fa-clock"></i> <strong>Time:</strong> <%= sess.get("startTime") %> - <%= sess.get("endTime") %></p>
                                <p><i class="fas fa-info-circle"></i> <strong>Status:</strong> 
                                    <%= appointmentStatus != null ? appointmentStatus : sessionStatus %>
                                </p>

                                <% if (studentID != null && studentID > 0 && !"available".equalsIgnoreCase(sessionStatus)) { %>
                                <div class="session-actions">
                                    <% if ("Pending".equalsIgnoreCase(appointmentStatus)) { %>
                                    <button class="btn-small btn-mark-complete" 
                                            onclick="window.location.href='AppointmentServlet?action=complete&id=<%= sess.get("ID") %>'">
                                        <i class="fas fa-check"></i> Mark Complete
                                    </button>
                                    <% } %>
                                </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                    <%
                            }

                            if (sessionCount == 0) {
                    %>
                    <div class="empty-state">
                        <i class="fas fa-calendar-times"></i>
                        <h4>All Sessions Cancelled</h4>
                        <p>All sessions for today have been cancelled.</p>
                    </div>
                    <%
                            }
                        } else {
                    %>
                    <div class="session-item">
                        <div class="session-details">
                            <h4><i class="fas fa-info-circle"></i> No Today's Appointments</h4>
                            <p>No appointments scheduled for today.</p>
                        </div>
                    </div>
                    <%
                        }
                    %>
                </div>
            </div>

            <div class="content-section">
                <div class="section-header">
                    <h2><i class="fas fa-calendar-alt"></i> Upcoming Appointments</h2>
                </div>
                <div class="session-history">
                    <%
                        List<Map<String, Object>> upcomingApps = null;
                        try {
                            upcomingApps = appointmentDAO.getUpcomingAppointments(counselorID, 5);
                            System.out.println("Upcoming appointments: " + (upcomingApps != null ? upcomingApps.size() : 0));
                        } catch (Exception e) {
                            e.printStackTrace();
                        }

                        if (upcomingApps != null && !upcomingApps.isEmpty()) {
                            for (Map<String, Object> appt : upcomingApps) {
                                String studentName = (String) appt.get("STUDENTNAME");
                                Integer studentID = (Integer) appt.get("STUDENTID");
                                java.sql.Date bookedDate = (java.sql.Date) appt.get("BOOKEDDATE");

                                System.out.println("Upcoming - Student: " + studentName + ", ID: " + studentID);
                    %>
                    <div class="session-item">
                        <div class="session-date">
                            <span class="date-day">
                                <%= bookedDate.toLocalDate().getDayOfMonth() %>
                            </span>
                            <span class="date-month">
                                <%= bookedDate.toLocalDate().getMonth().toString().substring(0, 3).toUpperCase() %>
                            </span>
                        </div>
                        <div class="session-details">
                            <h4>
                                <i class="fas fa-user"></i> 
                                <%= studentName != null && !studentName.isEmpty() ? studentName : "Student #" + studentID %>
                            </h4>
                            <p><strong>Date:</strong> <%= bookedDate %></p>
                            <p><strong>Description:</strong> <%= appt.get("DESCRIPTION") %></p>
                            <span class="session-status scheduled">
                                <i class="fas fa-calendar-check"></i> <%= appt.get("APPOINTMENTSTATUS") %>
                            </span>
                        </div>
                    </div>
                    <%
                            }
                        } else {
                    %>
                    <div class="session-item">
                        <div class="session-details">
                            <h4><i class="fas fa-info-circle"></i> No Upcoming Appointments</h4>
                            <p>No upcoming appointments scheduled.</p>
                        </div>
                    </div>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>
    </body>
</html>