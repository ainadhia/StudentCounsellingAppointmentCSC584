<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.counselling.model.AppointmentView"%>
<%@page import="com.counselling.model.Student"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Appointments | Student</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/global-style.css">
    <style>
        /* ADD THIS CSS TO SHOW THE SELECTION COLOR */
        #rescheduleSessions .session-card.selected {
            border: 2px solid #5D2E8C !important;
            background-color: #f3ebff !important;
            box-shadow: 0 4px 12px rgba(93, 46, 140, 0.2);
            transform: translateY(-2px);
        }
        
        #rescheduleSessions .sessions-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
            margin-top: 15px;
        }

        /* Ensure cards have a base border to avoid jumping when selected */
        #rescheduleSessions .session-card {
            border: 1px solid #ddd;
            padding: 15px;
            border-radius: 12px;
            transition: all 0.2s ease;
            background: #fff;
        }
    </style>
</head>
<body>
<%
    Student student = (Student) session.getAttribute("user");
    if (student == null || session.getAttribute("role") == null || !"S".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<AppointmentView> appointments = (List<AppointmentView>) request.getAttribute("appointments");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    SimpleDateFormat dateFmt = new SimpleDateFormat("EEE, MMM d, yyyy");
    SimpleDateFormat timeFmt = new SimpleDateFormat("HH:mm");
%>

    <nav class="navbar">
        <div class="navbar-logo">
            <span class="logo-text">UITM COUNSELLING</span>
        </div>
        <ul class="navbar-menu">
            <li><a  href="<%=request.getContextPath()%>/StudentDashboardServlet"><span class="menu-text" style="font-size: 0.85rem;">| Dashboard</span></a></li>
            <li><a href="bookAppointmentStudent.jsp"><span class="menu-text" style="font-size: 0.85rem;">| Book Appointment</span></a></li>
            <li class="active"><a href="StudentAppointmentServlet?action=manage"><span class="menu-text" style="font-size: 0.85rem;">| Manage Appointments</span></a></li>
            <li><a href="StudentAppointmentServlet?action=history"><span class="menu-text" style="font-size: 0.85rem;">| History</span></a></li>
            <li><a href="<%=request.getContextPath()%>/StudentProfileServlet"><span class="menu-text" style="font-size: 0.85rem;">| Profile</span></a></li>
            <li><a href="<%=request.getContextPath()%>/LogoutServlet"><span class="menu-text" style="font-size: 0.85rem;">| Logout</span></a></li>
        </ul>
    </nav>

<div class="main-content">
    <div class="main-header">
        <div>
            <h1>Manage Appointments</h1>
            <p class="welcome-subtitle">View upcoming appointments, reschedule or cancel</p>
        </div>
        <div class="header-date"><%= new java.text.SimpleDateFormat("EEEE, MMMM d, yyyy").format(new java.util.Date()) %></div>
    </div>

    <% if (errorMessage != null) { %>
        <div class="alert alert-error">
            <i class="fas fa-exclamation-circle"></i>
            <span><%= errorMessage %></span>
        </div>
    <% } %>
    <% if (successMessage != null) { %>
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i>
            <span><%= successMessage %></span>
        </div>
    <% } %>

    <section class="content-section">
        <div class="section-header">
            <h4><i class="fas fa-clock"></i> Upcoming Appointments</h4>
        </div>

        <% if (appointments == null || appointments.isEmpty()) { %>
            <div style="padding:20px; background:#f5f7fa; border-radius:8px; text-align:center; color:#6a3ba0;">
                <i class="fas fa-info-circle" style="font-size:2rem;"></i>
                <p style="margin-top:10px;">No upcoming appointments. Book a new appointment to get started.</p>
            </div>
        <% } else { %>
            <div class="sessions-grid">
            <% for (AppointmentView a : appointments) {
                Date start = a.getStartTime();
                Date end = a.getEndTime();
                String statusClass = a.getStatus() != null ? a.getStatus().toLowerCase() : "";
            %>
                <div class="session-card <%= statusClass %>">
                    <div class="card-info-line" style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"><span class="card-label">DATE :</span> <span><%= dateFmt.format(start).replace(", ", " ") %></span></div>
                    <div class="card-info-line" style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"><span class="card-label">SESSION :</span> <span><%= timeFmt.format(start) %> - <%= timeFmt.format(end) %></span></div>
                    <div class="card-info-line" style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"><span class="card-label">STATUS :</span> <span class="status-text <%= statusClass %>"><%= a.getStatus() %></span></div>
                    <div class="card-info-line" style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"><span class="card-label">COUNSELOR :</span> <span><%= a.getCounselorName() != null ? a.getCounselorName() : "-" %></span></div>
                    <div class="card-info-line" style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"><span class="card-label">DESCRIPTION :</span> <span><%= a.getDescription() != null ? a.getDescription() : "No notes" %></span></div>
                    <div class="button-row" style="margin-top:16px;">
                        <button type="button" class="btn-cancel-gray" onclick="openCancel(<%= a.getAppointmentID() %>, <%= a.getSessionID() %>)">
                            <i class="fas fa-times-circle"></i> Cancel
                        </button>
                        <button type="button" class="btn-reschedule" onclick="openReschedule(<%= a.getAppointmentID() %>, <%= a.getSessionID() %>)">
                            <i class="fas fa-edit"></i> Reschedule
                        </button>
                    </div>
                </div>
            <% } %>
            </div>
        <% } %>
    </section>
</div>

<div id="cancelModal" class="status-modal-overlay" style="display:none;">
    <div class="status-modal" style="max-width:480px;">
        <div class="modal-header">
            <h3><i class="fas fa-times-circle"></i> Cancel Appointment</h3>
            <button class="modal-close" onclick="closeCancel()">&times;</button>
        </div>
        <div class="modal-body">
            <p class="modal-message">Are you sure you want to cancel this appointment?</p>
            <div class="button-row right">
                <button class="btn-secondary" type="button" onclick="closeCancel()">Keep</button>
                <button class="btn-danger" type="button" onclick="submitCancel()">Cancel Appointment</button>
            </div>
        </div>
    </div>
</div>

<div id="rescheduleModal" class="status-modal-overlay" style="display:none;">
    <div class="status-modal" style="max-width:720px;">
        <div class="modal-header">
            <h3><i class="fas fa-calendar-plus"></i> Reschedule Appointment</h3>
            <button class="modal-close" onclick="closeReschedule()">&times;</button>
        </div>
        <div class="modal-body">
            <label style="display:block; margin-bottom:8px; font-weight:600; color:#5D2E8C;">Select New Date</label>
            <input type="date" id="rescheduleDate" class="date-input" style="width:100%;" min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date(System.currentTimeMillis() + 86400000)) %>" onchange="loadRescheduleSessions(this.value)">
            <div id="rescheduleSessions" style="margin-top:16px;"></div>
            <div class="button-row right" style="margin-top:16px;">
                <button class="btn-secondary" type="button" onclick="closeReschedule()">Close</button>
                <button class="btn-submit" type="button" onclick="submitReschedule()">Confirm Reschedule</button>
            </div>
        </div>
    </div>
</div>

<form id="cancelForm" method="POST" action="StudentAppointmentController" style="display:none;">
    <input type="hidden" name="action" value="cancelAppointment">
    <input type="hidden" name="appointmentID" id="cancelAppointmentID">
    <input type="hidden" name="sessionID" id="cancelSessionID">
</form>

<form id="rescheduleForm" method="POST" action="StudentAppointmentController" style="display:none;">
    <input type="hidden" name="action" value="rescheduleAppointment">
    <input type="hidden" name="appointmentID" id="rescheduleAppointmentID">
    <input type="hidden" name="oldSessionID" id="rescheduleOldSessionID">
    <input type="hidden" name="newSessionID" id="rescheduleNewSessionID">
</form>

<script>
    let pendingCancel = { appointmentID: null, sessionID: null };
    let pendingReschedule = { appointmentID: null, oldSessionID: null, newSessionID: null };

    function openCancel(appId, sessionId) {
        pendingCancel.appointmentID = appId;
        pendingCancel.sessionID = sessionId;
        document.getElementById('cancelModal').style.display = 'flex';
    }
    function closeCancel() { document.getElementById('cancelModal').style.display = 'none'; }
    function submitCancel() {
        document.getElementById('cancelAppointmentID').value = pendingCancel.appointmentID;
        document.getElementById('cancelSessionID').value = pendingCancel.sessionID;
        document.getElementById('cancelForm').submit();
    }

    function openReschedule(appId, oldSessionId) {
        pendingReschedule.appointmentID = appId;
        pendingReschedule.oldSessionID = oldSessionId;
        pendingReschedule.newSessionID = null;
        document.getElementById('rescheduleSessions').innerHTML = '';
        document.getElementById('rescheduleDate').value = '';
        document.getElementById('rescheduleModal').style.display = 'flex';
    }
    function closeReschedule() { document.getElementById('rescheduleModal').style.display = 'none'; }

    // This function handles the click and the visual class
    function selectSession(sessionID, element) {
        pendingReschedule.newSessionID = sessionID;
        // Remove 'selected' class from all other cards in the reschedule modal
        document.querySelectorAll('#rescheduleSessions .session-card').forEach(c => c.classList.remove('selected'));
        // Add 'selected' class to the clicked element
        element.classList.add('selected');
    }

    function loadRescheduleSessions(dateVal) {
        const container = document.getElementById('rescheduleSessions');
        container.innerHTML = '<p style="color:#6a3ba0;">Loading sessions...</p>';
        if (!dateVal) return;
        fetch('StudentAppointmentController?action=availableSessions&date=' + dateVal)
            .then(r => r.json())
            .then(data => {
                if (!data || data.length === 0) {
                    container.innerHTML = '<p style="color:#6a3ba0;">No available sessions for this date.</p>';
                    return;
                }
                let html = '<div class="sessions-grid">';
                data.forEach(s => {
                    const startTime = new Date(s.start).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'});
                    const endTime = new Date(s.end).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'});
                    
                    // Added selectSession call to onclick
                    html += '<div class="session-card available" onclick="selectSession(' + s.sessionID + ', this)" style="cursor: pointer;">';
                    html += '<div class="session-time"><i class="fas fa-clock"></i> ' + startTime + ' - ' + endTime + '</div>';
                    html += '<div class="session-status-pill available"><i class="fas fa-check"></i> AVAILABLE</div>';
                    html += '</div>';
                });
                html += '</div>';
                container.innerHTML = html;
            })
            .catch(() => {
                container.innerHTML = '<p style="color:#c62828;">Failed to load sessions.</p>';
            });
    }

    function submitReschedule() {
        if (!pendingReschedule.newSessionID) {
            alert('Please select a new session.');
            return;
        }
        document.getElementById('rescheduleAppointmentID').value = pendingReschedule.appointmentID;
        document.getElementById('rescheduleOldSessionID').value = pendingReschedule.oldSessionID;
        document.getElementById('rescheduleNewSessionID').value = pendingReschedule.newSessionID;
        document.getElementById('rescheduleForm').submit();
    }
</script>
</body>
</html>