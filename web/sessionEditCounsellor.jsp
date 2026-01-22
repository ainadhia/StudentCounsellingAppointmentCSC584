<%-- 
    Document   : sessionEditCounsellor
    Created on : Jan 15, 2026
    Author     : Aina
--%>
<%@page import="com.counselling.model.Counselor"%>
<%@page import="com.counselling.model.Session"%>
<%@page import="java.util.List"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    Object userObj = session.getAttribute("user");
    if (userObj == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    if (!(userObj instanceof Counselor)) {
        response.sendRedirect("unauthorized.jsp");
        return;
    }
    
    Counselor counselor = (Counselor) userObj;
    
    List<Session> sessionsList = (List<Session>) request.getAttribute("sessions");
    String selectedDate = (String) request.getAttribute("selectedDate");
    
    if (selectedDate == null || selectedDate.trim().isEmpty()) {
        java.util.Date tomorrow = new java.util.Date(System.currentTimeMillis() + 86400000);
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        selectedDate = sdf.format(tomorrow);
    }
    
    String displayDate = "";
    try {
        SimpleDateFormat displayFormat = new SimpleDateFormat("EEEE, MMMM d, yyyy");
        java.util.Date displayDateObj = new SimpleDateFormat("yyyy-MM-dd").parse(selectedDate);
        displayDate = displayFormat.format(displayDateObj);
    } catch (Exception e) {
        displayDate = selectedDate;
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <title>Manage Counseling Sessions</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="global-style.css">
        <style>
            .date-controls-container { 
                background: linear-gradient(135deg, #ffffff 0%, #f8f7fc 100%); 
                border-radius: 20px; 
                padding: 30px; 
                margin-bottom: 30px; 
                box-shadow: 0 8px 25px rgba(203, 149, 232, 0.12); 
                border: 2px solid #f0ebfa; 
            }
            .date-controls-row { 
                display: flex; 
                align-items: center; 
                gap: 20px; 
                flex-wrap: wrap; 
            }
            @keyframes fadeInUp { 
                from { opacity: 0; transform: translateY(20px); } 
                to { opacity: 1; transform: translateY(0); } 
            }
            .session-card { animation: fadeInUp 0.5s ease forwards; }
        </style>
    </head>
    <body>

        <nav class="navbar">
            <div class="navbar-logo"><span class="logo-text">COUNSELOR SYSTEM</span></div>
            <ul class="navbar-menu">
                <li><a href="counselorDashboard.jsp"><i class="fas fa-home"></i> Dashboard</a></li>
                <li><a href="StudentServlet?action=list"><i class="fas fa-users"></i> Students</a></li>
                <li><a href="AppointmentServlet?action=list"><i class="fas fa-calendar-check"></i> Appointments</a></li>
                <li class="active"><a href="SessionServlet?action=viewPage"><i class="fas fa-clock"></i> Sessions</a></li>
                <li class="logout"><a href="LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </nav>

        <div class="main-content">

            <div class="main-header">
                <div class="header-left">
                    <h1>Manage Counseling Sessions</h1>
                    <p class="welcome-subtitle">Create, manage, and view available session slots</p>
                </div>
                <div class="header-date"><%= new SimpleDateFormat("EEEE, MMMM d, yyyy").format(new java.util.Date()) %></div>
            </div>

            <c:if test="${not empty sessionScope.error}">
                <div class="content-section" style="border-color: #ffc0cb; background: linear-gradient(135deg, #ffe8ec 0%, #ffd4dd 100%); margin-bottom: 20px;">
                    <div style="display: flex; align-items: center; gap: 12px; color: #be185d;">
                        <i class="fas fa-exclamation-circle" style="font-size: 1.3em;"></i>
                        <span style="font-weight: 500;">${sessionScope.error}</span>
                    </div>
                </div>
                <c:remove var="error" scope="session"/>
            </c:if>

            <c:if test="${not empty sessionScope.message}">
                <div class="content-section" style="border-color: #a3e8b5; background: linear-gradient(135deg, #d4f4dd 0%, #b8f2c6 100%); margin-bottom: 20px;">
                    <div style="display: flex; align-items: center; gap: 12px; color: #1e7e34;">
                        <i class="fas fa-check-circle" style="font-size: 1.3em;"></i>
                        <span style="font-weight: 500;">${sessionScope.message}</span>
                    </div>
                </div>
                <c:remove var="message" scope="session"/>
            </c:if>

            <div class="date-controls-container">
                <div class="date-controls-row">
                    <div style="display: flex; align-items: center; gap: 12px; color: #5D2E8C; font-weight: 600; font-size: 1.1em;">
                        <i class="fas fa-calendar-alt"></i>
                        <span>Select Date:</span>
                    </div>

                    <form action="SessionServlet" method="GET" id="dateForm" style="display: flex; align-items: center; gap: 15px;">
                        <input type="hidden" name="action" value="viewPage">
                        <input type="date" class="date-input" id="sessionDate" name="date" value="${selectedDate}" 
                               onchange="document.getElementById('dateForm').submit()">
                        <div id="currentDateDisplay" style="padding: 12px 24px; background: linear-gradient(135deg, #CB95E8 0%, #A56CD1 100%); color: white; border-radius: 25px; font-weight: 600; font-size: 0.95em; box-shadow: 0 4px 12px rgba(203, 149, 232, 0.3);">
                            ${displayDate}
                        </div>
                    </form>

                    <div style="display: flex; gap: 15px; margin-left: auto;">
                        <button class="add-session-btn" onclick="openAddSessionModal()">
                            <i class="fas fa-plus"></i> Add Session
                        </button>
                        <button class="add-session-btn" onclick="generateDefaultSlots('${selectedDate}')" 
                                style="background: linear-gradient(135deg, #6ee7b7 0%, #34d399 100%);">
                            <i class="fas fa-magic"></i> Generate Slots
                        </button>
                    </div>
                </div>
            </div>

            <div class="content-section">
                <div class="section-header">
                    <h2><i class="fas fa-list-alt"></i> Sessions for ${displayDate}</h2>
                </div>

                <div class="sessions-grid">
                    <c:choose>
                        <c:when test="${empty sessions}">
                            <div class="no-sessions">
                                <i class="fas fa-calendar-times"></i>
                                <h3>No Sessions Available</h3>
                                <p>No counseling sessions scheduled for this date. Create new sessions or generate default time slots.</p>
                                <div style="display: flex; gap: 15px; justify-content: center; margin-top: 25px;">
                                    <button class="add-session-btn" onclick="openAddSessionModal()">
                                        <i class="fas fa-plus"></i> Add Session
                                    </button>
                                    <button class="add-session-btn" onclick="generateDefaultSlots('${selectedDate}')" 
                                            style="background: linear-gradient(135deg, #6ee7b7 0%, #34d399 100%);">
                                        <i class="fas fa-magic"></i> Generate Slots
                                    </button>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${sessions}" var="sess" varStatus="loop">
                                <%
                                    Session sess = (Session) pageContext.getAttribute("sess");
                                    String startTime = "N/A";
                                    String endTime = "N/A";
                                    String duration = "N/A";

                                    try {
                                        if (sess.getStartTime() != null) {
                                            startTime = new SimpleDateFormat("hh:mm a").format(sess.getStartTime());
                                        }
                                        if (sess.getEndTime() != null) {
                                            endTime = new SimpleDateFormat("hh:mm a").format(sess.getEndTime());
                                        }

                                        // Calculate duration
                                        if (sess.getStartTime() != null && sess.getEndTime() != null) {
                                            long dur = sess.getEndTime().getTime() - sess.getStartTime().getTime();
                                            long hours = dur / (1000 * 60 * 60);
                                            long minutes = (dur % (1000 * 60 * 60)) / (1000 * 60);
                                            duration = hours + "h " + minutes + "m";
                                        }
                                    } catch (Exception e) {
                                        startTime = "Error";
                                        endTime = "Error";
                                    }

                                    String status = sess.getSessionStatus() != null ? sess.getSessionStatus() : "available";
                                    pageContext.setAttribute("startTime", startTime);
                                    pageContext.setAttribute("endTime", endTime);
                                    pageContext.setAttribute("duration", duration);
                                    pageContext.setAttribute("status", status);
                                %>
                                <div class="session-card" style="animation-delay: ${loop.index * 0.1}s; opacity: 0;">
                                    <div class="session-header">
                                        <div class="session-time">
                                            <i class="fas fa-clock" style="color: #A56CD1;"></i>
                                            <span class="time-text">${startTime} - ${endTime}</span>
                                        </div>
                                    </div>

                                    <div class="session-status status-${status}">
                                        <i class="fas ${status == 'available' ? 'fa-check-circle' : status == 'booked' ? 'fa-calendar-check' : 'fa-ban'}"></i>
                                        <span>${status.toUpperCase()}</span>
                                    </div>

                                    <div class="session-info">
                                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
                                            <span style="color: #8B7BA6; font-size: 0.9em;">
                                                <i class="fas fa-user-clock"></i> Duration: ${duration}
                                            </span>
                                        </div>
                                    </div>

                                    <div class="session-actions">
                                        <c:choose>
                                            <c:when test="${status == 'available'}">
                                                <button class="btn-action btn-unavailable" 
                                                        onclick="changeStatus(${sess.sessionID}, 'unavailable', '${startTime} - ${endTime}', '${selectedDate}')">
                                                    <i class="fas fa-ban"></i> Mark Unavailable
                                                </button>
                                            </c:when>
                                            <c:when test="${status == 'unavailable'}">
                                                <button class="btn-action btn-available" 
                                                        onclick="changeStatus(${sess.sessionID}, 'available', '${startTime} - ${endTime}', '${selectedDate}')">
                                                    <i class="fas fa-check"></i> Mark Available
                                                </button>
                                            </c:when>
                                        </c:choose>

                                        <c:if test="${status != 'booked'}">
                                            <button class="btn-action btn-delete" 
                                                    onclick="deleteSession(${sess.sessionID}, '${startTime} - ${endTime}', '${selectedDate}')">
                                                <i class="fas fa-trash"></i> Delete
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

        <div id="addSessionModal" class="status-modal-overlay">
            <div class="status-modal">
                <div class="modal-header">
                    <h3><i class="fas fa-plus"></i> Add New Session</h3>
                    <button class="modal-close" onclick="closeAddSessionModal()">&times;</button>
                </div>
                <div class="modal-body">
                    <form action="SessionServlet" method="POST" onsubmit="return validateSessionTime()">
                        <input type="hidden" name="action" value="addSession">
                        <input type="hidden" name="date" value="<%= selectedDate %>">

                        <div class="form-group">
                            <label for="startTime">Start Time</label>
                            <input type="time" id="startTime" name="startTime" required>
                        </div>

                        <div class="form-group">
                            <label for="endTime">End Time</label>
                            <input type="time" id="endTime" name="endTime" required>
                        </div>

                        <div class="modal-buttons">
                            <button type="submit" class="btn-submit">Add Session</button>
                            <button type="button" class="btn-cancel" onclick="closeAddSessionModal()">Cancel</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <div id="deleteModal" class="status-modal-overlay">
            <div class="status-modal">
                <div class="modal-header">
                    <h3><i class="fas fa-trash"></i> Delete Session</h3>
                    <button class="modal-close" onclick="closeDeleteModal()">&times;</button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to delete this session?</p>
                    <form id="deleteForm" action="SessionServlet" method="POST">
                        <input type="hidden" name="action" value="deleteSession">
                        <input type="hidden" name="sessionID" id="deleteSessionId">
                        <input type="hidden" name="date" value="<%= selectedDate %>">

                        <div class="modal-buttons">
                            <button type="submit" class="btn-delete">Delete</button>
                            <button type="button" class="btn-cancel" onclick="closeDeleteModal()">Cancel</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        <div id="statusModal" class="status-modal-overlay">
            <div class="status-modal">
                <div class="modal-header">
                    <h3><i class="fas fa-exchange-alt"></i> Update Status Session</h3>
                    <button class="modal-close" onclick="closeStatusModal()">&times;</button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to change the status session?</p>
                    <form id="changeStatusForm" action="SessionServlet" method="POST">
                        <input type="hidden" name="action" value="updateStatus">  
                        <input type="hidden" name="sessionID" id="changeStatusId">
                        <input type="hidden" name="status" id="changeStatusValue">
                        <input type="hidden" name="date" value="<%= selectedDate %>">

                        <div class="modal-buttons">
                            <button type="submit" class="btn-confirm">Change</button>
                            <button type="button" class="btn-cancel" onclick="closeStatusModal()">Cancel</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script>
            function openAddSessionModal() {
                document.getElementById('addSessionModal').style.display = 'flex';
            }

            function closeAddSessionModal() {
                document.getElementById('addSessionModal').style.display = 'none';
            }

            function openDeleteModal(sessionId) {
                document.getElementById('deleteSessionId').value = sessionId;
                document.getElementById('deleteModal').style.display = 'flex';
            }

            function closeDeleteModal() {
                document.getElementById('deleteModal').style.display = 'none';
            }

            function changeStatus(sessionId, newStatus, timeSlot, selectedDate) {
                openStatusModal(sessionId, newStatus);
            }

            function openStatusModal(sessionId, newStatus) {
                document.getElementById('changeStatusId').value = sessionId;
                document.getElementById('changeStatusValue').value = newStatus;
                document.getElementById('statusModal').style.display = 'flex';
            }

            function closeStatusModal() {
                document.getElementById('statusModal').style.display = 'none';
            }

            function deleteSession(sessionId) {
                openDeleteModal(sessionId);
            }

            function generateDefaultSlots() {
                if (confirm('Generate default time slots for this date?\n\nThis will create sessions from:\n8:00-9:00, 9:00-10:00, 10:00-11:00,\n11:00-12:00, 14:00-15:00, 15:00-16:00')) {
                    var form = document.createElement('form');
                    form.method = 'POST';
                    form.action = 'SessionServlet';

                    form.innerHTML = '<input type="hidden" name="action" value="generateSlots">' +
                                    '<input type="hidden" name="date" value="<%= selectedDate %>">';

                    document.body.appendChild(form);
                    form.submit();
                }
            }

            function validateSessionTime() {
                var startTime = document.getElementById('startTime').value;
                var endTime = document.getElementById('endTime').value;

                if (startTime >= endTime) {
                    alert('Start time must be before end time!');
                    return false;
                }

                return true;
            }

            window.onclick = function(event) {
                var addModal = document.getElementById('addSessionModal');
                var deleteModal = document.getElementById('deleteModal');

                if (event.target == addModal) {
                    closeAddSessionModal();
                }
                if (event.target == deleteModal) {
                    closeDeleteModal();
                }
            }

            window.onload = function() {
                var today = new Date();
                var dd = String(today.getDate()).padStart(2, '0');
                var mm = String(today.getMonth() + 1).padStart(2, '0'); // January is 0!
                var yyyy = today.getFullYear();

                today = yyyy + '-' + mm + '-' + dd;
                document.getElementById('sessionDate').setAttribute('min', today);

                var selectedDate = document.getElementById('sessionDate').value;
                if (selectedDate < today) {
                    window.location.href = 'SessionServlet?action=viewPage';
                }
            };


            function validateDateSelection(dateInput) {
                var selectedDate = new Date(dateInput.value);
                var today = new Date();
                today.setHours(0, 0, 0, 0); 

                if (selectedDate < today) {
                    alert('You cannot view past dates!');
                    var tomorrow = new Date();
                    tomorrow.setDate(tomorrow.getDate() + 1);
                    var dd = String(tomorrow.getDate()).padStart(2, '0');
                    var mm = String(tomorrow.getMonth() + 1).padStart(2, '0');
                    var yyyy = tomorrow.getFullYear();

                    dateInput.value = yyyy + '-' + mm + '-' + dd;
                    document.getElementById('dateForm').submit();
                    return false;
                }
                return true;
            }
        </script>
    </body>
</html>
