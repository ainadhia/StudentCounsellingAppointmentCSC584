<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="com.counselling.model.Student"%>
<%@page import="com.counselling.model.RecentSession"%>

<%
    Object obj = session.getAttribute("user");
    if (obj == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Student student = (Student) obj;

    String displayName = (student.getFullName() != null && !student.getFullName().trim().isEmpty())
            ? student.getFullName()
            : student.getUserName();

    String studentId = student.getStudentID();
    if (studentId == null || studentId.trim().isEmpty()) studentId = student.getUserName();

    String faculty = (student.getFaculty() != null) ? student.getFaculty() : "-";
    String program = (student.getProgram() != null) ? student.getProgram() : "-";

    int upcoming = (request.getAttribute("upcoming") == null) ? 0 : (Integer) request.getAttribute("upcoming");
    int completed = (request.getAttribute("complete") == null) ? 0 : (Integer) request.getAttribute("complete");
    int pending = (request.getAttribute("Pending") == null) ? 0 : (Integer) request.getAttribute("Pending");

    List<RecentSession> recent = (List<RecentSession>) request.getAttribute("recentSessions");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/student.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>

    <nav class="navbar">
        <div class="navbar-logo">
            <span class="logo-text">UITM COUNSELLING</span>
        </div>
        <ul class="navbar-menu">
            <li  class="active"><a  href="<%=request.getContextPath()%>/StudentDashboardServlet"><span class="menu-text" style="font-size: 0.85rem;">| Dashboard</span></a></li>
            <li><a href="bookAppointmentStudent.jsp"><span class="menu-text" style="font-size: 0.85rem;">| Book Appointment</span></a></li>
            <li><a href="StudentAppointmentServlet?action=manage"><span class="menu-text" style="font-size: 0.85rem;">| Manage Appointments</span></a></li>
            <li><a href="StudentAppointmentServlet?action=history"><span class="menu-text" style="font-size: 0.85rem;">| History</span></a></li>
            <li><a href="<%=request.getContextPath()%>/StudentProfileServlet"><span class="menu-text" style="font-size: 0.85rem;">| Profile</span></a></li>
            <li><a href="<%=request.getContextPath()%>/LogoutServlet"><span class="menu-text" style="font-size: 0.85rem;">| Logout</span></a></li>
        </ul>
    </nav>

<!-- MAIN CONTENT (NO SIDEBAR) -->
<div class="main-content">

    <header class="main-header">
        <div>
            <h1>Welcome, <%= displayName %>!</h1>
            <p class="welcome-subtitle">Here's your counseling activity summary</p>
           
        </div>
        <!-- tarikh kanan dibuang -->
    </header>

    <div class="cards">
        <div class="card">
            <div class="card-content">
                <h3>Upcoming Appointment</h3>
                <p class="card-number"><%= upcoming %></p>
            </div>
        </div>

        <div class="card">
            <div class="card-content">
                <h3>Completed Session</h3>
                <p class="card-number"><%= completed %></p>
            </div>
        </div>

        <div class="card">
            <div class="card-content">
                <h3>Pending</h3>
                <p class="card-number"><%= pending %></p>
            </div>
        </div>
    </div>

    <div class="content-section">
        <div class="section-header">
            <h2>Recent Completed Sessions</h2>

            <a href="<%=request.getContextPath()%>/StudentAppointmentServlet?action=history" class="view-all">View Full History →</a>
        </div>

        <div class="session-history">
            <%
                if (recent != null && !recent.isEmpty()) {
                    for (RecentSession r : recent) {
                        String status = (r.getStatus() != null) ? r.getStatus() : "-";
                        String statusLower = status.toLowerCase();

String statusClass = "scheduled";
if (statusLower.contains("complete")) statusClass = "complete";
else if (statusLower.contains("pending")) statusClass = "pending";
else if (statusLower.contains("cancel")) statusClass = "cancel";


                        String day = "--", mon = "---";
                        try {
                            java.util.Date d = r.getBookedDate();
                            if (d != null) {
                                day = new java.text.SimpleDateFormat("dd").format(d);
                                mon = new java.text.SimpleDateFormat("MMM").format(d);
                            }
                        } catch (Exception ex) {}
            %>

            <div class="session-item">
                <div class="session-date">
                    <span class="date-day"><%= day %></span>
                    <span class="date-month"><%= mon %></span>
                </div>

                <div class="session-details">
                    <h4><%= (r.getDescription() != null ? r.getDescription() : "Counseling Session") %></h4>
                    <p><strong>Counselor:</strong> <%= (r.getCounselorId() != null ? r.getCounselorId() : "-") %></p>
                    <p><strong>Room:</strong> <%= (r.getRoomNo() != null ? r.getRoomNo() : "-") %></p>
                    <p><strong>Time:</strong>
                        <%= (r.getStartTime() != null ? r.getStartTime() : "-") %> -
                        <%= (r.getEndTime() != null ? r.getEndTime() : "-") %>
                    </p>

                    <span class="session-status <%= statusClass %>"><%= status %></span>
                </div>
            </div>

            <%
                    }
                } else {
            %>
                <p class="muted">No completed sessions yet.</p>


            <%
                }
            %>
        </div>
    </div>

</div>
</body>
</html>
