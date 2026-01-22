<%-- 
    Document   : sessionEditCounsellor
    Created on : Jan 15, 2026
    Author     : Aina
--%>

<%@page import="com.counselling.model.Counselor"%>
<%@page import="com.counselling.model.Session"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
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
    if (counselor == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String counselorName = counselor.getUserName();
    String counselorID = counselor.getCounselorID();
    
    session.setAttribute("counselorID", counselorID);
    
    String dateParam = request.getParameter("date");
    java.util.Date tomorrow = new java.util.Date(System.currentTimeMillis() + 86400000);
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
    String defaultDate = (dateParam != null && !dateParam.isEmpty()) ? dateParam : sdf.format(tomorrow);

    java.text.SimpleDateFormat displayFormat = new java.text.SimpleDateFormat("EEEE, MMMM d, yyyy");
    java.util.Date displayDateObj = sdf.parse(defaultDate);
    String displayDate = displayFormat.format(displayDateObj);
    
    List<Session> sessionsList = (List<Session>) request.getAttribute("sessions");
    request.setAttribute("sessionsList", sessionsList); 
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Manage Counseling Sessions</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="global-style.css">
    </head>
    <body>
        <nav class="navbar">
            <div class="navbar-logo">
                <span class="logo-text">COUNSELOR SYSTEM</span>
            </div>

            <ul class="navbar-menu">
                <li class="${param.activeTab == 'dashboard' ? 'active' : ''}">
                    <a href="counsellorDashboard.jsp">
                        <span class="menu-text">
                            <span>|</span>
                            <span>Dashboard</span>
                        </span>
                    </a>
                </li>
                <li class="${param.activeTab == 'students' ? 'active' : ''}">
                    <a href="listOfStudent.jsp">
                        <span class="menu-text">
                            <span>|</span>
                            <span>List of Students</span>
                        </span>
                    </a>
                </li>
                <li class="${param.activeTab == 'appointment' ? 'active' : ''}">
                    <a href="bookAppointmentCounsellor.jsp">
                        <span class="menu-text">
                            <span>|</span>
                            <span>Appointment</span>
                        </span>
                    </a>
                </li>
                <li class="${param.activeTab == 'session' ? 'active' : ''}">
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

        <!-- Main Content -->
        <div class="main-content">
            <div class="main-header">
                <div>
                    <h1>Manage Counseling Sessions</h1>
                    <p class="welcome-subtitle">Create, manage, and view available session slots</p>
                </div>
                <div class="header-date">
                    <%= new java.text.SimpleDateFormat("EEEE, MMMM d, yyyy").format(new java.util.Date()) %>
                </div>
            </div>

            <div class="content-section">
                <!-- Date Selector -->
                <div class="section-header">
                    <h4><i class="fas fa-calendar-day"></i> Select Session Date</h4>
                    <input type="date" 
                           class="date-input" 
                           id="sessionDateInput"
                           value="<%= defaultDate %>"
                           onchange="loadSessions(this.value)">
                    <span id="currentDateDisplay"><%= displayDate %></span>

                    <button class="add-session-btn" onclick="toggleSessionForm(true)">
                        <i class="fas fa-plus-circle"></i> Add New Session
                    </button>

                    <button class="add-session-btn" onclick="generateDailySlots()" style="background: linear-gradient(135deg, #28a745 0%, #20c997 100%);">
                        <i class="fas fa-bolt"></i> Generate Daily Slots
                    </button>
                </div>

                <div id="sessionFormContainer" style="display: none;">
                    <h4><i class="fas fa-clock"></i> Add Custom Session</h4>

                    <div class="form-group">
                        <label>Start Time</label>
                        <input type="time" id="formStartTime" required>
                    </div>

                    <div class="form-group">
                        <label>End Time</label>
                        <input type="time" id="formEndTime" required>
                    </div>

                    <div class="form-buttons">
                        <button class="btn-submit" onclick="createNewSession()">
                            <i class="fas fa-save"></i> Create Session
                        </button>
                        <button class="btn-cancel" onclick="toggleSessionForm(false)">
                            <i class="fas fa-times"></i> Cancel
                        </button>
                    </div>
                </div>

                <h3 class="sessions-list-header">
                    <i class="fas fa-list-alt"></i> Sessions for <span id="displayDateText"><%= displayDate %></span>
                </h3>

                <div class="sessions-grid" id="availableSessionsGrid">
                    <c:choose>
                        <c:when test="${empty sessionsList}">
                            <div class="no-sessions">
                                <i class="fas fa-calendar-times"></i>
                                <h3>No Sessions Available</h3>
                                <p>No counseling sessions available for this date.</p>
                                <button onclick="generateDailySlots()" class="add-session-btn">
                                    <i class="fas fa-bolt"></i> Generate Default Slots
                                </button>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="session" items="${sessionsList}">
                                <div class="session-card">
                                    <div class="session-header">
                                        <div class="session-time">
                                            <i class="fas fa-clock"></i>
                                            <span class="time-text">
                                                <c:out value="${session.formattedStartTime}" /> - <c:out value="${session.formattedEndTime}" />
                                            </span>
                                        </div>
                                    </div>

                                    <div class="session-status 
                                        <c:choose>
                                            <c:when test="${session.sessionStatus eq 'available'}">status-available</c:when>
                                            <c:when test="${session.sessionStatus eq 'booked'}">status-booked</c:when>
                                            <c:when test="${session.sessionStatus eq 'cancelled'}">status-cancelled</c:when>
                                            <c:when test="${session.sessionStatus eq 'unavailable'}">status-unavailable</c:when>
                                            <c:otherwise>status-unknown</c:otherwise>
                                        </c:choose>">
                                        <i class="fas 
                                            <c:choose>
                                                <c:when test="${session.sessionStatus eq 'available'}">fa-calendar-plus</c:when>
                                                <c:when test="${session.sessionStatus eq 'booked'}">fa-calendar-check</c:when>
                                                <c:when test="${session.sessionStatus eq 'cancelled'}">fa-calendar-times</c:when>
                                                <c:when test="${session.sessionStatus eq 'unavailable'}">fa-calendar-times</c:when>
                                                <c:otherwise>fa-calendar</c:otherwise>
                                            </c:choose>">
                                        </i>
                                        <span><c:out value="${session.sessionStatus}" /></span>
                                    </div>

                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <!-- Status Change Modal -->
        <div class="status-modal-overlay" id="statusModalOverlay">
            <div class="status-modal">
                <div class="modal-header">
                    <h3><i class="fas fa-exchange-alt"></i> Toggle Session Status</h3>
                    <button class="modal-close" onclick="closeStatusModal()">
                        <i class="fas fa-times"></i>
                    </button>
                </div>

                <div class="modal-body">
                    <div class="session-info">
                        <p><strong>Date:</strong> <span id="modalSessionDate"></span></p>
                        <p><strong>Time:</strong> <span id="modalSessionTime"></span></p>
                        <p><strong>Current Status:</strong> <span id="modalCurrentStatus"></span></p>
                    </div>

                    <div class="status-toggle">
                        <h4>Change to:</h4>
                        <div class="toggle-options">
                            <div class="toggle-option active-option" onclick="selectStatus('available')">
                                <i class="fas fa-calendar-check"></i>
                                <span>Available</span>
                                <p class="option-desc">Open for booking</p>
                            </div>

                            <div class="toggle-option unavailable-option" onclick="selectStatus('unavailable')">
                                <i class="fas fa-calendar-times"></i>
                                <span>Unavailable</span>
                                <p class="option-desc">Not open for booking</p>
                            </div>
                        </div>
                    </div>

                    <input type="hidden" id="selectedSessionId">
                    <input type="hidden" id="selectedNewStatus" value="">

                    <div class="modal-actions">
                        <button class="btn-cancel" onclick="closeStatusModal()">
                            <i class="fas fa-times"></i> Cancel
                        </button>
                        <button class="btn-submit" onclick="updateSessionStatus()" id="updateStatusBtn">
                            <i class="fas fa-save"></i> Update Status
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Success/Error Popup -->
        <div class="success-popup-overlay" id="successPopupOverlay">
            <div class="success-popup-modal" id="successPopupModal">
                <div class="icon" id="popupIcon"></div>
                <p id="successMessage">Notification Message</p>
            </div>
        </div>

        <script>
        let currentSelectedDate = "<%= defaultDate %>";
        let currentSelectedSessionId = null;
        let currentSelectedSessionStatus = null;

        const counselorID = "<%= counselorID %>";

        document.addEventListener('DOMContentLoaded', function() {
            console.log("=== PAGE LOADED ===");
            console.log("CounselorID: " + counselorID);
            console.log("Default Date: " + currentSelectedDate);

            const today = new Date();
            const todayFormatted = today.toISOString().split('T')[0];
            document.getElementById('sessionDateInput').min = todayFormatted;

            loadSessions(currentSelectedDate);

            const modalOverlay = document.getElementById('statusModalOverlay');
            if (modalOverlay) {
                modalOverlay.addEventListener('click', function(event) {
                    if (event.target === this) {
                        closeStatusModal();
                    }
                });
            }
        });

        function loadSessions(selectedDate) {
            if (!selectedDate) {
                console.error("No date provided to loadSessions");
                return;
            }

            currentSelectedDate = selectedDate;
            console.log("\n=== LOAD SESSIONS ===");
            console.log("Loading sessions for date:", selectedDate);

            const dateObj = new Date(selectedDate + 'T00:00:00');
            const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
            const formattedDate = dateObj.toLocaleDateString('en-US', options);

            document.getElementById('currentDateDisplay').textContent = formattedDate;
            document.getElementById('displayDateText').textContent = formattedDate;

            const grid = document.getElementById('availableSessionsGrid');
            if (!grid) {
                console.error("Grid element not found!");
                return;
            }

            grid.innerHTML = 
                '<div class="loading-sessions">' +
                '<i class="fas fa-spinner fa-spin"></i>' +
                '<p>Loading sessions...</p>' +
                '</div>';

            const fetchUrl = "<%= request.getContextPath() %>/SessionServlet?" + 
                            "action=getSessionsByDate&" +
                            "date=" + selectedDate + "&" +
                            "counselorID=" + counselorID;

            console.log("Fetching from:", fetchUrl);

            fetch(fetchUrl, {
                method: 'GET',
                headers: {
                    'Cache-Control': 'no-cache',
                    'Accept': 'application/json'
                }
            })
            .then(response => {
                console.log("Response status:", response.status, response.statusText);

                if (!response.ok) {
                    throw new Error(`Server returned ${response.status}: ${response.statusText}`);
                }

                return response.json();
            })
            .then(data => {
                console.log("✅ Data received:", data);
                console.log("   Type:", typeof data);
                console.log("   Is Array?:", Array.isArray(data));

                renderSessionsWithJS(data);
            })
            .catch(error => {
                console.error('❌ ERROR loading sessions:', error);

                grid.innerHTML = 
                    '<div class="error-message">' +
                    '<i class="fas fa-exclamation-circle"></i>' +
                    '<h4>Unable to Load Sessions</h4>' +
                    '<p>' + (error.message || 'Failed to load sessions.') + '</p>' +
                    '<button onclick="loadSessions(\'' + selectedDate + '\')" class="btn-retry">' +
                    '<i class="fas fa-redo"></i> Try Again' +
                    '</button>' +
                    '</div>';
            });
        }

        function renderSessionsWithJS(data) {
            console.log("🖌️ Raw data received:", data);

            let sessions = data;

            if (data && typeof data === 'object' && !Array.isArray(data)) {
                if (data.sessions && Array.isArray(data.sessions)) {
                    sessions = data.sessions;
                } else if (data.data && Array.isArray(data.data)) {
                    sessions = data.data;
                }
            }

            console.log("🖌️ Processed sessions:", sessions);
            console.log("   Is Array?:", Array.isArray(sessions));
            console.log("   Length:", Array.isArray(sessions) ? sessions.length : 'N/A');

            const grid = document.getElementById('availableSessionsGrid');
            if (!grid) return;

            if (!sessions || !Array.isArray(sessions) || sessions.length === 0) {
                grid.innerHTML = 
                    '<div class="no-sessions">' +
                    '<i class="fas fa-calendar-times"></i>' +
                    '<h3>No Sessions Available</h3>' +
                    '<p>No counseling sessions available for this date.</p>' +
                    '<button onclick="generateDailySlots()" class="add-session-btn">' +
                    '<i class="fas fa-bolt"></i> Generate Default Slots' +
                    '</button>' +
                    '</div>';
                return;
            }

            let html = '';

            sessions.forEach(function(session) {
                console.log("  - Rendering session:", session);

                const status = session.sessionStatus || 'available';
                const sessionId = session.sessionID || session.id || '';

                let statusClass = '';
                let statusIcon = '';
                let statusText = status.toUpperCase();

                switch(status.toLowerCase()) {
                    case 'available':
                        statusClass = 'status-available';
                        statusIcon = 'fa-calendar-check';
                        break;
                    case 'booked':
                        statusClass = 'status-booked';
                        statusIcon = 'fa-user-check';
                        break;
                    case 'cancelled':
                        statusClass = 'status-cancelled';
                        statusIcon = 'fa-calendar-times';
                        break;
                    case 'unavailable':
                        statusClass = 'status-unavailable';
                        statusIcon = 'fa-calendar-times';
                        break;
                    default:
                        statusClass = 'status-available';
                        statusIcon = 'fa-calendar';
                }

                const formatTime = function(timeStr) {
                    if (!timeStr) return '--:--';
                    try {
                        const [hours, minutes] = timeStr.split(':');
                        const hour = parseInt(hours);
                        const ampm = hour >= 12 ? 'PM' : 'AM';
                        const hour12 = hour % 12 || 12;
                        return hour12 + ':' + minutes + ' ' + ampm;
                    } catch (e) {
                        return timeStr;
                    }
                };

                const startTime = formatTime(session.startTime);
                const endTime = formatTime(session.endTime);

                html += '<div class="session-card">' +
                        '<div class="session-header">' +
                        '<div class="session-time">' +
                        '<i class="fas fa-clock"></i>' +
                        '<span class="time-text">' + startTime + ' - ' + endTime + '</span>' +
                        '</div>' +
                        '</div>' +
                        '<div class="session-status ' + statusClass + '" ' +
                        'onclick="openStatusModal(\'' + sessionId + '\', \'' + status + '\', \'' + startTime + ' - ' + endTime + '\')" ' +
                        'style="cursor: pointer;">' +
                        '<i class="fas ' + statusIcon + '"></i>' +
                        '<span>' + statusText + '</span>' +
                        '</div>' +
                        '</div>';
            });

            grid.innerHTML = html;
            console.log("✅ Sessions rendered successfully");
        }

        function openStatusModal(sessionId, currentStatus, sessionTime) {
            console.log("Opening modal for session:", sessionId, "status:", currentStatus, "time:", sessionTime);

            currentSelectedSessionId = sessionId;
            currentSelectedSessionStatus = currentStatus;

            const dateObj = new Date(currentSelectedDate + 'T00:00:00');
            const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
            const formattedDate = dateObj.toLocaleDateString('en-US', options);

            const modalDateElement = document.getElementById('modalSessionDate');
            const modalTimeElement = document.getElementById('modalSessionTime');
            const modalStatusElement = document.getElementById('modalCurrentStatus');

            if (modalDateElement) modalDateElement.textContent = formattedDate;
            if (modalTimeElement) modalTimeElement.textContent = sessionTime;

            if (modalStatusElement) {
                modalStatusElement.textContent = currentStatus.toUpperCase();
                if (currentStatus === 'available') {
                    modalStatusElement.style.background = 'linear-gradient(135deg, #e8f5e9 0%, #d0efd0 100%)';
                    modalStatusElement.style.color = '#2e7d32';
                    modalStatusElement.style.border = '2px solid #c8e6c9';
                } else {
                    modalStatusElement.style.background = 'linear-gradient(135deg, #ffebee 0%, #ffcdd2 100%)';
                    modalStatusElement.style.color = '#d32f2f';
                    modalStatusElement.style.border = '2px solid #ef9a9a';
                }
            }

            const newStatusInput = document.getElementById('selectedNewStatus');
            const updateBtn = document.getElementById('updateStatusBtn');

            if (newStatusInput) newStatusInput.value = '';
            if (updateBtn) updateBtn.disabled = true;

            const optionsElements = document.querySelectorAll('.toggle-option');
            optionsElements.forEach(option => {
                option.classList.remove('selected');
            });

            if (currentStatus === 'available') {
                selectStatus('unavailable');
            } else {
                selectStatus('available');
            }

            const modalOverlay = document.getElementById('statusModalOverlay');
            if (modalOverlay) {
                modalOverlay.style.display = 'flex';
            }
        }

        function selectStatus(newStatus) {
            console.log("Selected status:", newStatus);

            const newStatusInput = document.getElementById('selectedNewStatus');
            if (newStatusInput) newStatusInput.value = newStatus;

            const optionsElements = document.querySelectorAll('.toggle-option');
            optionsElements.forEach(option => {
                option.classList.remove('selected');
            });

            if (newStatus === 'available') {
                const availableOption = document.querySelector('.active-option');
                if (availableOption) availableOption.classList.add('selected');
            } else {
                const unavailableOption = document.querySelector('.unavailable-option');
                if (unavailableOption) unavailableOption.classList.add('selected');
            }

            const updateBtn = document.getElementById('updateStatusBtn');
            if (updateBtn) updateBtn.disabled = false;
        }

        function updateSessionStatus() {
            const newStatusInput = document.getElementById('selectedNewStatus');
            if (!newStatusInput) return;

            const newStatus = newStatusInput.value;

            if (!newStatus) {
                showPopup("Please select a status", "error");
                return;
            }

            if (!currentSelectedSessionId) {
                showPopup("No session selected", "error");
                return;
            }

            console.log("Updating session", currentSelectedSessionId, "to", newStatus);

            const updateBtn = document.getElementById('updateStatusBtn');
            if (updateBtn) {
                updateBtn.disabled = true;
                updateBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Updating...';
            }

            const url = "<%= request.getContextPath() %>/SessionServlet?" + 
                       "action=updateStatus&" +
                       "sessionID=" + currentSelectedSessionId + "&" +
                       "status=" + newStatus;

            fetch(url, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showPopup("Status updated successfully!", "success");
                    closeStatusModal();
                    setTimeout(() => {
                        loadSessions(currentSelectedDate);
                    }, 1000);
                } else {
                    showPopup(data.message || "Failed to update status", "error");
                    if (updateBtn) {
                        updateBtn.disabled = false;
                        updateBtn.innerHTML = '<i class="fas fa-save"></i> Update Status';
                    }
                }
            })
            .catch(error => {
                console.error("Update error:", error);
                showPopup("Server error updating status", "error");
                if (updateBtn) {
                    updateBtn.disabled = false;
                    updateBtn.innerHTML = '<i class="fas fa-save"></i> Update Status';
                }
            });
        }

        function closeStatusModal() {
            const modalOverlay = document.getElementById('statusModalOverlay');
            if (modalOverlay) {
                modalOverlay.style.display = 'none';
            }
            currentSelectedSessionId = null;
            currentSelectedSessionStatus = null;
        }

        function generateDailySlots() {
            console.log("Generating daily slots for date:", currentSelectedDate);

            const url = "<%= request.getContextPath() %>/SessionServlet?" + 
                       "action=generateSlots&" +
                       "date=" + currentSelectedDate + "&" +
                       "counselorID=" + counselorID;

            showPopup("Generating default slots...", "info");

            fetch(url, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
            })
            .then(response => response.json())
            .then(result => {
                console.log("Generate slots result:", result);
                if (result.success) {
                    showPopup("Daily slots generated successfully!", "success");
                    setTimeout(() => {
                        loadSessions(currentSelectedDate);
                    }, 1500);
                } else {
                    showPopup(result.message || "Failed to generate slots", "error");
                }
            })
            .catch(error => {
                console.error("Error generating slots:", error);
                showPopup("Failed to generate slots: " + error.message, "error");
            });
        }

        function deleteSession(sessionID) {
            if (!confirm("Are you sure you want to delete this session?")) {
                return;
            }

            console.log("Deleting session:", sessionID);

            const url = "<%= request.getContextPath() %>/SessionServlet?" + 
                       "action=deleteSession&" +
                       "sessionID=" + sessionID;

            fetch(url, {
                method: 'POST'
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showPopup("Session deleted successfully!", "success");
                    setTimeout(() => loadSessions(currentSelectedDate), 1000);
                } else {
                    showPopup(data.message || "Failed to delete session", "error");
                }
            })
            .catch(error => {
                console.error("Delete error:", error);
                showPopup("Server error deleting session", "error");
            });
        }

        function toggleSessionForm(show) {
            const form = document.getElementById('sessionFormContainer');

            if (show) {
                form.style.display = 'block';

                const now = new Date();
                let hour = now.getHours();
                if (hour >= 16 || hour < 8) hour = 16;
                else hour = hour + 1;

                const defaultStart = String(hour).padStart(2, '0') + ":00";
                const defaultEnd = String(hour + 1).padStart(2, '0') + ":00";

                document.getElementById('formStartTime').value = defaultStart;
                document.getElementById('formEndTime').value = defaultEnd;

                form.scrollIntoView({ behavior: 'smooth' });
            } else {
                form.style.display = 'none';
            }
        }

        function createNewSession() {
            const startTime = document.getElementById("formStartTime").value;
            const endTime = document.getElementById("formEndTime").value;

            if (!startTime || !endTime) {
                showPopup("Please fill all fields", "error");
                return;
            }

            if (startTime >= endTime) {
                showPopup("Start time must be before end time", "error");
                return;
            }

            console.log("\n=== CREATE SESSION ===");
            console.log("Date:", currentSelectedDate);
            console.log("Time:", startTime, "-", endTime);

            const url = "<%= request.getContextPath() %>/SessionServlet";
            const params = new URLSearchParams();
            params.append("action", "addSession");
            params.append("date", currentSelectedDate);
            params.append("startTime", startTime);
            params.append("endTime", endTime);
            params.append("counselorID", counselorID);

            fetch(url, {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded",
                },
                body: params.toString()
            })
            .then(response => response.json())
            .then(data => {
                console.log("POST Response data:", data);

                if (data.success) {
                    showPopup("Session created successfully!", "success");
                    toggleSessionForm(false);

                    setTimeout(() => {
                        loadSessions(currentSelectedDate);
                    }, 800);
                } else {
                    showPopup(data.message || "Failed to create session", "error");
                }
            })
            .catch(err => {
                console.error("POST Error:", err);
                showPopup("Server error. Please try again.", "error");
            });
        }

        function showPopup(message, type) {
            const popup = document.getElementById('successPopupOverlay');
            const modal = document.getElementById('successPopupModal');
            const icon = document.getElementById('popupIcon');
            const msg = document.getElementById('successMessage');

            if (!popup || !modal || !icon || !msg) return;

            if (type === 'error') {
                icon.className = 'icon error-icon fas fa-exclamation-triangle';
                msg.style.color = '#dc3545';
            } else if (type === 'info') {
                icon.className = 'icon fas fa-info-circle';
                msg.style.color = '#17a2b8';
            } else {
                icon.className = 'icon success-icon fas fa-check-circle';
                msg.style.color = '#28a745';
            }

            msg.textContent = message;
            popup.style.display = 'flex';

            setTimeout(() => modal.classList.add('show'), 10);

            setTimeout(() => {
                modal.classList.remove('show');
                setTimeout(() => popup.style.display = 'none', 300);
            }, 3000);
        }    
        </script>
    </body>
</html>