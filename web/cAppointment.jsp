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
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Appointment Management | Counselor Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="global-style.css">
    <style>
        /* ADDITIONAL STYLES FOR MODALS */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }
        
        .status-modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }
        
        .confirmation-modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }
        
        .popup-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 1000;
            display: none;
            align-items: center;
            justify-content: center;
        }
        
        /* Ensure modal appears above everything */
        .popup-modal, .status-modal {
            position: relative;
            z-index: 1001;
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="navbar-logo"><span class="logo-text">COUNSELOR</span></div>
        <ul class="navbar-menu">
            <li><a href="counselorDashboard.jsp"><i class="fas fa-home"></i> Dashboard</a></li>
            <li><a href="listOfStudent.jsp"><i class="fas fa-users"></i> List of Students</a></li>
            <li class="active"><a href="AppointmentServlet?action=list"><i class="fas fa-calendar-check"></i> Appointment</a></li>
            <li><a href="SessionServlet?action=viewPage"><i class="fas fa-clock"></i> Session</a></li>
            <li class="logout"><a href="LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
        </ul>
    </nav>

    <div class="main-content">
        <div class="main-header">
            <div>
                <h1>Appointments</h1>
                <p class="welcome-subtitle">Manage your counseling sessions and appointments</p>
            </div>
            <div style="display: flex; flex-direction: column; align-items: flex-end; gap: 15px;">
                <div class="header-date">
                    <fmt:formatDate value="${currentDate}" pattern="EEEE, MMMM d, yyyy"/>
                </div>
                <a href="bookAppointmentCounsellor.jsp" class="add-session-btn">
                    <i class="fas fa-plus"></i> New Appointment
                </a>
            </div>
        </div>

        <!-- SUCCESS POPUP (from session) - SHOW ONLY WHEN MESSAGE EXISTS -->
        <c:if test="${not empty sessionScope.message}">
            <div class="popup-overlay" id="sessionSuccessPopup">
                <div class="popup-modal success-popup">
                    <div class="popup-icon-wrapper">
                        <div class="icon-circle success-circle">
                            <i class="fas fa-check-circle"></i>
                        </div>
                    </div>
                    <h2 class="popup-title">Success!</h2>
                    <p class="popup-message">${sessionScope.message}</p>
                    <button class="popup-btn success-btn" onclick="closeSessionSuccessPopup()">
                        <i class="fas fa-check"></i> Got it
                    </button>
                </div>
            </div>
            <c:remove var="message" scope="session"/>
        </c:if>

        <!-- ERROR POPUP (from session) - SHOW ONLY WHEN ERROR EXISTS -->
        <c:if test="${not empty sessionScope.error}">
            <div class="popup-overlay" id="sessionErrorPopup">
                <div class="popup-modal error-popup">
                    <div class="popup-icon-wrapper">
                        <div class="icon-circle error-circle">
                            <i class="fas fa-exclamation-circle"></i>
                        </div>
                    </div>
                    <h2 class="popup-title">Error</h2>
                    <p class="popup-message">${sessionScope.error}</p>
                    <button class="popup-btn error-btn" onclick="closeSessionErrorPopup()">
                        <i class="fas fa-times"></i> Close
                    </button>
                </div>
            </div>
            <c:remove var="error" scope="session"/>
        </c:if>

        <div class="content-section">
            <div class="section-header">
                <h4><i class="fas fa-list-alt"></i> Appointments List</h4>
                <form action="AppointmentServlet" method="get" style="display: flex; gap: 10px;">
                    <input type="hidden" name="action" value="list">
                    <select class="date-input" name="statusFilter" onchange="this.form.submit()">
                        <option value="all" ${param.statusFilter == 'all' ? 'selected' : ''}>All Status</option>
                        <option value="Pending" ${param.statusFilter == 'Pending' ? 'selected' : ''}>Pending</option>
                        <option value="complete" ${param.statusFilter == 'complete' ? 'selected' : ''}>Completed</option>
                        <option value="cancelled" ${param.statusFilter == 'cancelled' ? 'selected' : ''}>Cancelled</option>
                    </select>
                </form>
            </div>

            <div style="display: flex; flex-direction: column; gap: 20px;">
                <c:choose>
                    <c:when test="${empty appointments}">
                        <div class="no-sessions">
                            <i class="fas fa-calendar-times"></i>
                            <h3>No appointments found</h3>
                            <p>Try adjusting your filters or create a new appointment</p>
                            <a href="bookAppointmentCounsellor.jsp" class="add-session-btn" style="margin-top: 20px; display: inline-flex;">
                                <i class="fas fa-plus"></i> Create Appointment
                            </a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="appointment" items="${appointments}">
                            <div class="session-item" style="padding: 25px; background: white; border-radius: 15px; border: 2px solid #f0ebfa; transition: all 0.3s ease;">
                                <div class="session-date" style="min-width: 80px;">
                                    <div class="date-day">
                                        <fmt:formatDate value="${appointment.bookedDate}" pattern="dd"/>
                                    </div>
                                    <div class="date-month">
                                        <fmt:formatDate value="${appointment.bookedDate}" pattern="MMM"/>
                                    </div>
                                </div>

                                <div class="session-details" style="flex: 1;">
                                    <h4 style="color: #5D2E8C; font-size: 1.3em; margin-bottom: 12px;">
                                        Appointment #${appointment.ID}
                                    </h4>
                                    <div style="display: flex; flex-wrap: wrap; gap: 20px; margin-bottom: 10px;">
                                        <p style="margin: 0;">
                                            <i class="fas fa-user" style="color: #A56CD1;"></i>
                                            <strong>Student:</strong> ${userNameMap[appointment.studentID]}
                                        </p>
                                        <p style="margin: 0;">
                                            <i class="fas fa-calendar" style="color: #A56CD1;"></i>
                                            <strong>Date:</strong> <fmt:formatDate value="${appointment.bookedDate}" pattern="EEE, MMM d, yyyy"/>
                                        </p>
                                        <c:if test="${appointment.sessionID > 0}">
                                            <p style="margin: 0;">
                                                <i class="fas fa-clock" style="color: #A56CD1;"></i>
                                                <strong>Time:</strong> ${sessionStartTimeMap[appointment.sessionID]} - ${sessionEndTimeMap[appointment.sessionID]}
                                            </p>
                                        </c:if>
                                    </div>
                                    <p style="margin: 8px 0 0 0; color: #666;">
                                        <i class="fas fa-file-alt" style="color: #A56CD1;"></i>
                                        <strong>Notes:</strong> ${appointment.description}
                                    </p>
                                    <div style="margin-top: 12px;">
                                        <span class="session-status status-${fn:toLowerCase(appointment.appointmentStatus)}">
                                            <i class="fas fa-circle"></i> ${appointment.appointmentStatus}
                                        </span>
                                    </div>
                                </div>

                                <div style="display: flex; flex-direction: column; gap: 10px; min-width: 180px;">
                                    <button class="add-session-btn" onclick="viewAppointmentModal(${appointment.ID})" 
                                            style="background: linear-gradient(135deg, #A56CD1 0%, #8a4ec7 100%); font-size: 0.9em;">
                                        <i class="fas fa-eye"></i> View Details
                                    </button>

                                    <c:if test="${appointment.appointmentStatus != 'complete' && appointment.appointmentStatus != 'cancelled'}">
                                        <button class="add-session-btn" onclick="showCompleteModal(${appointment.ID})" 
                                                style="background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%); font-size: 0.9em;">
                                            <i class="fas fa-check"></i> Complete
                                        </button>
                                        <c:if test="${appointment.appointmentStatus == 'Pending' || appointment.appointmentStatus == 'booked'}">
                                            <button class="add-session-btn" onclick="location.href='AppointmentServlet?action=showReschedule&id=${appointment.ID}'" 
                                                    style="background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%); font-size: 0.9em;">
                                                <i class="fas fa-calendar-alt"></i> Reschedule
                                            </button>
                                        </c:if>
                                        <button class="add-session-btn" onclick="showCancelModal(${appointment.ID})" 
                                                style="background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); font-size: 0.9em;">
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

    <!-- View Modal (DETAILS) -->
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

    <!-- Complete Confirmation Modal -->
    <div id="completeModal" class="confirmation-modal-overlay">
        <div class="popup-modal success-popup">
            <div class="popup-icon-wrapper">
                <div class="icon-circle success-circle">
                    <i class="fas fa-check-circle"></i>
                </div>
            </div>
            <h2 class="popup-title">Complete Appointment?</h2>
            <p class="popup-message">Are you sure you want to mark this appointment as completed?</p>
            <div style="display: flex; gap: 12px; justify-content: center;">
                <button class="popup-btn success-btn" onclick="confirmComplete()">
                    <i class="fas fa-check"></i> Yes, Complete
                </button>
                <button class="popup-btn" onclick="closeCompleteModal()" 
                        style="background: linear-gradient(135deg, #6c757d 0%, #5a6268 100%);">
                    <i class="fas fa-times"></i> Cancel
                </button>
            </div>
        </div>
    </div>

    <!-- Cancel Confirmation Modal -->
    <div id="cancelModal" class="confirmation-modal-overlay">
        <div class="popup-modal error-popup">
            <div class="popup-icon-wrapper">
                <div class="icon-circle error-circle">
                    <i class="fas fa-exclamation-triangle"></i>
                </div>
            </div>
            <h2 class="popup-title">Cancel Appointment?</h2>
            <p class="popup-message">Are you sure you want to cancel this appointment? This action cannot be undone.</p>
            <div style="display: flex; gap: 12px; justify-content: center;">
                <button class="popup-btn error-btn" onclick="confirmCancel()">
                    <i class="fas fa-times"></i> Yes, Cancel
                </button>
                <button class="popup-btn" onclick="closeCancelModal()" 
                        style="background: linear-gradient(135deg, #6c757d 0%, #5a6268 100%);">
                    <i class="fas fa-arrow-left"></i> Go Back
                </button>
            </div>
        </div>
    </div>

    <script>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
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

        // Auto show session popups when page loads
        window.onload = function() {
            // Check if session success popup should be shown
            var successPopup = document.getElementById('sessionSuccessPopup');
            if (successPopup) {
                successPopup.style.display = 'flex';
            }
            
            // Check if session error popup should be shown
            var errorPopup = document.getElementById('sessionErrorPopup');
            if (errorPopup) {
                errorPopup.style.display = 'flex';
            }
        };

        function viewAppointmentModal(id) {
            var apt = appointmentsData[id];
            if (!apt) return;

            var html = '<div style="background: #f8f7fc; border-radius: 12px; padding: 20px; margin-bottom: 20px;">';
            html += '<table style="width: 100%; border-collapse: collapse;">';
            html += '<tr><td style="padding: 12px; font-weight: 600; color: #5D2E8C; width: 40%;">Appointment Number:</td><td style="padding: 12px;">#' + apt.id + '</td></tr>';
            html += '<tr style="background: white;"><td style="padding: 12px; font-weight: 600; color: #5D2E8C;">Student Name:</td><td style="padding: 12px;">' + apt.studentName + '</td></tr>';
            html += '<tr><td style="padding: 12px; font-weight: 600; color: #5D2E8C;">Status:</td><td style="padding: 12px;"><span class="session-status status-' + apt.status.toLowerCase() + '">' + apt.status + '</span></td></tr>';
            html += '<tr style="background: white;"><td style="padding: 12px; font-weight: 600; color: #5D2E8C;">Date:</td><td style="padding: 12px;">' + apt.date + '</td></tr>';
            
            if (apt.sessionID > 0) {
                html += '<tr><td style="padding: 12px; font-weight: 600; color: #5D2E8C;">Session Time:</td><td style="padding: 12px;">' + apt.sessionStartTime + ' - ' + apt.sessionEndTime + '</td></tr>';
            }
            
            html += '<tr style="background: white;"><td style="padding: 12px; font-weight: 600; color: #5D2E8C;">Description:</td><td style="padding: 12px;">' + apt.description + '</td></tr>';
            html += '</table></div>';

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

        function closeSessionSuccessPopup() {
            var popup = document.getElementById('sessionSuccessPopup');
            if (popup) {
                popup.style.display = 'none';
            }
        }

        function closeSessionErrorPopup() {
            var popup = document.getElementById('sessionErrorPopup');
            if (popup) {
                popup.style.display = 'none';
            }
        }

        // Handle clicks outside modals to close them
        window.onclick = function(event) {
            // Close view modal when clicking outside
            if (event.target.id === 'viewModal') {
                closeViewModal();
            }
            
            // Close complete modal when clicking outside
            if (event.target.id === 'completeModal') {
                closeCompleteModal();
            }
            
            // Close cancel modal when clicking outside
            if (event.target.id === 'cancelModal') {
                closeCancelModal();
            }
            
            // Close session popups when clicking outside
            if (event.target.id === 'sessionSuccessPopup') {
                closeSessionSuccessPopup();
            }
            
            if (event.target.id === 'sessionErrorPopup') {
                closeSessionErrorPopup();
            }
        }
        
        // Handle ESC key to close modals
        document.onkeydown = function(evt) {
            evt = evt || window.event;
            if (evt.keyCode === 27) { // ESC key
                closeViewModal();
                closeCompleteModal();
                closeCancelModal();
                closeSessionSuccessPopup();
                closeSessionErrorPopup();
            }
        };
    </script>
</body>
</html>