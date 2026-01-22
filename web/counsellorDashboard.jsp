<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.counselling.model.Counselor" %>
<%
    Counselor counselor = (Counselor) session.getAttribute("user");
    if (counselor == null || !"C".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Counselor Dashboard</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/global-style.css">
</head>
<body>
    <nav class="navbar">
        <div class="navbar-logo">
            <span class="logo-text">COUNSELOR SYSTEM</span>
        </div>

        <ul class="navbar-menu">
            <li class="active">
                <a href="counsellorDashboard.jsp">
                    <span class="menu-text">
                        <span>|</span>
                        <span>Dashboard</span>
                    </span>
                </a>
            </li>
            <li>
                <a href="listOfStudent.jsp">
                    <span class="menu-text">
                        <span>|</span>
                        <span>List of Students</span>
                    </span>
                </a>
            </li>
            <li>
                <a href="AppointmentController">
                    <span class="menu-text">
                        <span>|</span>
                        <span>Appointment</span>
                    </span>
                </a>
            </li>
            <li>
                <a href="sessionEditCounsellor.jsp">
                    <span class="menu-text">
                        <span>|</span>
                        <span>Session</span>
                    </span>
                </a>
            </li>
            <li class="logout">
                <a href="logout.jsp">
                    <span class="menu-text">
                        <span>|</span>
                        <span>Logout</span>
                    </span>
                </a>
            </li>
        </ul>
    </nav>

    <!-- MAIN CONTENT -->
    <div class="main-content">
        <!-- Header -->
        <div class="main-header">
            <div>
                <h1>Welcome back, <%= counselor.getFullName() %>! 👋</h1>
                <p class="welcome-subtitle">Here's what's happening with your students today</p>
            </div>
            <div class="header-date">
                <%= new java.text.SimpleDateFormat("EEEE, MMMM d, yyyy").format(new java.util.Date()) %>
            </div>
        </div>

        <!-- Cards -->
        <div class="cards">
            <div class="card">
                <div class="card-icon">👥</div>
                <div class="card-content">
                    <h3>Total Students</h3>
                    <div class="card-number">25</div>
                    <p class="card-detail">Active cases</p>
                </div>
            </div>
            <div class="card">
                <div class="card-icon">📅</div>
                <div class="card-content">
                    <h3>Upcoming</h3>
                    <div class="card-number">5</div>
                    <p class="card-detail">Appointments this week</p>
                </div>
            </div>
            <div class="card">
                <div class="card-icon">✅</div>
                <div class="card-content">
                    <h3>Completed</h3>
                    <div class="card-number">12</div>
                    <p class="card-detail">Sessions this month</p>
                </div>
            </div>
            <div class="card">
                <div class="card-icon">⏳</div>
                <div class="card-content">
                    <h3>Pending</h3>
                    <div class="card-number">3</div>
                    <p class="card-detail">Follow-ups needed</p>
                </div>
            </div>
        </div>

        <!-- Recent Sessions -->
        <div class="content-section">
            <div class="section-header">
                <h2>Recent Sessions</h2>
                <a href="#" class="view-all">View All →</a>
            </div>
            <div class="session-history">
                <div class="session-item">
                    <div class="session-date">
                        <span class="date-day">15</span>
                        <span class="date-month">DEC</span>
                    </div>
                    <div class="session-details">
                        <h4>Individual Counseling - Ahmad Zaki</h4>
                        <p><strong>Time:</strong> 10:00 AM - 11:00 AM</p>
                        <p><strong>Topic:</strong> Academic Stress Management</p>
                        <span class="session-status completed">Completed</span>
                    </div>
                </div>
                <div class="session-item">
                    <div class="session-date">
                        <span class="date-day">14</span>
                        <span class="date-month">DEC</span>
                    </div>
                    <div class="session-details">
                        <h4>Group Session - Year 2 Students</h4>
                        <p><strong>Time:</strong> 2:00 PM - 3:30 PM</p>
                        <p><strong>Topic:</strong> Peer Relationship Building</p>
                        <span class="session-status completed">Completed</span>
                    </div>
                </div>
                <div class="session-item">
                    <div class="session-date">
                        <span class="date-day">13</span>
                        <span class="date-month">DEC</span>
                    </div>
                    <div class="session-details">
                        <h4>Individual Counseling - Siti Nurhaliza</h4>
                        <p><strong>Time:</strong> 11:00 AM - 12:00 PM</p>
                        <p><strong>Topic:</strong> Family Issues Discussion</p>
                        <span class="session-status completed">Completed</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Upcoming Appointments -->
        <div class="content-section">
            <div class="section-header">
                <h2>Upcoming Appointments</h2>
                <a href="cAppointment.html" class="view-all">View All →</a>
            </div>
            <div class="session-history">
                <div class="session-item">
                    <div class="session-date">
                        <span class="date-day">16</span>
                        <span class="date-month">DEC</span>
                    </div>
                    <div class="session-details">
                        <h4>Individual Counseling - Lim Wei Jie</h4>
                        <p><strong>Time:</strong> 9:00 AM - 10:00 AM</p>
                        <p><strong>Topic:</strong> Career Guidance</p>
                        <span class="session-status">Scheduled</span>
                    </div>
                </div>
                <div class="session-item">
                    <div class="session-date">
                        <span class="date-day">16</span>
                        <span class="date-month">DEC</span>
                    </div>
                    <div class="session-details">
                        <h4>Follow-up Session - Ahmad Zaki</h4>
                        <p><strong>Time:</strong> 2:00 PM - 3:00 PM</p>
                        <p><strong>Topic:</strong> Progress Check-in</p>
                        <span class="session-status">Scheduled</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Display current date
        function updateDate() {
            const dateElement = document.getElementById('currentDate');
            const now = new Date();
            const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
            dateElement.textContent = now.toLocaleDateString('en-US', options);
        }

        // Toggle submenu
        function toggleSubmenu(event) {
            event.preventDefault();
            const parentLi = event.currentTarget.parentElement;
            const submenu = parentLi.querySelector('.submenu');
            const arrow = parentLi.querySelector('.arrow');
            
            // Toggle active class
            submenu.classList.toggle('active');
            arrow.classList.toggle('rotate');
        }

        // Initialize
        updateDate();
    </script>
</body>
</html>