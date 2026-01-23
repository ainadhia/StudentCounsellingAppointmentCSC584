<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@page import="com.counselling.model.Counselor"%>
<%@page import="java.text.SimpleDateFormat"%>

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
    int counselorID = counselor.getID();
    
    String successMessage = (String) session.getAttribute("rescheduleSuccess");
    boolean showSuccessModal = (successMessage != null);
    if (showSuccessModal) {
        session.removeAttribute("rescheduleSuccess");
    }
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Reschedule Appointment</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="global-style.css">
        <style>
            .session-slot {
                border: 2px solid #e6e1f7;
                border-radius: 10px;
                padding: 15px;
                text-align: center;
                cursor: pointer;
                transition: all 0.3s ease;
                background: white;
            }

            .session-slot:hover {
                border-color: #A56CD1;
                background: #f8f7fc;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(165, 108, 209, 0.15);
            }

            .session-slot.selected {
                border-color: #4CAF50;
                background: #f1f8e9;
            }

            .success-modal-overlay {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.6);
                z-index: 9999;
                justify-content: center;
                align-items: center;
            }

            .success-modal {
                background: white;
                border-radius: 20px;
                padding: 40px;
                max-width: 450px;
                text-align: center;
                box-shadow: 0 10px 40px rgba(0,0,0,0.3);
                animation: slideIn 0.3s ease;
            }

            @keyframes slideIn {
                from { transform: translateY(-50px); opacity: 0; }
                to { transform: translateY(0); opacity: 1; }
            }

            .success-icon {
                width: 80px;
                height: 80px;
                background: linear-gradient(135deg, #4CAF50, #45a049);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 20px;
                animation: scaleIn 0.5s ease;
            }

            @keyframes scaleIn {
                0% { transform: scale(0); }
                50% { transform: scale(1.1); }
                100% { transform: scale(1); }
            }

            .success-icon i {
                color: white;
                font-size: 40px;
            }

            .success-modal h3 {
                color: #4CAF50;
                margin-bottom: 15px;
                font-size: 24px;
            }

            .success-modal p {
                color: #666;
                margin-bottom: 25px;
                font-size: 16px;
            }

            .modal-ok-btn {
                background: linear-gradient(135deg, #4CAF50, #45a049);
                color: white;
                border: none;
                padding: 12px 40px;
                border-radius: 25px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s ease;
            }

            .modal-ok-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(76, 175, 80, 0.3);
            }

            .confirm-modal-overlay {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.6);
                z-index: 9998;
                justify-content: center;
                align-items: center;
            }

            .confirm-modal {
                background: white;
                border-radius: 25px;
                padding: 40px;
                max-width: 500px;
                width: 90%;
                text-align: center;
                box-shadow: 0 10px 40px rgba(0,0,0,0.3);
                animation: bounceIn 0.6s cubic-bezier(0.68, -0.55, 0.265, 1.55);
            }

            @keyframes bounceIn {
                0% { 
                    transform: scale(0.3) rotate(-10deg); 
                    opacity: 0; 
                }
                50% { 
                    transform: scale(1.05) rotate(2deg); 
                }
                70% { 
                    transform: scale(0.95) rotate(-1deg); 
                }
                100% { 
                    transform: scale(1) rotate(0deg); 
                    opacity: 1; 
                }
            }

            .confirm-icon {
                width: 100px;
                height: 100px;
                background: linear-gradient(135deg, #A56CD1, #8B5AB8);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 25px;
                animation: floatIcon 3s ease-in-out infinite;
                box-shadow: 0 10px 30px rgba(165, 108, 209, 0.3);
            }

            @keyframes floatIcon {
                0%, 100% { transform: translateY(0px) rotate(0deg); }
                50% { transform: translateY(-10px) rotate(5deg); }
            }

            .confirm-icon i {
                color: white;
                font-size: 50px;
                animation: wiggle 1s ease-in-out infinite;
            }

            @keyframes wiggle {
                0%, 100% { transform: rotate(0deg); }
                25% { transform: rotate(-10deg); }
                75% { transform: rotate(10deg); }
            }

            .confirm-modal h3 {
                color: #5D2E8C;
                margin-bottom: 15px;
                font-size: 28px;
                font-weight: 700;
            }

            .confirm-modal-subtitle {
                color: #8B7BA6;
                margin-bottom: 30px;
                font-size: 15px;
                font-weight: 500;
            }

            .confirm-details {
                background: linear-gradient(135deg, #f8f7fc 0%, #ffffff 100%);
                border: 2px solid #e6e1f7;
                border-radius: 20px;
                padding: 25px;
                margin: 25px 0;
                text-align: left;
            }

            .confirm-details-row {
                display: flex;
                align-items: center;
                gap: 15px;
                margin-bottom: 15px;
                padding: 12px;
                background: white;
                border-radius: 12px;
                transition: all 0.3s ease;
            }

            .confirm-details-row:hover {
                transform: translateX(5px);
                box-shadow: 0 2px 10px rgba(165, 108, 209, 0.1);
            }

            .confirm-details-row:last-child {
                margin-bottom: 0;
            }

            .confirm-details-icon {
                width: 40px;
                height: 40px;
                background: linear-gradient(135deg, #A56CD1, #8B5AB8);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                flex-shrink: 0;
            }

            .confirm-details-icon i {
                color: white;
                font-size: 18px;
            }

            .confirm-details-text {
                flex: 1;
            }

            .confirm-details-label {
                font-size: 11px;
                color: #8B7BA6;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 1px;
                margin-bottom: 3px;
            }

            .confirm-details-value {
                font-size: 16px;
                color: #5D2E8C;
                font-weight: 700;
            }

            .confirm-buttons {
                display: flex;
                gap: 15px;
                margin-top: 35px;
            }

            .confirm-btn-yes {
                flex: 1;
                background: linear-gradient(135deg, #4CAF50, #45a049);
                color: white;
                border: none;
                padding: 16px 30px;
                border-radius: 30px;
                font-size: 17px;
                font-weight: 700;
                cursor: pointer;
                transition: all 0.3s ease;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 10px;
                box-shadow: 0 5px 20px rgba(76, 175, 80, 0.3);
            }

            .confirm-btn-yes:hover {
                transform: translateY(-3px);
                box-shadow: 0 8px 25px rgba(76, 175, 80, 0.4);
            }

            .confirm-btn-yes:active {
                transform: translateY(-1px);
            }

            .confirm-btn-no {
                flex: 1;
                background: white;
                color: #8B7BA6;
                border: 3px solid #e6e1f7;
                padding: 16px 30px;
                border-radius: 30px;
                font-size: 17px;
                font-weight: 700;
                cursor: pointer;
                transition: all 0.3s ease;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 10px;
            }

            .confirm-btn-no:hover {
                background: #f8f7fc;
                border-color: #A56CD1;
                color: #5D2E8C;
                transform: translateY(-3px);
            }

            .confirm-btn-no:active {
                transform: translateY(-1px);
            }

            .confirm-modal::before {
                position: absolute;
                top: 20px;
                left: 30px;
                font-size: 24px;
                animation: sparkle 2s ease-in-out infinite;
            }

            .confirm-modal::after {
                position: absolute;
                top: 20px;
                right: 30px;
                font-size: 24px;
                animation: heartbeat 1.5s ease-in-out infinite;
            }

            @keyframes sparkle {
                0%, 100% { opacity: 1; transform: scale(1); }
                50% { opacity: 0.5; transform: scale(1.2); }
            }

            @keyframes heartbeat {
                0%, 100% { transform: scale(1); }
                10%, 30% { transform: scale(0.9); }
                20%, 40% { transform: scale(1.1); }
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
                <div class="header-left">
                    <h1><i class="fas fa-calendar-alt"></i> Reschedule Appointment</h1>
                    <p class="welcome-subtitle">Update appointment date and add notes</p>
                </div>
                <div class="header-date">
                    <%= new SimpleDateFormat("EEEE, MMMM d, yyyy").format(new java.util.Date()) %>
                </div>
            </div>

            <c:if test="${not empty appointment}">
                <div class="content-section" style="max-width: 800px; margin: 0 auto;">

                    <div style="background: linear-gradient(135deg, #f8f7fc 0%, #ffffff 100%); 
                                padding: 30px; border-radius: 15px; margin-bottom: 30px; 
                                border: 2px solid #e6e1f7;">
                        <h3 style="color: #5D2E8C; margin-bottom: 20px; display: flex; align-items: center; gap: 10px;">
                            <i class="fas fa-info-circle"></i> Current Appointment Details
                        </h3>

                        <table style="width: 100%; border-collapse: collapse;">
                            <tr>
                                <td style="padding: 12px 0; font-weight: 600; color: #5D2E8C; width: 30%;">
                                    <i class="fas fa-hashtag" style="color: #A56CD1; margin-right: 8px;"></i>
                                    Appointment ID:
                                </td>
                                <td style="padding: 12px 0; color: #666;" id="currentAppointmentID">
                                    ${appointment.ID}
                                </td>
                            </tr>
                            <tr>
                                <td style="padding: 12px 0; font-weight: 600; color: #5D2E8C;">
                                    <i class="fas fa-user" style="color: #A56CD1; margin-right: 8px;"></i>
                                    Student ID:
                                </td>
                                <td style="padding: 12px 0; color: #666;" id="currentStudentID">
                                    ${appointment.studentID}
                                </td>
                            </tr>
                            <tr>
                                <td style="padding: 12px 0; font-weight: 600; color: #5D2E8C;">
                                    <i class="fas fa-calendar" style="color: #A56CD1; margin-right: 8px;"></i>
                                    Current Date:
                                </td>
                                <td style="padding: 12px 0; color: #666;" id="currentDate">
                                    <fmt:formatDate value="${appointment.bookedDate}" pattern="EEEE, MMMM d, yyyy"/>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding: 12px 0; font-weight: 600; color: #5D2E8C;">
                                    <i class="fas fa-info" style="color: #A56CD1; margin-right: 8px;"></i>
                                    Status:
                                </td>
                                <td style="padding: 12px 0;">
                                    ${appointment.appointmentStatus}
                                </td>
                            </tr>
                        </table>
                    </div>

                    <div class="add-session-form" style="background: white; border-radius: 15px; padding: 30px; border: 2px solid #e6e1f7;">
                        <div style="display: flex; align-items: center; gap: 15px; margin-bottom: 25px; color: #5D2E8C;">
                            <i class="fas fa-calendar-check" style="font-size: 1.5em;"></i>
                            <h3>Reschedule to New Date</h3>
                        </div>

                        <form id="rescheduleForm" action="AppointmentServlet" method="POST">
                            <input type="hidden" name="action" value="reschedule">
                            <input type="hidden" name="appointmentID" value="${appointment.ID}">
                            <input type="hidden" name="sessionID" id="selectedSessionID" required>
                            <input type="hidden" name="notes" id="hiddenNotes">
                            <input type="hidden" id="counselorID" value="<%= counselorID %>">

                            <div style="margin-bottom: 25px;">
                                <label for="newDate" style="display: block; margin-bottom: 10px; font-weight: 600; color: #5D2E8C;">
                                    <i class="fas fa-calendar-alt" style="color: #A56CD1; margin-right: 8px;"></i>
                                    Select New Date
                                </label>
                                <input type="date" id="newDate" name="newDate" required
                                       onchange="loadAvailableSessions()"
                                       style="width: 100%; padding: 16px 20px; border: 2px solid #e6e1f7; 
                                              border-radius: 25px; font-size: 1.1em; font-weight: 500; 
                                              color: #5D2E8C; background: white;">
                            </div>

                            <div id="availableSessions" style="margin-top: 20px; min-height: 100px;">
                                <div style="text-align: center; padding: 30px; color: #8B7BA6; font-style: italic;">
                                    <i class="fas fa-calendar-alt"></i><br>
                                    Select a date to view available time slots
                                </div>
                            </div>

                            <div style="margin-bottom: 25px;">
                                <label for="notes" style="display: block; margin-bottom: 10px; font-weight: 600; color: #5D2E8C;">
                                    <i class="fas fa-sticky-note" style="color: #A56CD1; margin-right: 8px;"></i>
                                    Reschedule Notes (Optional)
                                </label>
                                <textarea id="notes" rows="4"
                                          style="width: 100%; padding: 16px 20px; border: 2px solid #e6e1f7; 
                                                 border-radius: 15px; font-size: 1em; color: #333; 
                                                 background: white; font-family: inherit; resize: vertical;"
                                          placeholder="Add any notes about the reschedule..."></textarea>
                            </div>

                            <div style="display: flex; gap: 15px; margin-top: 30px;">
                                <button type="button" class="add-session-btn" id="submitBtn" disabled onclick="showConfirmModal()">
                                    <i class="fas fa-check"></i> Confirm Reschedule
                                </button>
                                <a href="AppointmentServlet?action=list" 
                                   style="padding: 14px 28px; border: 2px solid #e6e1f7; background: white; 
                                          border-radius: 25px; text-decoration: none; color: #8B7BA6; 
                                          font-weight: 600; transition: all 0.3s ease; display: inline-flex; 
                                          align-items: center; gap: 10px;">
                                    <i class="fas fa-times"></i> Cancel
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
            </c:if>

            <c:if test="${empty appointment}">
                <div class="content-section">
                    <div class="no-sessions">
                        <i class="fas fa-exclamation-triangle"></i>
                        <h3>Appointment Not Found</h3>
                        <p>The requested appointment could not be found.</p>
                        <a href="AppointmentServlet?action=list" class="add-session-btn" 
                           style="display: inline-flex; text-decoration: none;">
                            <i class="fas fa-arrow-left"></i> Back to Appointments
                        </a>
                    </div>
                </div>
            </c:if>
        </div>

        <div id="confirmModal" class="confirm-modal-overlay">
            <div class="confirm-modal">
                <div class="confirm-icon">
                    <i class="fas fa-question-circle"></i>
                </div>
                <h3>Confirm Reschedule?</h3>
                <p class="confirm-modal-subtitle">Please review the new appointment details</p>

                <div class="confirm-details">
                    <div class="confirm-details-row">
                        <div class="confirm-details-icon">
                            <i class="fas fa-hashtag"></i>
                        </div>
                        <div class="confirm-details-text">
                            <div class="confirm-details-label">Appointment ID</div>
                            <div class="confirm-details-value" id="modalAppointmentID"></div>
                        </div>
                    </div>

                    <div class="confirm-details-row">
                        <div class="confirm-details-icon">
                            <i class="fas fa-user"></i>
                        </div>
                        <div class="confirm-details-text">
                            <div class="confirm-details-label">Student ID</div>
                            <div class="confirm-details-value" id="modalStudentID"></div>
                        </div>
                    </div>

                    <div class="confirm-details-row">
                        <div class="confirm-details-icon">
                            <i class="fas fa-calendar"></i>
                        </div>
                        <div class="confirm-details-text">
                            <div class="confirm-details-label">New Date</div>
                            <div class="confirm-details-value" id="modalNewDate"></div>
                        </div>
                    </div>

                    <div class="confirm-details-row">
                        <div class="confirm-details-icon">
                            <i class="fas fa-clock"></i>
                        </div>
                        <div class="confirm-details-text">
                            <div class="confirm-details-label">New Time</div>
                            <div class="confirm-details-value" id="modalTimeSlot"></div>
                        </div>
                    </div>
                </div>

                <div class="confirm-buttons">
                    <button class="confirm-btn-no" onclick="hideConfirmModal()">
                        <i class="fas fa-times"></i> Cancel
                    </button>
                    <button class="confirm-btn-yes" onclick="confirmReschedule()">
                        <i class="fas fa-check"></i> Yes, Reschedule!
                    </button>
                </div>
            </div>
        </div>

        <div id="successModal" class="success-modal-overlay">
            <div class="success-modal">
                <div class="success-icon">
                    <i class="fas fa-check"></i>
                </div>
                <h3>Appointment Rescheduled!</h3>
                <p>The appointment has been successfully rescheduled to the new date and time.</p>
                <button class="modal-ok-btn" onclick="redirectToAppointments()">
                    <i class="fas fa-arrow-right"></i> Go to Appointments
                </button>
            </div>
        </div>

        <script>
            var selectedTimeSlotText = '';

            <% if (showSuccessModal) { %>
            window.onload = function() {
                document.getElementById('successModal').style.display = 'flex';
            };
            <% } %>

            function redirectToAppointments() {
                window.location.href = 'AppointmentServlet?action=list';
            }

            function showConfirmModal() {
                var selectedSessionID = document.getElementById('selectedSessionID').value;
                var newDate = document.getElementById('newDate').value;

                if (!selectedSessionID) {
                    alert('Please select a time slot!');
                    return;
                }

                if (!newDate) {
                    alert('Please select a date!');
                    return;
                }

                var selectedDate = new Date(newDate);
                var today = new Date();
                today.setHours(0, 0, 0, 0);

                if (selectedDate < today) {
                    alert('Please select a future date!');
                    return;
                }

                var options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
                var formattedDate = selectedDate.toLocaleDateString('en-US', options);

                document.getElementById('modalAppointmentID').textContent = document.getElementById('currentAppointmentID').textContent.trim();
                document.getElementById('modalStudentID').textContent = document.getElementById('currentStudentID').textContent.trim();
                document.getElementById('modalNewDate').textContent = formattedDate;
                document.getElementById('modalTimeSlot').textContent = selectedTimeSlotText;

                document.getElementById('confirmModal').style.display = 'flex';
            }

            function hideConfirmModal() {
                document.getElementById('confirmModal').style.display = 'none';
            }

            function confirmReschedule() {
                document.getElementById('hiddenNotes').value = document.getElementById('notes').value;

                hideConfirmModal();

                document.getElementById('rescheduleForm').submit();
            }

            function loadAvailableSessions() {
                var selectedDate = document.getElementById('newDate').value;
                var counselorID = document.getElementById('counselorID').value;

                if (!selectedDate) {
                    document.getElementById('availableSessions').innerHTML = 
                        '<div style="text-align: center; padding: 30px; color: #8B7BA6; font-style: italic;">' +
                        '<i class="fas fa-calendar-alt"></i><br>' +
                        'Select a date to view available time slots' +
                        '</div>';
                    return;
                }

                document.getElementById('availableSessions').innerHTML = 
                    '<div style="text-align: center; padding: 30px; color: #666;">' +
                    '<i class="fas fa-spinner fa-spin"></i><br>' +
                    'Loading available sessions...' +
                    '</div>';

                document.getElementById('selectedSessionID').value = '';
                document.getElementById('submitBtn').disabled = true;
                selectedTimeSlotText = '';

                var xhr = new XMLHttpRequest();
                var url = 'AppointmentServlet?action=getAvailableSessions&date=' + 
                          selectedDate + '&counselorID=' + counselorID;

                xhr.open('GET', url, true);
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === 4 && xhr.status === 200) {
                        try {
                            var sessions = JSON.parse(xhr.responseText);
                            displayAvailableSessions(sessions);
                        } catch (e) {
                            document.getElementById('availableSessions').innerHTML = 
                                '<div style="color: #f44336; padding: 20px; text-align: center;">' +
                                '<i class="fas fa-exclamation-circle"></i><br>' +
                                'Error loading sessions' +
                                '</div>';
                        }
                    }
                };
                xhr.send();
            }

            function displayAvailableSessions(sessions) {
                var container = document.getElementById('availableSessions');

                if (!sessions || sessions.length === 0) {
                    container.innerHTML = 
                        '<div style="text-align: center; padding: 30px; color: #666;">' +
                        '<i class="fas fa-calendar-times"></i><br>' +
                        '<strong>No available sessions</strong><br>' +
                        'No available time slots for this date.' +
                        '</div>';
                    return;
                }

                var html = '<h4 style="color: #5D2E8C; margin-bottom: 15px;">' +
                          '<i class="fas fa-clock"></i> Available Time Slots:' +
                          '</h4>' +
                          '<div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 10px; margin-bottom: 20px;">';

                for (var i = 0; i < sessions.length; i++) {
                    var session = sessions[i];

                    html += '<div class="session-slot" onclick="selectSession(this, ' + session.sessionID + ', \'' + 
                           session.startTime + ' - ' + session.endTime + '\')">' +
                           '<div style="font-weight: 600; color: #5D2E8C; margin-bottom: 5px;">' +
                           '<i class="fas fa-clock" style="color: #A56CD1; margin-right: 5px;"></i>' +
                           session.startTime + ' - ' + session.endTime +
                           '</div>' +
                           '<small style="color: #8B7BA6; font-size: 0.85em;">Click to select</small>' +
                           '</div>';
                }

                html += '</div>' +
                       '<div id="selectedSessionInfo" style="display: none; margin-top: 20px;">' +
                       '<div style="background: #e8f5e9; padding: 15px; border-radius: 10px; ' +
                       'border-left: 4px solid #4CAF50;">' +
                       '<strong><i class="fas fa-check-circle" style="color: #4CAF50;"></i> Selected Session:</strong> ' +
                       '<span id="selectedTimeSlot" style="font-weight: 600; margin-left: 10px;"></span>' +
                       '</div>' +
                       '</div>';

                container.innerHTML = html;
            }

            function selectSession(element, sessionID, timeSlot) {
                var allSlots = document.querySelectorAll('.session-slot');
                allSlots.forEach(function(slot) {
                    slot.classList.remove('selected');
                    slot.style.borderColor = '#e6e1f7';
                    slot.style.background = 'white';
                });

                element.classList.add('selected');
                element.style.borderColor = '#4CAF50';
                element.style.background = '#f1f8e9';

                document.getElementById('selectedSessionID').value = sessionID;
                document.getElementById('selectedTimeSlot').textContent = timeSlot;
                document.getElementById('selectedSessionInfo').style.display = 'block';
                document.getElementById('submitBtn').disabled = false;

                selectedTimeSlotText = timeSlot;
            }

            document.addEventListener('DOMContentLoaded', function() {
                var today = new Date();
                var tomorrow = new Date(today);
                tomorrow.setDate(tomorrow.getDate() + 1);

                var dateInput = document.getElementById('newDate');
                if (dateInput) {
                    var dd = String(tomorrow.getDate()).padStart(2, '0');
                    var mm = String(tomorrow.getMonth() + 1).padStart(2, '0');
                    var yyyy = tomorrow.getFullYear();

                    dateInput.min = yyyy + '-' + mm + '-' + dd;
                }
            });
        </script>
    </body>
</html>