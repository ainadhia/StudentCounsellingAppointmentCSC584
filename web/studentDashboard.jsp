<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.counselling.model.Student" %>
<%
    Student student = (Student) session.getAttribute("user");
    if (student == null || !"S".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard | UiTM Counselling</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="global-style.css">
    <style>
        .dashboard-container {
            max-width: 1000px;
            margin: 40px auto;
            padding: 0 20px;
        }
        .welcome-section {
            background: linear-gradient(135deg, #42145F 0%, #5D2E8C 100%);
            color: white;
            padding: 40px;
            border-radius: 20px;
            margin-bottom: 30px;
            box-shadow: 0 10px 25px rgba(66, 20, 95, 0.15);
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 15px;
            border: 1px solid #e6e1f7;
            display: flex;
            align-items: center;
            gap: 20px;
            transition: transform 0.3s;
        }
        .stat-card:hover { transform: translateY(-5px); }
        .stat-icon {
            width: 50px;
            height: 50px;
            background: #f0ebfa;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #5D2E8C;
            font-size: 1.5em;
        }
        .quick-actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }
        .action-btn {
            background: white;
            border: 2px solid #5D2E8C;
            color: #5D2E8C;
            padding: 20px;
            border-radius: 15px;
            text-decoration: none;
            font-weight: 700;
            text-align: center;
            transition: 0.3s;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 10px;
        }
        .action-btn:hover {
            background: #5D2E8C;
            color: white;
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="navbar-header">
            <h2>UiTM Counselling</h2>
        </div>
        <ul class="navbar-menu">
            <li class="active"><a href="studentDashboard.jsp"><i class="fas fa-home"></i> Home</a></li>
            <li><a href="viewStudent.jsp?id=<%= student.getStudentID() %>"><i class="fas fa-user"></i> Profile</a></li>
            <li><a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
        </ul>
    </nav>

    <div class="dashboard-container">
        <div class="welcome-section">
            <h1>Welcome back, <%= student.getFullName() %>!</h1>
            <p>Your mental well-being is our priority. How can we help you today?</p>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon"><i class="fas fa-calendar-check"></i></div>
                <div>
                    <h3 style="margin:0;">Next Appointment</h3>
                    <p style="color:#636e72; margin:5px 0 0;">None scheduled</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon"><i class="fas fa-id-card"></i></div>
                <div>
                    <h3 style="margin:0;">Student ID</h3>
                    <p style="color:#636e72; margin:5px 0 0;"><%= student.getStudentID() %></p>
                </div>
            </div>
        </div>

        <h2 style="color:#42145F; margin-bottom:20px;">Quick Actions</h2>
        <div class="quick-actions">
            <a href="#" class="action-btn">
                <i class="fas fa-calendar-plus fa-2x"></i>
                Book Appointment
            </a>
            <a href="#" class="action-btn">
                <i class="fas fa-history fa-2x"></i>
                Session History
            </a>
            <a href="viewStudent.jsp?id=<%= student.getStudentID() %>" class="action-btn">
                <i class="fas fa-user-edit fa-2x"></i>
                Update Profile
            </a>
        </div>
    </div>
</body>
</html>
