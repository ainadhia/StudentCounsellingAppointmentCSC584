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

            <style>
                .search-wrapper {
                    display: flex;
                    align-items: center;
                    background: #ffffff;
                    border: 2px solid #e0e0e0;
                    border-radius: 50px;
                    padding: 4px;
                    width: 280px;
                    transition: all 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
                    box-shadow: 0 4px 6px rgba(0,0,0,0.02);
                }
                .search-wrapper:focus-within {
                    width: 380px;
                    border-color: #A56CD1;
                    box-shadow: 0 4px 15px rgba(165, 108, 209, 0.25);
                }
                .search-input-field {
                    border: none; background: transparent; outline: none; padding: 8px 16px;
                    font-size: 0.95rem; color: #555; width: 100%; border-radius: 50px 0 0 50px;
                }
                .search-btn-icon {
                    background: #A56CD1; color: white; border: none; width: 42px; height: 42px;
                    border-radius: 50%; cursor: pointer; display: flex; align-items: center; justify-content: center;
                    transition: all 0.3s ease; flex-shrink: 0;
                }
                .search-btn-icon:hover {
                    background: #8e56b8; transform: rotate(10deg) scale(1.1);
                }

                .table-card {
                    background: white; border-radius: 12px; box-shadow: 0 5px 15px rgba(0,0,0,0.05);
                    overflow: hidden; border: 1px solid #eee;
                }
                table { width: 100%; border-collapse: collapse; font-size: 0.95rem; }
                thead { background-color: #f8f9fa; border-bottom: 2px solid #eaeaea; }
                th { padding: 18px 24px; text-align: left; font-weight: 600; color: #444; text-transform: uppercase; font-size: 0.8rem; letter-spacing: 0.5px; }
                td { padding: 20px 24px; vertical-align: middle; border-bottom: 1px solid #f0f0f0; color: #555; }
                tr:last-child td { border-bottom: none; }
                tr:hover { background-color: #fafafa; }
                .data-with-icon { display: flex; align-items: center; gap: 10px; }
                .data-with-icon i { color: #A56CD1; font-size: 1rem; width: 20px; text-align: center; }

                .action-buttons-container { display: flex; gap: 12px; }
                .btn-action-neat {
                    background: transparent; border: none; width: 36px; height: 36px; border-radius: 8px; cursor: pointer;
                    display: flex; align-items: center; justify-content: center; transition: all 0.2s ease; font-size: 1rem;
                }
                .btn-view { color: #A56CD1; background: rgba(165, 108, 209, 0.1); }
                .btn-view:hover { background: #A56CD1; color: white; transform: translateY(-2px); }
                .btn-delete { color: #e74c3c; background: rgba(231, 76, 60, 0.1); }
                .btn-delete:hover { background: #e74c3c; color: white; transform: translateY(-2px); }
                .status-pill { display: inline-block; padding: 6px 14px; border-radius: 20px; font-size: 0.85rem; font-weight: 600; }
                .status-pill.pending { background-color: #FFF8E1; color: #F57F17; }
                .status-pill.approved { background-color: #E8F5E9; color: #2E7D32; }
                .status-pill.completed { background-color: #E3F2FD; color: #1565C0; }
                .status-pill.cancelled { background-color: #FFEBEE; color: #C62828; }

                .status-modal-overlay {
                    background: rgba(0, 0, 0, 0.5);
                    backdrop-filter: blur(2px);
                    position: fixed; top: 0; left: 0; width: 100%; height: 100%;
                    display: flex; justify-content: center; align-items: center; z-index: 1000;
                }

                .status-modal {
                    background: white;
                    border-radius: 16px;
                    width: 100%;
                    max-width: 500px;  
                    margin: 0 20px;   
                    box-shadow: 0 10px 30px rgba(0,0,0,0.2);
                    display: flex;
                    flex-direction: column; 
                    overflow: hidden; 
                    animation: slideDown 0.3s ease-out;
                    border: none; 
                }

                @keyframes slideDown {
                    from { opacity: 0; transform: translateY(-20px); }
                    to { opacity: 1; transform: translateY(0); }
                }

                .modal-header {
                    width: 100%;
                    box-sizing: border-box; 
                    padding: 20px 25px;
                    background: #fafafa;
                    border-bottom: 1px solid #eee;
                    display: flex; 
                    justify-content: space-between; 
                    align-items: center;
                    margin: 0; 
                }

                .modal-header h3 { margin: 0; font-size: 1.15rem; color: #333; display: flex; align-items: center; gap: 10px; }
                .modal-header h3 i { color: #A56CD1; }

                .modal-close { background: none; border: none; font-size: 1.5rem; color: #999; cursor: pointer; padding: 0; line-height: 1; }
                .modal-close:hover { color: #333; }

                .modal-body { 
                    padding: 25px; 
                    width: 100%; 
                    box-sizing: border-box; 
                }

                .detail-row {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    padding: 12px 0;
                    border-bottom: 1px dashed #eee;
                }
                .detail-row:last-child { border-bottom: none; }
                .detail-label { color: #777; font-weight: 500; font-size: 0.95rem; }
                .detail-value { color: #333; font-weight: 600; font-size: 1rem; text-align: right; }
                .detail-value.highlight { color: #A56CD1; }

                .notes-section { margin-top: 20px; }
                .notes-label { display: block; color: #777; font-weight: 500; margin-bottom: 8px; font-size: 0.9rem; }
                .notes-content {
                    background: #f8f9fa;
                    border-left: 4px solid #A56CD1;
                    padding: 15px;
                    border-radius: 4px; 
                    color: #444;
                    font-size: 0.95rem;
                    line-height: 1.5;
                    min-height: 60px;
                }

                .modal-footer {
                    padding: 15px 25px;
                    background: #fff;
                    display: flex;
                    justify-content: flex-end;
                    border-top: 1px solid #f5f5f5;
                }

                .btn-modal-close {
                    background: #eee; color: #333; border: none; padding: 10px 24px; border-radius: 50px; 
                    cursor: pointer; font-weight: 500; transition: background 0.2s;
                }
                .btn-modal-close:hover { background: #e0e0e0; }
         </style>
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
                <h1>List Booked Appointment</h1>
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
            <div class="section-header" style="flex-wrap: wrap; gap: 20px; align-items: center; justify-content: space-between;">
                <h4 style="margin: 0; color: #333; font-size: 1.25rem;">
                    <i class="fas fa-list" style="color: #A56CD1; margin-right: 8px;"></i> 
                    All Appointments
                </h4>

                <form action="StudentAppointmentServlet" method="GET" style="margin:0;">
                    <input type="hidden" name="action" value="history">
                    <div class="search-wrapper">
                        <input type="text" name="q" class="search-input-field" placeholder="Search by counselor, status..." value="<%= query != null ? query : "" %>" autocomplete="off">
                        <button class="search-btn-icon" type="submit"><i class="fas fa-search"></i></button>
                    </div>
                </form>
            </div>

            <% if (history == null || history.isEmpty()) { %>
                <div style="padding:40px; background:#f9f9f9; border-radius:8px; text-align:center; color:#A56CD1; border: 1px dashed #A56CD1; margin-top: 20px;">
                    <i class="fas fa-search" style="font-size:2.5rem; opacity: 0.5;"></i>
                    <p style="margin-top:15px; font-weight: 500;">No appointments found.</p>
                </div>
            <% } else { %>
                <div class="table-card" style="margin-top: 20px;">
                    <table>
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Time</th>
                                <th>Counselor</th>
                                <th>Status</th>
                                <th style="width: 25%;">Notes</th>
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
                                    <div class="data-with-icon">
                                        <i class="fas fa-calendar-day"></i>
                                        <span><%= dateFmt.format(start) %></span>
                                    </div>
                                </td>
                                    <td>
                                        <div class="data-with-icon">
                                            <i class="fas fa-clock"></i>
                                            <span><%= timeFmt.format(start) %> - <%= timeFmt.format(end) %></span>
                                        </div>
                                    </td>
                                    <td style="color:#5D2E8C; font-weight:600;"><%= a.getCounselorName() != null ? a.getCounselorName() : "-" %></td>
                                    <td><span class="status-pill <%= statusClass %>"><%= a.getStatus() %></span></td>
                                    <td style="color:#666; max-width:250px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;"><%= a.getDescription() != null ? a.getDescription() : "No notes" %></td>
                                    <td>
                                        <div class="action-buttons-container">
                                            <button type="button" class="btn-action-neat btn-view" 
                                                 onclick="openView('<%= dateFmt.format(start) %>', '<%= timeFmt.format(start) %> - <%= timeFmt.format(end) %>', '<%= counselorEsc %>', '<%= statusEsc %>', '<%= notesEsc %>')" title="View Details">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                            <button type="button" class="btn-action-neat btn-delete" onclick="openDelete(<%= a.getSessionID() %>)" title="Delete Record">
                                                <i class="fas fa-trash-alt"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </section>
        </div>

        <div id="viewModal" class="status-modal-overlay" style="display:none;">
            <div class="status-modal">
                <div class="modal-header">
                    <h3><i class="fas fa-info-circle"></i> Appointment Details</h3>
                    <button class="modal-close" onclick="closeView()">&times;</button>
                </div>
                <div class="modal-body">
                    <div class="detail-row">
                        <span class="detail-label">Date</span>
                        <span class="detail-value" id="viewDate"></span>
                    </div>

                    <div class="detail-row">
                        <span class="detail-label">Time</span>
                        <span class="detail-value" id="viewTime"></span>
                    </div>

                    <div class="detail-row">
                        <span class="detail-label">Counselor</span>
                        <span class="detail-value highlight" id="viewCounselor"></span>
                    </div>

                    <div class="detail-row">
                        <span class="detail-label">Status</span>
                        <span id="viewStatusPill"></span> </div>

                    <div class="notes-section">
                        <span class="notes-label">Student Notes</span>
                        <div class="notes-content" id="viewNotes"></div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button class="btn-modal-close" onclick="closeView()">Close</button>
                </div>
            </div>
        </div>

        <div id="deleteModal" class="status-modal-overlay" style="display:none;">
            <div class="status-modal" style="max-width:400px; text-align:center;">
                <div class="modal-body" style="padding: 40px 30px;">
                    <i class="fas fa-trash-alt" style="font-size: 3rem; color: #ff6b6b; margin-bottom: 20px; display:block;"></i>
                    <h3 style="margin-bottom:10px; color:#333;">Delete Appointment?</h3>
                    <p style="color:#666; margin-bottom:25px;">This action is permanent and cannot be undone.</p>
                    <div style="display:flex; justify-content:center; gap:15px;">
                        <button class="btn-modal-close" onclick="closeDelete()">Cancel</button>
                        <button class="btn-modal-close" onclick="submitDelete()" style="background:#ff6b6b; color:white;">Delete</button>
                    </div>
                </div>
            </div>
        </div>

        <form id="deleteForm" method="POST" action="StudentAppointmentServlet" style="display:none;">
            <input type="hidden" name="action" value="deleteAppointment">
            <input type="hidden" name="sessionID" id="deleteSessionID">
        </form>

        <script>
            function openView(dateText, timeText, counselor, status, notes) {
                document.getElementById('viewDate').textContent = dateText;
                document.getElementById('viewTime').textContent = timeText;
                document.getElementById('viewCounselor').textContent = counselor;

                const statusLower = status.toLowerCase();
                const pillHTML = '<span class="status-pill ' + statusLower + '">' + status + '</span>';
                document.getElementById('viewStatusPill').innerHTML = pillHTML;

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

            window.onclick = function(event) {
                if (event.target.classList.contains('status-modal-overlay')) {
                    closeView();
                    closeDelete();
                }
            }
        </script>
    </body>
</html>