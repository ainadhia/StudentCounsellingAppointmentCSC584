<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    if (request.getAttribute("studentList") == null) {
        request.getRequestDispatcher("/ListStudents").forward(request, response);
        return; 
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Student Directory | UiTM Counselling</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/global-style.css">
        <style>
            .success-banner { 
                background: #e8f5e9; 
                color: #2e7d32; 
                padding: 15px; 
                border-radius: 10px; 
                border: 1px solid #2e7d32; 
                margin-bottom: 25px; 
                font-weight: bold; 
                text-align: center;
                font-size: 0.9em;
            }

            .student-list-container {
                width: 100%;
                margin-top: 20px;
            }

            .student-list-item {
                display: flex;
                align-items: center;
                justify-content: space-between;
                background: white;
                padding: 15px 30px;
                border-radius: 15px;
                margin-bottom: 12px;
                border: 1px solid #f0ebfa;
                transition: all 0.3s ease;
                box-shadow: 0 4px 12px rgba(203, 149, 232, 0.08);
            }

            .student-list-item:hover {
                transform: translateX(10px);
                border-color: #CB95E8;
                box-shadow: 0 8px 20px rgba(203, 149, 232, 0.15);
            }

            .student-info-wrapper {
                display: flex;
                align-items: center;
                gap: 20px;
                flex: 1;
            }

            .student-name-container {
                display: flex;
                flex-direction: column;
            }

            .student-name-text {
                color: #5D2E8C;
                font-weight: 600;
                font-size: 1.1em;
            }

            .student-id-text {
                color: #8B7BA6;
                font-size: 0.9em;
                font-family: 'Courier New', Courier, monospace;
            }

            .btn-view-profile {
                background: #f8f7fc;
                color: #5D2E8C;
                border: 2px solid #e6e1f7;
                padding: 10px 20px;
                border-radius: 25px;
                text-decoration: none;
                font-weight: 600;
                font-size: 0.9em;
                display: flex;
                align-items: center;
                gap: 8px;
                transition: all 0.3s ease;
                white-space: nowrap;
            }

            .btn-view-profile:hover {
                background: linear-gradient(135deg, #CB95E8 0%, #A56CD1 100%);
                color: white;
                border-color: transparent;
                box-shadow: 0 4px 12px rgba(165, 108, 209, 0.3);
            }
        </style>
    </head>
    <body>

        <nav class="navbar">
                <div class="navbar-logo"><span class="logo-text">COUNSELOR</span></div>
                <ul class="navbar-menu">
                    <li><a href="counselorDashboard.jsp"><i class="fas fa-home"></i> Dashboard</a></li>
                    <li class="active"><a href="listOfStudent.jsp"><i class="fas fa-users"></i> List of Students</a></li>
                    <li><a href="AppointmentServlet?action=list"><i class="fas fa-calendar-check"></i> Appointment</a></li>
                    <li><a href="SessionServlet?action=viewPage"><i class="fas fa-clock"></i> Session</a></li>
                    <li class="logout"><a href="LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
                </ul>
            </nav>

        <div class="main-content">
            <div class="main-header">
                <div>
                    <h1>Student Directory</h1>
                    <p class="welcome-subtitle">List of all registered students in the system.</p>
                </div>
                <div class="header-date">
                    <%= new java.text.SimpleDateFormat("EEEE, MMMM d, yyyy").format(new java.util.Date()) %>
                </div>
            </div>

            <%-- Updated check for loginSuccess parameter from LoginServlet --%>
            <c:if test="${param.loginSuccess == 'true'}">
                <div class="success-banner">
                    <i class="fas fa-check-circle"></i> Login successful! Welcome back.
                </div>
            </c:if>

            <section class="content-section">
                <div class="section-header">
                    <h4><i class="fas fa-list-ul"></i> Enrolled Students List</h4>
                </div>

                <c:if test="${empty studentList}">
                    <div class="no-sessions" style="text-align: center; padding: 40px;">
                        <i class="fas fa-search" style="font-size: 3em; color: #ccc;"></i>
                        <h3>No students found</h3>
                        <p>There are currently no student records available in the database.</p>
                    </div>
                </c:if>

                <div class="student-list-container">
                    <c:forEach var="student" items="${studentList}">
                        <div class="student-list-item">
                            <div class="student-info-wrapper">
                                <div class="avatar" style="width: 40px; height: 40px; font-size: 1.2em;">
                                    <i class="fas fa-user"></i>
                                </div>
                                <div class="student-name-container">
                                    <span class="student-name-text">${student.fullname}</span>
                                    <span class="student-id-text">ID: ${student.studentID}</span>
                                </div>
                            </div>

                            <div class="action-wrapper">
                                <a href="viewStudent.jsp?id=${student.studentID}" class="btn-view-profile">
                                    <i class="fas fa-eye"></i> View Profile
                                </a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </section>
        </div>
    </body>
</html>