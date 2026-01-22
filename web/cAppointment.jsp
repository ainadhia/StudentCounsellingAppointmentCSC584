<%@page import="com.counselling.model.Counselor"%>
<%@page import="com.counselling.dao.SessionDAO"%>
<%@page import="com.counselling.dao.AppointmentDAO"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%
    Object userObj = session.getAttribute("user");
    if(userObj == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    if(!(userObj instanceof com.counselling.model.Counselor)) {
        response.sendRedirect("unauthorized.jsp");
        return;
    }
    
    Counselor counselor = (Counselor) userObj;
    String fullName = counselor.getFullName();
    
    int counselorID = counselor.getID();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Appointment Management</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="global-style.css">
    <style>
        .action-modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 9999;
            justify-content: center;
            align-items: center;
        }
        
        .action-modal {
            background: white;
            border-radius: 20px;
            padding: 40px;
            max-width: 450px;
            text-align: center;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            animation: slideIn 0.3s ease;
        }
        
        @keyframes slideIn {
            from { transform: translateY(-50px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
        
        .modal-icon {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            animation: scaleIn 0.5s ease;
        }
        
        .modal-icon.success {
            background: linear-gradient(135deg, #4CAF50, #45a049);
        }
        
        .modal-icon.warning {
            background: linear-gradient(135deg, #ff9800, #f57c00);
        }
        
        @keyframes scaleIn {
            0% { transform: scale(0); }
            50% { transform: scale(1.1); }
            100% { transform: scale(1); }
        }
        
        .modal-icon i {
            color: white;
            font-size: 40px;
        }
        
        .action-modal h3 {
            margin-bottom: 15px;
            font-size: 24px;
        }
        
        .action-modal p {
            color: #666;
            margin-bottom: 25px;
            font-size: 16px;
        }
        
        .modal-buttons {
            display: flex;
            gap: 10px;
            justify-content: center;
        }
        
        .modal-btn {
            padding: 12px 30px;
            border: none;
            border-radius: 25px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .modal-btn-confirm {
            background: linear-gradient(135deg, #4CAF50, #45a049);
            color: white;
        }
        
        .modal-btn-cancel-action {
            background: linear-gradient(135deg, #f44336, #d32f2f);
            color: white;
        }
        
        .modal-btn-secondary {
            background: #f5f5f5;
            color: #666;
        }
        
        .modal-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        }
    </style>
</head>
    <body>
        <nav class="navbar">
            <div class="navbar-logo"><span class="logo-text">COUNSELOR SYSTEM</span></div>
            <ul class="navbar-menu">
                <li><a href="counselorDashboard.jsp">Dashboard</a></li>
                <li><a href="StudentServlet?action=list">List of Students</a></li>
                <li class="active"><a href="AppointmentServlet?action=list">Appointment</a></li>
                <li><a href="SessionServlet?action=viewPage">Session</a></li>
                <li class="logout"><a href="LogoutServlet">Logout</a></li>
            </ul>
        </nav>

        <div class="main-content">
            <div class="main-header">
                <div class="header-left">
                    <h1>Appointments</h1>
                    <p class="welcome-subtitle">Manage your counseling sessions and appointments</p>
                </div>
                <div class="header-right">
                    <div class="header-date" id="currentDate">
                        <fmt:formatDate value="${currentDate}" pattern="EEEE, MMMM d, yyyy"/>
                    </div>
                </div>
            </div>

            <c:if test="${not empty sessionScope.message}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> ${sessionScope.message}
                </div>
                <c:remove var="message" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.error}">
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i> ${sessionScope.error}
                </div>
                <c:remove var="error" scope="session"/>
            </c:if>

            <div class="cards">
                <div class="card">
                    <div class="card-content">
                        <h3>Today</h3>
                        <div class="card-number">${todayBookedCount}</div>
                        <p class="card-detail">Booked appointments</p>
                    </div>
                </div>

                <div class="card">
                    <div class="card-content">
                        <h3>This Week</h3>
                        <div class="card-number">${weekCount}</div>
                        <p class="card-detail">Upcoming sessions</p>
                    </div>
                </div>

                <div class="card">
                    <div class="card-content">
                        <h3>Pending</h3>
                        <div class="card-number">${todayPendingCount}</div>
                        <p class="card-detail">Awaiting confirmation</p>
                    </div>
                </div>

                <div class="card">
                    <div class="card-content">
                        <h3>Completed</h3>
                        <div class="card-number">${weekCompletedCount}</div>
                        <p class="card-detail">This week completed appointment</p>
                    </div>
                </div>
            </div>

            <div class="content-section">
                <div class="section-header" style="flex-wrap: wrap;">
                    <h2><i class="fas fa-list-alt"></i> Appointments List</h2>
                    <form action="AppointmentServlet" method="get" style="display: flex; gap: 10px;">
                        <input type="hidden" name="action" value="list">
                        <select class="date-input" name="statusFilter" onchange="this.form.submit()" style="min-width: 150px;">
                            <option value="all" ${param.statusFilter == 'all' ? 'selected' : ''}>All Status</option>
                            <option value="Pending" ${param.statusFilter == 'Pending' ? 'selected' : ''}>Pending</option>
                            <option value="booked" ${param.statusFilter == 'booked' ? 'selected' : ''}>Booked</option>
                            <option value="complete" ${param.statusFilter == 'complete' ? 'selected' : ''}>Completed</option>
                            <option value="cancelled" ${param.statusFilter == 'cancelled' ? 'selected' : ''}>Cancelled</option>
                        </select>
                    </form>
                </div>

                <div class="sessions-grid" style="grid-template-columns: 1fr;">
                    <c:choose>
                        <c:when test="${empty appointments}">
                            <div class="no-sessions">
                                <i class="fas fa-calendar-times"></i>
                                <h3>No appointments found</h3>
                                <p>Try adjusting your filters or check back later</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="appointment" items="${appointments}">
                                <div class="session-card" style="display: flex; gap: 25px; align-items: center;">
                                    <div style="min-width: 120px; text-align: center; padding: 15px; 
                                                background: linear-gradient(135deg, #f8f7fc 0%, #ffffff 100%); 
                                                border-radius: 12px; border: 2px solid #e6e1f7;">
                                        <div style="font-size: 1.5em; font-weight: 700; color: #5D2E8C; margin-bottom: 5px;">
                                            <fmt:formatDate value="${appointment.bookedDate}" pattern="dd"/>
                                        </div>
                                        <div style="color: #8B7BA6; font-size: 0.9em; font-weight: 500;">
                                            <fmt:formatDate value="${appointment.bookedDate}" pattern="MMM yyyy"/>
                                        </div>
                                    </div>

                                    <div style="flex: 1;">
                                        <h4 style="color: #5D2E8C; font-size: 1.3em; margin-bottom: 10px; font-weight: 600;">
                                            Appointment ${appointment.ID}
                                        </h4>
                                        <div style="display: flex; gap: 30px; margin-bottom: 8px; flex-wrap: wrap;">
                                            <div style="display: flex; align-items: center; gap: 8px; color: #666; font-size: 0.95em;">
                                                <i class="fas fa-user" style="color: #A56CD1;"></i>
                                                <span>${userNameMap[appointment.studentID]}</span>
                                            </div>                                        
                                            <div style="display: flex; align-items: center; gap: 8px; color: #666; font-size: 0.95em;">
                                                <i class="fas fa-calendar" style="color: #A56CD1;"></i>
                                                <span><fmt:formatDate value="${appointment.bookedDate}" pattern="EEE, MMM d, yyyy"/></span>
                                            </div>
                                            <div style="display: flex; align-items: center; gap: 8px;">
                                                <span class="session-status status-${appointment.appointmentStatus}">
                                                    ${appointment.appointmentStatus}
                                                </span>
                                            </div>
                                        </div>
                                        <div style="display: flex; gap: 8px; color: #666; font-size: 0.95em;">
                                            <i class="fas fa-file-alt" style="color: #A56CD1;"></i>
                                            <span>${appointment.description}</span>
                                        </div>
                                    </div>

                                    <div style="display: flex; gap: 10px; flex-direction: column;">
                                        <button class="btn-professional" onclick="viewAppointmentModal(${appointment.ID})">
                                            <i class="fas fa-eye"></i> View Details
                                        </button>

                                        <c:if test="${appointment.appointmentStatus != 'complete' && appointment.appointmentStatus != 'cancelled'}">
                                            <button class="add-session-btn" onclick="showCompleteModal(${appointment.ID})" 
                                                    style="background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%); font-size: 0.9em; padding: 10px 16px;">
                                                <i class="fas fa-check"></i> Complete
                                            </button>
                                            <c:if test="${appointment.appointmentStatus == 'Pending' || appointment.appointmentStatus == 'Booked'}">
                                                <button class="add-session-btn" onclick="rescheduleAppointment(${appointment.ID})" 
                                                        style="background: linear-gradient(135deg, #2196F3 0%, #1976D2 100%); font-size: 0.9em; padding: 10px 16px;">
                                                    <i class="fas fa-calendar-alt"></i> Reschedule
                                                </button>
                                            </c:if>
                                            <button class="add-session-btn" onclick="showCancelModal(${appointment.ID})" 
                                                    style="background: linear-gradient(135deg, #f44336 0%, #d32f2f 100%); font-size: 0.9em; padding: 10px 16px;">
                                                <i class="fas fa-times"></i> Cancel
                                            </button>
                                        </c:if>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <div id="viewModal" class="status-modal-overlay">
            <div class="status-modal" style="max-width: 700px;">
                <div class="modal-header">
                    <h3><i class="fas fa-eye"></i> Appointment Details</h3>
                    <button class="modal-close" onclick="closeViewModal()">&times;</button>
                </div>
                <div class="modal-body">
                    <div id="appointmentDetails"></div>
                    <div class="modal-buttons">
                        <button type="button" class="btn-cancel" onclick="closeViewModal()">Close</button>
                    </div>
                </div>
            </div>
        </div>

        <div id="completeModal" class="action-modal-overlay">
            <div class="action-modal">
                <div class="modal-icon success">
                    <i class="fas fa-check-circle"></i>
                </div>
                <h3 style="color: #4CAF50;">Complete Appointment?</h3>
                <p>Are you sure you want to mark this appointment as completed?</p>
                <div class="modal-buttons">
                    <button class="modal-btn modal-btn-confirm" onclick="confirmComplete()">
                        <i class="fas fa-check"></i> Yes, Complete
                    </button>
                    <button class="modal-btn modal-btn-secondary" onclick="closeCompleteModal()">
                        Cancel
                    </button>
                </div>
            </div>
        </div>

        <div id="cancelModal" class="action-modal-overlay">
            <div class="action-modal">
                <div class="modal-icon warning">
                    <i class="fas fa-exclamation-triangle"></i>
                </div>
                <h3 style="color: #ff9800;">Cancel Appointment?</h3>
                <p>Are you sure you want to cancel this appointment? This action cannot be undone.</p>
                <div class="modal-buttons">
                    <button class="modal-btn modal-btn-cancel-action" onclick="confirmCancel()">
                        <i class="fas fa-times"></i> Yes, Cancel
                    </button>
                    <button class="modal-btn modal-btn-secondary" onclick="closeCancelModal()">
                        Go Back
                    </button>
                </div>
            </div>
        </div>

        <script>
            var appointmentsData = {
            <c:forEach var="apt" items="${appointments}" varStatus="status">
                "${apt.ID}": {
                    id: ${apt.ID},
                    studentID: ${apt.studentID},
                    studentName: "${userNameMap[apt.studentID]}",
                    counselorID: ${apt.counselorID},
                    counselorName: "${counselorNameMap[apt.counselorID]}",
                    status: "${apt.appointmentStatus}",
                    date: "<fmt:formatDate value='${apt.bookedDate}' pattern='dd/MM/yyyy'/>",
                    description: "${apt.description}",
                    sessionID: ${apt.sessionID},
                    sessionStartTime: "${sessionStartTimeMap[apt.sessionID]}",
                    sessionEndTime: "${sessionEndTimeMap[apt.sessionID]}"
                }<c:if test="${!status.last}">,</c:if>
            </c:forEach>
            };

            var currentAppointmentID = null;

            function viewAppointmentModal(id) {
                var apt = appointmentsData[id];
                if (!apt) return;

                var html = '<table class="details-table" style="width: 100%; border-collapse: collapse;">';
                html += '<tr><td style="padding: 12px; border-bottom: 1px solid #eee; font-weight: 600; color: #5D2E8C; width: 30%;">Appointment Number:</td><td style="padding: 12px; border-bottom: 1px solid #eee;">' + apt.id + '</td></tr>';
                html += '<tr><td style="padding: 12px; border-bottom: 1px solid #eee; font-weight: 600; color: #5D2E8C;">Student Name:</td><td style="padding: 12px; border-bottom: 1px solid #eee;">' + apt.studentName + '</td></tr>';
                html += '<tr><td style="padding: 12px; border-bottom: 1px solid #eee; font-weight: 600; color: #5D2E8C;">Status:</td><td style="padding: 12px; border-bottom: 1px solid #eee;">' + apt.status + '</td></tr>';
                html += '<tr><td style="padding: 12px; border-bottom: 1px solid #eee; font-weight: 600; color: #5D2E8C;">Date:</td><td style="padding: 12px; border-bottom: 1px solid #eee;">' + apt.date + '</td></tr>';
                html += '<tr><td style="padding: 12px; border-bottom: 1px solid #eee; font-weight: 600; color: #5D2E8C;">Description:</td><td style="padding: 12px; border-bottom: 1px solid #eee;">' + apt.description + '</td></tr>';

                if (apt.sessionID > 0) {
                    html += '<tr><td style="padding: 12px; border-bottom: 1px solid #eee; font-weight: 600; color: #5D2E8C;">Session Time:</td><td style="padding: 12px; border-bottom: 1px solid #eee;">' + apt.sessionStartTime + ' - ' + apt.sessionEndTime + '</td></tr>';
                }

                html += '</table>';

                document.getElementById('appointmentDetails').innerHTML = html;
                document.getElementById('viewModal').style.display = 'flex';
            }

            function closeViewModal() {
                document.getElementById('viewModal').style.display = 'none';
            }

            function showCompleteModal(id) {
                currentAppointmentID = id;
                document.getElementById('completeModal').style.display = 'flex';
            }

            function closeCompleteModal() {
                document.getElementById('completeModal').style.display = 'none';
                currentAppointmentID = null;
            }

            function confirmComplete() {
                if (currentAppointmentID) {
                    window.location.href = 'AppointmentServlet?action=complete&id=' + currentAppointmentID;
                }
            }

            function showCancelModal(id) {
                currentAppointmentID = id;
                document.getElementById('cancelModal').style.display = 'flex';
            }

            function closeCancelModal() {
                document.getElementById('cancelModal').style.display = 'none';
                currentAppointmentID = null;
            }

            function confirmCancel() {
                if (currentAppointmentID) {
                    window.location.href = 'AppointmentServlet?action=cancel&id=' + currentAppointmentID;
                }
            }

            function rescheduleAppointment(id) {
                window.location.href = 'AppointmentServlet?action=showReschedule&id=' + id;
            }

            document.addEventListener('DOMContentLoaded', function() {
                const dateElement = document.getElementById('currentDate');
                if (dateElement && dateElement.textContent === '') {
                    const now = new Date();
                    const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
                    dateElement.textContent = now.toLocaleDateString('en-US', options);
                }
            });

            window.onclick = function(event) {
                var viewModal = document.getElementById('viewModal');
                if (event.target == viewModal) {
                    closeViewModal();
                }
            }
        </script>
    </body>
</html>