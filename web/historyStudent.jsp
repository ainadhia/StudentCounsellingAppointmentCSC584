<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="com.counselling.model.AppointmentView"%>
<%@page import="com.counselling.model.AppointmentStats"%>
<%@page import="com.counselling.model.Student"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Appointment History | Student</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/global-style.css">
</head>
<body>
<%
    Student student = (Student) session.getAttribute("user");
    if (student == null || session.getAttribute("role") == null || !"S".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<AppointmentView> history = (List<AppointmentView>) request.getAttribute("history");
    AppointmentStats stats = (AppointmentStats) request.getAttribute("stats");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String query = (String) request.getAttribute("query");
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
            <li><a href="StudentAppointmentServlet?action=manage"><span class="menu-text" style="font-size: 0.85rem;">| Manage Appointments</span></a></li>
            <li class="active"><a href="StudentAppointmentServlet?action=history"><span class="menu-text" style="font-size: 0.85rem;">| History</span></a></li>
            <li><a href="<%=request.getContextPath()%>/StudentProfileServlet"><span class="menu-text" style="font-size: 0.85rem;">| Profile</span></a></li>
            <li><a href="<%=request.getContextPath()%>/LogoutServlet"><span class="menu-text" style="font-size: 0.85rem;">| Logout</span></a></li>
        </ul>
    </nav>

<div class="main-content">
    <div class="main-header">
        <div>
            <h1>Appointment History</h1>
            <p class="welcome-subtitle">View all appointments you have made</p>
        </div>
        <div class="header-date"><%= new java.text.SimpleDateFormat("EEEE, MMMM d, yyyy").format(new java.util.Date()) %></div>
    </div>

    <div class="cards" style="grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));">
        <div class="card">
            <div class="card-content">
                <h3>Total Appointments</h3>
                <div class="card-number"><%= stats != null ? stats.getTotal() : 0 %></div>
            </div>
        </div>
        <div class="card">
            <div class="card-content">
                <h3>Completed</h3>
                <div class="card-number"><%= stats != null ? stats.getCompleted() : 0 %></div>
            </div>
        </div>
        <div class="card">
            <div class="card-content">
                <h3>Upcoming</h3>
                <div class="card-number"><%= stats != null ? stats.getUpcoming() : 0 %></div>
            </div>
        </div>
        <div class="card">
            <div class="card-content">
                <h3>Cancelled</h3>
                <div class="card-number"><%= stats != null ? stats.getCancelled() : 0 %></div>
            </div>
        </div>
    </div>

    <% if (errorMessage != null) { %>
        <div class="alert alert-error">
            <i class="fas fa-exclamation-circle"></i>
            <span><%= errorMessage %></span>
        </div>
    <% } %>

    <section class="content-section">
        <div class="section-header" style="flex-wrap: wrap; gap: 12px;">
            <h4><i class="fas fa-list"></i> All Appointments</h4>
            <form action="StudentAppointmentController" method="GET" class="section-toolbar">
                <input type="hidden" name="action" value="history">
                <input type="text" name="q" class="input-control" placeholder="Search by counselor, status, note" value="<%= query != null ? query : "" %>">
                <button class="btn-submit" type="submit"><i class="fas fa-search"></i> Search</button>
            </form>
        </div>

        <% if (history == null || history.isEmpty()) { %>
            <div style="padding:20px; background:#f5f7fa; border-radius:8px; text-align:center; color:#6a3ba0;">
                <i class="fas fa-info-circle" style="font-size:2rem;"></i>
                <p style="margin-top:10px;">No appointments found.</p>
            </div>
        <% } else { %>
            <div class="table-card">
                <table>
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Time</th>
                            <th>Counselor</th>
                            <th>Status</th>
                            <th>Notes</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (AppointmentView a : history) {
                        Date start = a.getStartTime();
                        Date end = a.getEndTime();
                        String statusClass = a.getStatus() != null ? a.getStatus().toLowerCase() : "";
                            String counselorEsc = a.getCounselorName() != null ? a.getCounselorName().replace("'", "\\'") : "-";
                            String statusEsc = a.getStatus() != null ? a.getStatus().replace("'", "\\'") : "";
                            String notesEsc = a.getDescription() != null ? a.getDescription().replace("'", "\\'") : "No notes";
                    %>
                        <tr>
                            <td>
                                <i class="fas fa-calendar-day" style="color:#6a3ba0;"></i>
                                <span style="margin-left:6px;"><%= dateFmt.format(start) %></span>
                            </td>
                            <td>
                                <i class="fas fa-clock" style="color:#6a3ba0;"></i>
                                <span style="margin-left:6px;"><%= timeFmt.format(start) %> - <%= timeFmt.format(end) %></span>
                            </td>
                            <td style="color:#5D2E8C;">
                                <%= a.getCounselorName() != null ? a.getCounselorName() : "-" %>
                            </td>
                            <td>
                                <span class="pill <%= statusClass %>">
                                    <i class="fas fa-info-circle"></i>
                                    <%= a.getStatus() %>
                                </span>
                            </td>
                            <td style="color:#6a3ba0; max-width:320px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
                                <%= a.getDescription() != null ? a.getDescription() : "No notes" %>
                            </td>
                            <td>
                                <button type="button" class="btn-secondary btn-icon" 
                                     onclick="openView('<%= dateFmt.format(start) %>', '<%= timeFmt.format(start) %> - <%= timeFmt.format(end) %>', '<%= counselorEsc %>', '<%= statusEsc %>', '<%= notesEsc %>')">
                                    <i class="fas fa-eye"></i>
                                </button>
                                <button type="button" class="btn-danger btn-icon" onclick="openDelete(<%= a.getSessionID() %>)">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        <% } %>
    </section>
</div>

<!-- View Modal -->
<div id="viewModal" class="status-modal-overlay" style="display:none;">
    <div class="status-modal" style="max-width:520px;">
        <div class="modal-header">
            <h3><i class="fas fa-eye"></i> Appointment Details</h3>
            <button class="modal-close" onclick="closeView()">&times;</button>
        </div>
        <div class="modal-body">
            <p><strong>Date:</strong> <span id="viewDate"></span></p>
            <p><strong>Time:</strong> <span id="viewTime"></span></p>
            <p><strong>Counselor:</strong> <span id="viewCounselor"></span></p>
            <p><strong>Status:</strong> <span id="viewStatus"></span></p>
            <p><strong>Notes:</strong> <span id="viewNotes"></span></p>
            <div class="form-buttons" style="justify-content:flex-end; margin-top:12px;">
                <button class="btn-secondary" type="button" onclick="closeView()">Close</button>
            </div>
        </div>
    </div>
</div>

<!-- Delete Modal -->
<div id="deleteModal" class="status-modal-overlay" style="display:none;">
    <div class="status-modal" style="max-width:480px;">
        <div class="modal-header">
            <h3><i class="fas fa-trash"></i> Delete Appointment</h3>
            <button class="modal-close" onclick="closeDelete()">&times;</button>
        </div>
        <div class="modal-body">
            <p class="modal-message">Are you sure you want to permanently delete this appointment?</p>
            <div class="form-buttons" style="justify-content:flex-end; gap:10px;">
                <button class="btn-secondary" type="button" onclick="closeDelete()">Cancel</button>
                <button class="btn-danger" type="button" onclick="submitDelete()">Delete</button>
            </div>
        </div>
    </div>
</div>

<form id="deleteForm" method="POST" action="StudentAppointmentController" style="display:none;">
    <input type="hidden" name="action" value="deleteAppointment">
    <input type="hidden" name="sessionID" id="deleteSessionID">
</form>

<script>
    function openView(dateText, timeText, counselor, status, notes) {
        document.getElementById('viewDate').textContent = dateText;
        document.getElementById('viewTime').textContent = timeText;
        document.getElementById('viewCounselor').textContent = counselor;
        document.getElementById('viewStatus').textContent = status;
        document.getElementById('viewNotes').textContent = notes;
        document.getElementById('viewModal').style.display = 'flex';
    }
    function closeView() { document.getElementById('viewModal').style.display = 'none'; }

    let pendingDelete = null;
    function openDelete(sessionId) {
        pendingDelete = sessionId;
        document.getElementById('deleteModal').style.display = 'flex';
    }
    function closeDelete() { document.getElementById('deleteModal').style.display = 'none'; }
    function submitDelete() {
        if (!pendingDelete) return;
        document.getElementById('deleteSessionID').value = pendingDelete;
        document.getElementById('deleteForm').submit();
    }
</script>
</body>
</html>
