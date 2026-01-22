<!DOCTYPE html>
<!--
To change this license header, choose License Headers in Project Properties.
To change this template file, choose Tools | Templates
and open the template in the editor.
-->
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Appointment Details</title>
    <link rel="stylesheet" href="global-style.css">
    <style>
        .details-container {
            max-width: 800px;
            margin: 50px auto;
            padding: 30px;
            background: white;
            border-radius: 15px;
            box-shadow: 0 8px 25px rgba(203, 149, 232, 0.12);
        }
        
        .details-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        
        .details-table td {
            padding: 12px 15px;
            border-bottom: 1px solid #eee;
        }
        
        .details-table td:first-child {
            font-weight: 600;
            color: #5D2E8C;
            width: 30%;
        }
        
        .status-badge {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.9em;
            font-weight: 600;
        }
        
        .status-pending { background: #fff3cd; color: #856404; }
        .status-booked { background: #d1ecf1; color: #0c5460; }
        .status-complete { background: #d4edda; color: #155724; }
        .status-cancelled { background: #f8d7da; color: #721c24; }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="navbar-logo"><span class="logo-text">COUNSELOR SYSTEM</span></div>
        <ul class="navbar-menu">
            <li><a href="counselorDashboard.jsp">Dashboard</a></li>
            <li><a href="StudentServlet?action=list">List of Students</a></li>
            <li><a href="AppointmentServlet?action=list">Appointment</a></li>
            <li><a href="SessionServlet?action=viewPage">Session</a></li>
            <li class="logout"><a href="LogoutServlet">Logout</a></li>
        </ul>
    </nav>
    
    <div class="main-content">
        <div class="main-header">
            <h1>Appointment Details</h1>
            <a href="AppointmentServlet?action=list" class="btn-back">← Back to List</a>
        </div>
        
        <c:if test="${not empty appointment}">
            <div class="details-container">
                <h2>Appointment #${appointment.ID}</h2>
                
                <table class="details-table">
                    <tr>
                        <td>Appointment ID:</td>
                        <td>${appointment.ID}</td>
                    </tr>
                    <tr>
                        <td>Student ID:</td>
                        <td>${appointment.studentID}</td>
                    </tr>
                    <tr>
                        <td>Student Name:</td>
                        <td>${studentNameMap[apt.ID]}</td>
                    </tr>
                    <td>Status:</td>
                        <td>
                            <span class="status-badge status-${appointment.appointmentStatus}">
                                ${appointment.appointmentStatus}
                            </span>
                    </td>
                    </tr>
                    <tr>
                        <td>Date:</td>
                        <td><fmt:formatDate value="${appointment.bookedDate}" pattern="dd/MM/yyyy"/></td>
                    </tr>
                    <tr>
                        <td>Description:</td>
                        <td>${appointment.description}</td>
                    </tr>
                    <c:if test="${appointment.sessionID > 0}">
                    <tr>
                        <td>Session ID:</td>
                        <td>${appointment.sessionID}</td>
                    </tr>
                    </c:if>
                    <tr>
                        <td>Counselor ID:</td>
                        <td>${appointment.counselorID}</td>
                    </tr>
                </table>
            </div>
        </c:if>
        
        <c:if test="${empty appointment}">
            <div class="details-container">
                <p style="text-align: center; color: #666;">Appointment not found.</p>
            </div>
        </c:if>
    </div>
</body>
</html>

