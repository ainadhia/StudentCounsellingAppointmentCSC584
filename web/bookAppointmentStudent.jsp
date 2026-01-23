<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.counselling.model.Session"%>
<%@page import="com.counselling.model.Student"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Book Appointment | Student Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/global-style.css">
    <style>
        /* --- 1. Form & Input Styles --- */
        .form-label {
            display: block; font-weight: 600; color: #444; margin-bottom: 10px; font-size: 0.95rem;
        }

        /* Modern Date Input */
        .date-input-container {
            position: relative; margin-bottom: 30px;
        }
        .date-input-styled {
            width: 100%; padding: 15px; border: 2px solid #e0e0e0; border-radius: 12px;
            font-size: 1rem; color: #333; outline: none; transition: all 0.3s ease;
            font-family: inherit; background: #fff; cursor: pointer;
        }
        .date-input-styled:focus {
            border-color: #A56CD1; box-shadow: 0 0 0 4px rgba(165, 108, 209, 0.1);
        }

        /* --- 2. Session Cards (The "Ticket" Look) --- */
        .sessions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 20px;
            margin-top: 15px;
        }

        .session-card {
            display: block; /* Important for label behavior */
            background: #fff;
            border: 2px solid #f0f0f0;
            border-radius: 16px;
            padding: 20px;
            cursor: pointer;
            transition: all 0.25s cubic-bezier(0.25, 0.8, 0.25, 1);
            position: relative;
            overflow: hidden;
        }

        /* Hover Effect */
        .session-card:hover {
            transform: translateY(-4px);
            border-color: #dcdcdc;
            box-shadow: 0 8px 20px rgba(0,0,0,0.06);
        }

        /* Hidden Radio Button */
        .session-card input[type="radio"] {
            position: absolute; opacity: 0; width: 0; height: 0;
        }

        /* --- SELECTED STATE (Purple Theme) --- */
        .session-card.selected {
            border-color: #A56CD1;
            background-color: #fbf7ff; /* Very light purple bg */
            box-shadow: 0 4px 15px rgba(165, 108, 209, 0.25);
            transform: translateY(-2px);
        }
        
        /* The Checkmark Badge */
        .selected-badge {
            position: absolute; top: 15px; right: 15px;
            background: #A56CD1; color: white; width: 24px; height: 24px;
            border-radius: 50%; display: flex; align-items: center; justify-content: center;
            font-size: 0.8rem; opacity: 0; transform: scale(0); transition: 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }
        .session-card.selected .selected-badge { opacity: 1; transform: scale(1); }

        /* Typography inside Card */
        .session-time {
            font-size: 1.1rem; font-weight: 700; color: #333; margin-bottom: 8px;
            display: flex; align-items: center; gap: 8px;
        }
        .session-time i { color: #ccc; transition: color 0.3s; }
        
        .session-card.selected .session-time { color: #A56CD1; }
        .session-card.selected .session-time i { color: #A56CD1; }

        .session-status {
            font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;
            padding: 4px 10px; border-radius: 6px; display: inline-block;
        }
        .status-available { background: #e8f5e9; color: #2E7D32; }
        .status-unavailable { background: #ffebee; color: #c62828; }

        /* --- UNAVAILABLE STATE --- */
        .session-card.unavailable {
            opacity: 0.6; cursor: not-allowed; background: #fafafa; border-color: #eee;
        }
        .session-card.unavailable:hover { transform: none; box-shadow: none; border-color: #eee; }

        /* --- 3. Textarea Styling --- */
        .reason-box {
            width: 100%; padding: 15px; border: 2px solid #e0e0e0; border-radius: 12px;
            font-size: 1rem; color: #333; outline: none; transition: 0.3s; font-family: inherit;
            resize: vertical; min-height: 100px; margin-top: 5px;
        }
        .reason-box:focus {
            border-color: #A56CD1; box-shadow: 0 0 0 4px rgba(165, 108, 209, 0.1);
        }

        /* --- 4. Submit Button --- */
        .btn-book-submit {
            background: linear-gradient(135deg, #A56CD1, #8e56b8);
            color: white; border: none; padding: 14px 30px; border-radius: 50px;
            font-weight: 600; font-size: 1rem; cursor: pointer;
            box-shadow: 0 4px 15px rgba(165, 108, 209, 0.3);
            transition: all 0.3s ease; display: inline-flex; align-items: center; gap: 10px;
        }
        .btn-book-submit:hover {
            transform: translateY(-2px); box-shadow: 0 6px 20px rgba(165, 108, 209, 0.4);
        }

        /* --- 5. Success Modal --- */
        .status-modal-overlay {
            background: rgba(0, 0, 0, 0.6); backdrop-filter: blur(3px);
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            display: flex; justify-content: center; align-items: center; z-index: 1000;
        }
        .status-modal {
            background: white; border-radius: 16px; width: 90%; max-width: 400px;
            box-shadow: 0 20px 50px rgba(0,0,0,0.2); overflow: hidden; text-align: center;
            animation: popIn 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }
        @keyframes popIn { from { opacity: 0; transform: scale(0.9); } to { opacity: 1; transform: scale(1); } }
        
        .modal-header-success { background: #A56CD1; padding: 20px; color: white; }
        .modal-body { padding: 30px; }
        .success-icon-large { font-size: 3rem; color: #fff; margin-bottom: 10px; }
    </style>
</head>
<body>
<%
    Student student = (Student) session.getAttribute("user");
    if (student == null || !"S".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    String selectedDate = (String) request.getAttribute("selectedDate");
    List<Session> allSessions = (List<Session>) request.getAttribute("allSessions");
%>

    <nav class="navbar">
        <div class="navbar-logo"><span class="logo-text">UITM COUNSELLING</span></div>
        <ul class="navbar-menu">
            <li><a href="<%=request.getContextPath()%>/StudentDashboardServlet"><span class="menu-text" style="font-size: 0.85rem;">| Dashboard</span></a></li>
            <li class="active"><a href="bookAppointmentStudent.jsp"><span class="menu-text" style="font-size: 0.85rem;">| Book Appointment</span></a></li>
            <li><a href="StudentAppointmentServlet?action=manage"><span class="menu-text" style="font-size: 0.85rem;">| Manage Appointments</span></a></li>
            <li><a href="StudentAppointmentServlet?action=history"><span class="menu-text" style="font-size: 0.85rem;">| History</span></a></li>
            <li><a href="<%=request.getContextPath()%>/StudentProfileServlet"><span class="menu-text" style="font-size: 0.85rem;">| Profile</span></a></li>
            <li><a href="<%=request.getContextPath()%>/LogoutServlet"><span class="menu-text" style="font-size: 0.85rem;">| Logout</span></a></li>
        </ul>
    </nav>

    <div class="main-content">
        <div class="main-header">
            <div>
                <h1>Book Counseling Appointment</h1>
                <p class="welcome-subtitle">Select a date and time slot below</p>
            </div>
            <div class="header-date"><%= new java.text.SimpleDateFormat("EEEE, MMMM d, yyyy").format(new java.util.Date()) %></div>
        </div>

        <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> <span><%= errorMessage %></span>
            </div>
        <% } %>

        <section class="content-section" style="max-width: 900px; margin: 0 auto;">
            
            <form action="StudentAppointmentServlet" method="POST" id="bookingForm">
                <input type="hidden" name="action" value="bookAppointment">
                <input type="hidden" name="studentID" value="<%= student.getStudentID() %>">
                <input type="hidden" name="studentInternalID" value="<%= student.getId() %>">
                <input type="hidden" name="date" id="selectedDateInput" value="<%= selectedDate %>">

                <div style="margin-bottom: 30px;">
                    <label class="form-label"><i class="fas fa-calendar-day" style="color:#A56CD1; margin-right:5px;"></i> 1. Select Date</label>
                    <div class="date-input-container">
                        <input type="date" 
                               class="date-input-styled" 
                               id="sessionDateInput"
                               min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date(System.currentTimeMillis() + 86400000)) %>"
                               value="<%= selectedDate != null ? selectedDate : "" %>"
                               onchange="loadSessions(this.value)">
                    </div>
                </div>

                <% if (allSessions != null && !allSessions.isEmpty()) { %>
                    <div style="margin-bottom: 30px;">
                        <label class="form-label"><i class="fas fa-clock" style="color:#A56CD1; margin-right:5px;"></i> 2. Select Available Session</label>
                        <div class="sessions-grid">
                        <% for (Session s : allSessions) {
                               String statusClass = s.getSessionStatus() != null ? s.getSessionStatus().toLowerCase() : "";
                               boolean isAvailable = "available".equals(statusClass);
                               String cardClass = isAvailable ? "session-card" : "session-card unavailable";
                        %>
                            <label class="<%= cardClass %>">
                                <input type="radio" name="sessionID" value="<%= s.getSessionID() %>" <%= !isAvailable ? "disabled" : "" %> required>
                                
                                <div class="selected-badge"><i class="fas fa-check"></i></div>
                                
                                <div class="session-time">
                                    <i class="far fa-clock"></i>
                                    <span><%= s.getFormattedStartTime() %> - <%= s.getFormattedEndTime() %></span>
                                </div>
                                
                                <div class="session-status <%= isAvailable ? "status-available" : "status-unavailable" %>">
                                    <%= isAvailable ? "Available" : "Unavailable" %>
                                </div>
                            </label>
                        <% } %>
                        </div>
                    </div>

                    <div style="margin-bottom: 30px;">
                        <label class="form-label"><i class="fas fa-comment-alt" style="color:#A56CD1; margin-right:5px;"></i> 3. Reason for Appointment</label>
                        <textarea name="reason" class="reason-box" placeholder="Briefly describe what you would like to discuss..." required></textarea>
                    </div>

                    <div style="text-align: right;">
                        <button type="submit" class="btn-book-submit">
                            Confirm Booking <i class="fas fa-arrow-right"></i>
                        </button>
                    </div>

                <% } else if (selectedDate != null) { %>
                    <div style="padding: 40px; background: #f9f9f9; border-radius: 12px; text-align: center; border: 2px dashed #e0e0e0;">
                        <i class="fas fa-calendar-times" style="color: #ccc; font-size: 2.5rem; margin-bottom: 15px;"></i>
                        <p style="color: #666; font-weight:500;">No available sessions found for <span style="color:#A56CD1; font-weight:700;"><%= selectedDate %></span>.</p>
                        <p style="color: #999; font-size:0.9rem;">Please try selecting a different date.</p>
                    </div>
                <% } else { %>
                     <div style="padding: 30px; background: #fdfdfd; border-radius: 12px; text-align: center; color:#888; border: 1px solid #eee;">
                         <i class="fas fa-arrow-up" style="margin-bottom:10px;"></i>
                         <p>Please select a date above to view availability.</p>
                     </div>
                <% } %>
            </form>
        </section>
    </div>

    <% if (successMessage != null && !successMessage.isEmpty()) { %>
        <div class="status-modal-overlay">
            <div class="status-modal">
                <div class="modal-header-success">
                    <i class="fas fa-check-circle success-icon-large"></i>
                    <h3 style="margin:0; color:white;">Booked Successfully!</h3>
                </div>
                <div class="modal-body">
                    <p style="color:#555; line-height:1.6; margin-bottom:25px;"><%= successMessage %></p>
                    <button class="btn-book-submit" style="width:100%; justify-content:center;" onclick="window.location.href='<%=request.getContextPath()%>/StudentDashboardServlet'">
                        Back to Dashboard
                    </button>
                </div>
            </div>
        </div>
    <% } %>

    <script>
        function loadSessions(date) {
            if (date) {
                window.location.href = "StudentAppointmentServlet?action=loadSessions&date=" + date;
            }
        }

        // Initialize Card Selection Logic
        document.addEventListener('DOMContentLoaded', function() {
            const cards = document.querySelectorAll('.session-card');
            
            cards.forEach(card => {
                // Ignore unavailable cards
                if(card.classList.contains('unavailable')) return;

                card.addEventListener('click', function() {
                    // 1. Reset all cards
                    cards.forEach(c => c.classList.remove('selected'));
                    
                    // 2. Select this card
                    this.classList.add('selected');
                    
                    // 3. Check the radio inside
                    const radio = this.querySelector('input[type="radio"]');
                    if(radio) radio.checked = true;
                });
            });
        });
    </script>

</body>
</html>