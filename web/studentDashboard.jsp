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
    int completed = (request.getAttribute("completed") == null) ? 0 : (Integer) request.getAttribute("completed");
    int pending = (request.getAttribute("pending") == null) ? 0 : (Integer) request.getAttribute("pending");

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

<!-- NAVBAR (KEKAL) -->
<div class="navbar">
    <div class="navbar-header">
        <h2>UiTM Counselling</h2>
    </div>

    <ul class="navbar-menu">
        <li class="active">
            <a href="<%=request.getContextPath()%>/StudentDashboardServlet">
                <span class="menu-text">
                            <span>|</span>
                            <span>Dashboard</span>
                        </span>
            </a>
        </li>

        <li class="dropdown">
            <a href="#"><span class="menu-text">
                <span>|</span>
                    <span>Appointment</span>
                </span></i>  
                <i class="fa-solid fa-caret-down"></i></a>
            <ul class="dropdown-menu">
                <li><a href="<%=request.getContextPath()%>/StudentAppointmentServlet">Manage Appointment</a></li>
            </ul>
        </li>

        <li><a href="<%=request.getContextPath()%>/StudentHistoryServlet">
                <span class="menu-text">
                            <span>|</span>
                            <span>History</span>
                </span>
            </a>
        </li>
        <li><a href="<%=request.getContextPath()%>/StudentProfileServlet">
                <span class="menu-text">
                            <span>|</span>
                            <span>Profile</span>
                        </span>
           </a>
        </li>
        <li class="logout"><a href="<%=request.getContextPath()%>/LogoutServlet">
             <span class="menu-text">
                            <span>|</span>
                            <span>Logout</span>
                        </span>   
            
            </a>
        </li>
    </ul>
</div>

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
            <h2>Recent Sessions</h2>
            <a href="<%=request.getContextPath()%>/StudentHistoryServlet" class="view-all">View Full History →</a>
        </div>

        <div class="session-history">
            <%
                if (recent != null && !recent.isEmpty()) {
                    for (RecentSession r : recent) {
                        String status = (r.getStatus() != null) ? r.getStatus() : "-";
                        String statusLower = status.toLowerCase();

                        String statusClass = "scheduled";
                        if (statusLower.contains("complete")) statusClass = "completed";
                        else if (statusLower.contains("pending")) statusClass = "scheduled";
                        else if (statusLower.contains("cancel")) statusClass = "cancelled";

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
                <p class="muted">No sessions today.</p>

            <%
                }
            %>
        </div>
    </div>

</div>
</body>
</html>
