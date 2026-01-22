<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%

    if (request.getAttribute("student") == null) {
        String studentID = request.getParameter("id");
        if (studentID != null) {
            // Forward to the servlet to get the data
            request.getRequestDispatcher("/viewStudent").forward(request, response);
            return; 
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Student Profile | UiTM Counselling</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="global-style.css">
    <style>
        /* Specific Profile Page Styling */
        .profile-card-detailed {
            max-width: 600px;
            margin: 20px auto;
            background: white;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 15px 35px rgba(81, 36, 92, 0.1);
            border: 2px solid #f0ebfa;
        }

        .profile-banner {
            background: linear-gradient(135deg, #51245C 0%, #3d1b47 100%);
            height: 100px;
            position: relative;
        }

        .profile-image-container {
            width: 100px;
            height: 100px;
            background: linear-gradient(135deg, #CB95E8 0%, #A56CD1 100%);
            border: 5px solid white;
            border-radius: 50%;
            position: absolute;
            bottom: -50px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2.5em;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }

        .profile-content {
            padding: 70px 40px 40px;
            text-align: center;
        }

        .profile-content h2 {
            color: #51245C;
            font-size: 1.8em;
            margin-bottom: 5px;
        }

        .profile-content .student-id-badge {
            display: inline-block;
            background: #f0ebfa;
            color: #8a4ec7;
            padding: 5px 15px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.9em;
            margin-bottom: 30px;
        }

        .detail-grid {
            text-align: left;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 15px;
            background: #f8f7fc;
            border-radius: 12px;
            border: 1px solid #f0ebfa;
            transition: all 0.3s ease;
        }

        .detail-row:hover {
            border-color: #CB95E8;
            background: white;
            transform: translateX(5px);
        }

        .detail-label {
            color: #8B7BA6;
            font-weight: 600;
            font-size: 0.9em;
            text-transform: uppercase;
        }

        .detail-value {
            color: #51245C;
            font-weight: 500;
        }

        .profile-actions {
            margin-top: 40px;
            display: flex;
            gap: 15px;
        }

        .btn-full {
            flex: 1;
            text-decoration: none;
            padding: 15px;
            border-radius: 12px;
            font-weight: 600;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            transition: all 0.3s ease;
        }

        .btn-outline {
            background: white;
            color: #51245C;
            border: 2px solid #e6e1f7;
        }

        .btn-outline:hover {
            background: #f0ebfa;
            border-color: #CB95E8;
            transform: translateY(-2px);
        }
    </style>
</head>
<body>

    <nav class="navbar">
        <div class="navbar-logo">
            <span class="logo-text">COUNSELOR SYSTEM</span>
        </div>

        <ul class="navbar-menu">
            <li>
                <a href="counsellorDashboard.jsp">
                    <span class="menu-text">
                        <span>|</span>
                        <span>Dashboard</span>
                    </span>
                </a>
            </li>
            <li class="active">
                <a href="listOfStudent.jsp">
                    <span class="menu-text">
                        <span>|</span>
                        <span>List of Students</span>
                    </span>
                </a>
            </li>
            <li>
                <a href="bookAppointmentCounsellor.jsp">
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

    <div class="main-content">
        <div class="main-header">
            <div>
                <h1>Student Profile</h1>
                <p class="welcome-subtitle">Detailed information for counseling reference.</p>
            </div>
            <div class="header-date">
                <%= new java.text.SimpleDateFormat("EEEE, MMMM d, yyyy").format(new java.util.Date()) %>
            </div>
        </div>

        <div class="profile-card-detailed">
            <div class="profile-banner">
                <div class="profile-image-container">
                    <i class="fas fa-user-graduate"></i>
                </div>
            </div>
            
            <div class="profile-content">
                <h2>${student.fullName}</h2>
                <span class="student-id-badge">ID: ${student.studentID}</span>

                <div class="detail-grid">
                    <div class="detail-row">
                        <span class="detail-label">Email Address</span>
                        <span class="detail-value">${student.userEmail}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Phone Number</span>
                        <span class="detail-value">${student.userPhoneNum}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Faculty</span>
                        <span class="detail-value">${student.faculty}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Academic Program</span>
                        <span class="detail-value">${student.program}</span>
                    </div>
                </div>

                <div class="profile-actions">
                    <a href="ListStudents" class="btn-full btn-outline">
                        <i class="fas fa-arrow-left"></i> Back to List
                    </a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>