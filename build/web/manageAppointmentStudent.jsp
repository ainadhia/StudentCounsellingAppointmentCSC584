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
        /* --- 1. General Card & Button Styles --- */
        .sessions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }

        .session-card {
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 12px;
            padding: 20px;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0,0,0,0.02);
        }
        
        .session-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.08);
            border-color: #d1d1d1;
        }

        /* Status Stripe on left */
        .session-card::before {
            content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 5px;
        }
        .session-card.pending::before { background: #A56CD1; }
        .session-card.approved::before { background: #2E7D32; }

        .card-info-line {
            display: flex; margin-bottom: 10px; font-size: 0.95rem; color: #555; align-items: center;
        }
        .card-label {
            font-weight: 600; color: #333; width: 100px; font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.5px; flex-shrink: 0;
        }
        .status-text {
            font-weight: 700; text-transform: uppercase; font-size: 0.85rem;
        }
        .status-text.pending { color: #A56CD1; }
        .status-text.approved { color: #2E7D32; }

        /* --- 2. Action Buttons (Page Level) --- */
        .button-row { display: flex; gap: 12px; margin-top: 15px; }
        .button-row button { flex: 1; padding: 10px; border-radius: 8px; border: none; cursor: pointer; font-weight: 600; transition: 0.2s; font-size: 0.9rem; }
        
        .btn-cancel-gray { background: #f1f3f5; color: #636e72; border: 1px solid #dee2e6 !important; }
        .btn-cancel-gray:hover { background: #e9ecef; color: #2d3436; }
        
        .btn-reschedule { background: #A56CD1; color: white; box-shadow: 0 4px 10px rgba(165, 108, 209, 0.3); }
        .btn-reschedule:hover { background: #8e56b8; transform: translateY(-2px); }

        /* --- 3. FIXED MODAL STYLES (Alignment Fix) --- */
        .status-modal-overlay {
            background: rgba(0, 0, 0, 0.6); backdrop-filter: blur(3px);
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            display: flex; justify-content: center; align-items: center; z-index: 1000;
        }
        
        /* The Single Seamless Card */
        .status-modal {
            background: white; 
            border-radius: 16px; 
            width: 90%;
            box-shadow: 0 20px 50px rgba(0,0,0,0.2); 
            overflow: hidden;
            display: flex;           /* Flexbox layout */
            flex-direction: column;  /* Stack children vertically */
            max-height: 90vh;        /* Prevent it from being taller than screen */
            animation: slideUp 0.3s ease-out;
            border: none;
        }
        @keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }

        /* Header flush with top */
        .modal-header {
            padding: 20px 25px; 
            display: flex; justify-content: space-between; align-items: center;
            border-bottom: 1px solid #eee; 
            background: #fff;
            flex-shrink: 0; /* Prevents header from collapsing */
            width: 100%;
            box-sizing: border-box;
            margin: 0; /* Ensures no margin separates it */
        }
        .modal-header h3 { margin: 0; font-size: 1.2rem; color: #333; }
        .modal-close { background: none; border: none; font-size: 1.5rem; color: #999; cursor: pointer; padding: 0; line-height: 1; }
        .modal-close:hover { color: #333; }

        /* Body flush with header */
        .modal-body { 
            padding: 25px; 
            overflow-y: auto; /* Allows scrolling inside body if content is long */
            width: 100%;
            box-sizing: border-box;
        }

        /* --- 4. CANCEL MODAL SPECIFIC --- */
        .cancel-content { text-align: center; padding: 10px 0; }
        .warning-icon { font-size: 3.5rem; color: #ff6b6b; margin-bottom: 20px; display: inline-block; animation: popIn 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275); }
        @keyframes popIn { from { transform: scale(0); opacity: 0; } to { transform: scale(1); opacity: 1; } }
        
        .cancel-actions { display: flex; gap: 15px; justify-content: center; margin-top: 25px; }
        .btn-keep { background: #f8f9fa; color: #495057; border: 1px solid #dee2e6; padding: 12px 24px; border-radius: 50px; cursor: pointer; font-weight: 600; font-size: 0.95rem; }
        .btn-confirm-cancel { background: #ff6b6b; color: white; border: none; padding: 12px 24px; border-radius: 50px; cursor: pointer; font-weight: 600; font-size: 0.95rem; box-shadow: 0 4px 12px rgba(255, 107, 107, 0.3); }
        .btn-confirm-cancel:hover { background: #fa5252; transform: translateY(-2px); }

        /* --- 5. RESCHEDULE MODAL SPECIFIC --- */
        .reschedule-label { display: block; margin-bottom: 10px; font-weight: 600; color: #444; font-size: 0.95rem; text-align: center; }
        
        /* Date Input Styling */
        .date-input-wrapper { position: relative; margin-bottom: 25px; }
        .date-input {
            width: 100%; padding: 15px; border: 2px solid #eee; border-radius: 10px;
            font-size: 1rem; color: #333; outline: none; transition: 0.3s;
            font-family: inherit;
        }
        .date-input:focus { border-color: #A56CD1; box-shadow: 0 0 0 4px rgba(165, 108, 209, 0.1); }

        /* Grid for Times */
        .reschedule-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(130px, 1fr)); gap: 15px; max-height: 300px; overflow-y: auto; padding: 5px; }
        
        /* Selectable Time Card */
        .time-slot-card {
            border: 2px solid #f0f0f0; border-radius: 12px; padding: 15px;
            text-align: center; cursor: pointer; transition: all 0.2s; background: #fff;
        }
        .time-slot-card:hover { border-color: #A56CD1; transform: translateY(-2px); }
        
        .time-slot-card.selected {
            border-color: #A56CD1; background-color: #f3ebff;
            box-shadow: 0 4px 12px rgba(165, 108, 209, 0.25);
        }
        
        .time-slot-card i { color: #A56CD1; margin-bottom: 8px; font-size: 1.1rem; display: block; }
        .slot-time { font-weight: 700; color: #333; display: block; font-size: 0.9rem; }
        .slot-status { font-size: 0.75rem; color: #2E7D32; font-weight: 600; margin-top: 4px; display: block; }
        
        .reschedule-footer {
            margin-top: 25px; padding-top: 20px; border-top: 1px solid #eee; display: flex; justify-content: flex-end; gap: 12px;
        }
        .btn-confirm-res { background: #A56CD1; color: white; border: none; padding: 12px 30px; border-radius: 50px; font-weight: 600; cursor: pointer; box-shadow: 0 4px 15px rgba(165, 108, 209, 0.3); }
        .btn-confirm-res:hover { background: #8e56b8; transform: translateY(-2px); }

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
            <i class="fas fa-exclamation-circle"></i> <span><%= errorMessage %></span>
        </div>
    <% } %>
    <% if (successMessage != null) { %>
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i> <span><%= successMessage %></span>
        </div>
    <% } %>

    <section class="content-section">
        <div class="section-header">
            <h4><i class="fas fa-clock"></i> Upcoming Appointments</h4>
        </div>

        <% if (appointments == null || appointments.isEmpty()) { %>
            <div style="padding:40px; background:#f9f9f9; border-radius:12px; text-align:center; color:#A56CD1; border: 1px dashed #A56CD1;">
                <i class="fas fa-calendar-alt" style="font-size:2.5rem; opacity: 0.5;"></i>
                <p style="margin-top:15px; font-weight: 500;">No upcoming appointments found.</p>
                <a href="bookAppointmentStudent.jsp" style="display:inline-block; margin-top:10px; color:#A56CD1; font-weight:600;">Book a Session Now &rarr;</a>
            </div>
        <% } else { %>
            <div class="sessions-grid">
            <% for (AppointmentView a : appointments) {
                Date start = a.getStartTime();
                Date end = a.getEndTime();
                String statusClass = a.getStatus() != null ? a.getStatus().toLowerCase() : "";
            %>
                <div class="session-card <%= statusClass %>">
                    <div class="card-info-line"><span class="card-label">DATE</span> <span><%= dateFmt.format(start) %></span></div>
                    <div class="card-info-line"><span class="card-label">TIME</span> <span><%= timeFmt.format(start) %> - <%= timeFmt.format(end) %></span></div>
                    <div class="card-info-line"><span class="card-label">STATUS</span> <span class="status-text <%= statusClass %>"><%= a.getStatus() %></span></div>
                    <div class="card-info-line"><span class="card-label">COUNSELOR</span> <span><%= a.getCounselorName() != null ? a.getCounselorName() : "-" %></span></div>
                    <div class="card-info-line" style="margin-bottom:0;"><span class="card-label">NOTES</span> <span style="font-style:italic; color:#777;"><%= a.getDescription() != null ? a.getDescription() : "None" %></span></div>
                    
                    <div class="button-row">
                        <button type="button" class="btn-cancel-gray" onclick="openCancel(<%= a.getAppointmentID() %>, <%= a.getSessionID() %>)">
                            <i class="fas fa-times"></i> Cancel
                        </button>
                        <button type="button" class="btn-reschedule" onclick="openReschedule(<%= a.getAppointmentID() %>, <%= a.getSessionID() %>)">
                            <i class="fas fa-calendar-check"></i> Reschedule
                        </button>
                    </div>
                </div>
            <% } %>
            </div>
        <% } %>
    </section>
</div>

<div id="cancelModal" class="status-modal-overlay" style="display:none;">
    <div class="status-modal" style="max-width:400px;">
        <div class="modal-body">
            <div class="cancel-content">
                <i class="fas fa-exclamation-triangle warning-icon"></i>
                <h3 style="margin-bottom:10px; color:#333;">Cancel Appointment?</h3>
                <p style="color:#666; line-height:1.5;">Are you sure you want to cancel this session? This action cannot be undone.</p>
            </div>
            <div class="cancel-actions">
                <button class="btn-keep" type="button" onclick="closeCancel()">No, Keep it</button>
                <button class="btn-confirm-cancel" type="button" onclick="submitCancel()">Yes, Cancel</button>
            </div>
        </div>
    </div>
</div>

<div id="rescheduleModal" class="status-modal-overlay" style="display:none;">
    <div class="status-modal" style="max-width:600px;">
        <div class="modal-header">
            <h3><i class="fas fa-sync-alt" style="color:#A56CD1; margin-right:10px;"></i> Reschedule Appointment</h3>
            <button class="modal-close" onclick="closeReschedule()">&times;</button>
        </div>
        <div class="modal-body">
            <label class="reschedule-label">1. Select New Date</label>
            <div class="date-input-wrapper">
                <input type="date" id="rescheduleDate" class="date-input" 
                       min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date(System.currentTimeMillis() + 86400000)) %>" 
                       onchange="loadRescheduleSessions(this.value)">
            </div>

            <label class="reschedule-label">2. Select New Time Slot</label>
            <div id="rescheduleSessions" class="reschedule-grid-container">
                <div style="text-align:center; padding:20px; color:#999; border:2px dashed #eee; border-radius:10px;">
                    Please select a date first.
                </div>
            </div>

            <div class="reschedule-footer">
                <button class="btn-keep" type="button" onclick="closeReschedule()">Cancel</button>
                <button class="btn-confirm-res" type="button" onclick="submitReschedule()">Confirm Change</button>
            </div>
        </div>
    </div>
</div>

<form id="cancelForm" method="POST" action="StudentAppointmentServlet" style="display:none;">
    <input type="hidden" name="action" value="cancelAppointment">
    <input type="hidden" name="appointmentID" id="cancelAppointmentID">
    <input type="hidden" name="sessionID" id="cancelSessionID">
</form>

<form id="rescheduleForm" method="POST" action="StudentAppointmentServlet" style="display:none;">
    <input type="hidden" name="action" value="rescheduleAppointment">
    <input type="hidden" name="appointmentID" id="rescheduleAppointmentID">
    <input type="hidden" name="oldSessionID" id="rescheduleOldSessionID">
    <input type="hidden" name="newSessionID" id="rescheduleNewSessionID">
</form>

<script>
    let pendingCancel = { appointmentID: null, sessionID: null };
    let pendingReschedule = { appointmentID: null, oldSessionID: null, newSessionID: null };

    // --- Cancel Logic ---
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

    // --- Reschedule Logic ---
    function openReschedule(appId, oldSessionId) {
        pendingReschedule.appointmentID = appId;
        pendingReschedule.oldSessionID = oldSessionId;
        pendingReschedule.newSessionID = null;
        document.getElementById('rescheduleSessions').innerHTML = '<div style="text-align:center; padding:20px; color:#999; border:2px dashed #eee; border-radius:10px;">Please select a date first.</div>';
        document.getElementById('rescheduleDate').value = '';
        document.getElementById('rescheduleModal').style.display = 'flex';
    }
    function closeReschedule() { document.getElementById('rescheduleModal').style.display = 'none'; }

    function selectSession(sessionID, element) {
        pendingReschedule.newSessionID = sessionID;
        document.querySelectorAll('.time-slot-card').forEach(c => c.classList.remove('selected'));
        element.classList.add('selected');
    }

    function loadRescheduleSessions(dateVal) {
        const container = document.getElementById('rescheduleSessions');
        container.innerHTML = '<div style="text-align:center; padding:20px; color:#A56CD1;"><i class="fas fa-circle-notch fa-spin"></i> Loading slots...</div>';
        
        if (!dateVal) return;
        
        fetch('StudentAppointmentServlet?action=availableSessions&date=' + dateVal)
            .then(r => r.json())
            .then(data => {
                if (!data || data.length === 0) {
                    container.innerHTML = '<div style="text-align:center; padding:20px; color:#666;">No available sessions for this date.</div>';
                    return;
                }
                
                // Build the Grid HTML
                let html = '<div class="reschedule-grid">';
                data.forEach(s => {
                    const startTime = new Date(s.start).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'});
                    const endTime = new Date(s.end).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'});
                    
                    html += `
                        <div class="time-slot-card" onclick="selectSession(\${s.sessionID}, this)">
                            <i class="far fa-clock"></i>
                            <span class="slot-time">\${startTime} - \${endTime}</span>
                            <span class="slot-status">Available</span>
                        </div>
                    `;
                });
                html += '</div>';
                container.innerHTML = html;
            })
            .catch(() => {
                container.innerHTML = '<div style="text-align:center; padding:20px; color:#ff6b6b;">Failed to load sessions. Try again.</div>';
            });
    }

    function submitReschedule() {
        if (!pendingReschedule.newSessionID) {
            alert('Please select a new time slot.');
            return;
        }
        document.getElementById('rescheduleAppointmentID').value = pendingReschedule.appointmentID;
        document.getElementById('rescheduleOldSessionID').value = pendingReschedule.oldSessionID;
        document.getElementById('rescheduleNewSessionID').value = pendingReschedule.newSessionID;
        document.getElementById('rescheduleForm').submit();
    }
    
    // Close modals on outside click
    window.onclick = function(event) {
        if (event.target.classList.contains('status-modal-overlay')) {
            closeCancel();
            closeReschedule();
        }
    }
</script>
</body>
</html>