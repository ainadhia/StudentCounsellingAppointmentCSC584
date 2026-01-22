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
        /* Session cards styling - tidy and neat design */
        .sessions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 16px;
            margin-top: 20px;
        }
        
        .session-card {
            border: 1.5px solid #e0e0e0;
            border-radius: 10px;
            padding: 18px;
            background: white;
            transition: all 0.2s ease;
            position: relative;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            min-height: 110px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
        }
        
        .session-card.available {
            border-color: #4CAF50;
            background: linear-gradient(to bottom right, #ffffff, #f8fff8);
        }
        
        .session-card.unavailable {
            border-color: #f44336;
            background: linear-gradient(to bottom right, #ffffff, #fff8f8);
            pointer-events: none; /* Prevent clicking on unavailable cards */
        }
        
        .session-card.selected {
            border-color: #5D2E8C !important;
            border-width: 2px !important;
            box-shadow: 0 4px 12px rgba(93, 46, 140, 0.15) !important;
            transform: translateY(-2px);
        }
        
        .session-card input[type="radio"] {
            position: absolute;
            opacity: 0;
            width: 0;
            height: 0;
        }
        
        .session-card.available:hover {
            border-color: #5D2E8C;
            box-shadow: 0 4px 8px rgba(93, 46, 140, 0.1);
            cursor: pointer;
        }
        
        .session-time {
            font-size: 1.15rem;
            font-weight: 600;
            color: #333;
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 12px;
        }
        
        .session-time i {
            color: #5D2E8C;
            font-size: 1rem;
            width: 20px;
        }
        
        .time-slot {
            font-family: 'Segoe UI', 'Roboto', sans-serif;
            letter-spacing: 0.3px;
            font-weight: 600;
        }
        
        .session-status {
            font-weight: 600;
            font-size: 0.85rem;
            padding: 6px 14px;
            border-radius: 16px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            width: fit-content;
            align-self: flex-end;
            margin-top: 8px;
        }
        
        .session-card.available .session-status {
            background-color: #E8F5E9;
            color: #2E7D32;
            border: 1px solid #C8E6C9;
        }
        
        .session-card.unavailable .session-status {
            background-color: #FFEBEE;
            color: #C62828;
            border: 1px solid #FFCDD2;
        }
        
        .session-status i {
            font-size: 0.8rem;
        }
        
        /* Disabled state */
        .session-card.unavailable {
            cursor: not-allowed;
            opacity: 0.7;
        }
        
        .session-card.unavailable .session-time {
            color: #666;
        }
        
        .session-card.unavailable .session-time i {
            color: #999;
        }
        
        /* Selected state indicator */
        .session-card.selected::before {
            position: absolute;
            top: -10px;
            left: 50%;
            transform: translateX(-50%);
            background: #5D2E8C;
            color: white;
            padding: 4px 16px;
            border-radius: 12px;
            font-size: 0.7rem;
            font-weight: 600;
            letter-spacing: 0.5px;
            z-index: 1;
            box-shadow: 0 2px 4px rgba(93, 46, 140, 0.3);
        }
        
        /* Grid layout for consistency */
        @media (min-width: 1200px) {
            .sessions-grid {
                grid-template-columns: repeat(3, 1fr);
            }
        }
        
        @media (min-width: 768px) and (max-width: 1199px) {
            .sessions-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        
        @media (max-width: 767px) {
            .sessions-grid {
                grid-template-columns: 1fr;
                max-width: 400px;
                margin-left: auto;
                margin-right: auto;
            }
        }
        
        /* Ensure equal height for all cards */
        .sessions-grid .session-card {
            height: 100%;
        }
        
        /* Section header styling */
        .section-header h4 {
            color: #5D2E8C;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .section-header h4 i {
            color: #5D2E8C;
        }
    </style>
</head>
<body>
<%
    // Get student from session
    Student student = (Student) session.getAttribute("user");
    if (student == null || !"S".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

    <nav class="navbar">
        <div class="navbar-logo">
            <span class="logo-text">UITM COUNSELLING</span>
        </div>
        <ul class="navbar-menu">
            <li><a  href="<%=request.getContextPath()%>/StudentDashboardServlet"><span class="menu-text" style="font-size: 0.85rem;">| Dashboard</span></a></li>
            <li class="active"><a href="bookAppointmentStudent.jsp"><span class="menu-text" style="font-size: 0.85rem;">| Book Appointment</span></a></li>
            <li><a href="StudentAppointmentServlet?action=manage"><span class="menu-text" style="font-size: 0.85rem;">| Manage Appointments</span></a></li>
            <li><a href="StudentAppointmentServlet?action=history"><span class="menu-text" style="font-size: 0.85rem;">| History</span></a></li>
            <li><a href="<%=request.getContextPath()%>/StudentProfileServlet"><span class="menu-text" style="font-size: 0.85rem;">| Profile</span></a></li>
            <li><a href="<%=request.getContextPath()%>/LogoutServlet"><span class="menu-text" style="font-size: 0.85rem;">| Logout</span></a></li>
        </ul>
    </nav>

    <div class="main-content">
        <%

            String errorMessage = (String) request.getAttribute("errorMessage");
            String successMessage = (String) request.getAttribute("successMessage");
            String selectedDate = (String) request.getAttribute("selectedDate");
            List<Session> allSessions = (List<Session>) request.getAttribute("allSessions");
        %>

        <div class="main-header">
            <div>
                <h1>Book Counseling Appointment</h1>
                <p class="welcome-subtitle">Select a date and available session to book your appointment</p>
            </div>
            <div class="header-date"><%= new java.text.SimpleDateFormat("EEEE, MMMM d, yyyy").format(new java.util.Date()) %></div>
        </div>

        <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i>
                <span><%= errorMessage %></span>
            </div>
        <% } %>

        <section class="content-section">
            <div class="section-header" style="display: flex; align-items: center; justify-content: space-between;">
                <h4 style="margin: 0;"><i class="fas fa-clock"></i> Select Counselling Date</h4>
                <div style="display: flex; align-items: center; gap: 12px;">
                    <div style="display: flex; align-items: center; gap: 8px; border: 2px solid #ddd; border-radius: 25px; padding: 10px 16px; background: white;">
                        <input type="date" 
                               class="date-input" 
                               id="sessionDateInput"
                               style="border: none; outline: none; background: transparent; cursor: pointer; width: 0; padding: 0;"
                               min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date(System.currentTimeMillis() + 86400000)) %>"
                               value="<%= selectedDate != null ? selectedDate : "" %>"
                               onchange="loadSessions(this.value)">
                    </div>
                </div>
            </div>

            <form action="StudentAppointmentServlet" method="POST" id="bookingForm">
                <input type="hidden" name="action" value="bookAppointment">
                <input type="hidden" name="studentID" value="<%= student.getStudentID() %>">
                <input type="hidden" name="studentInternalID" value="<%= student.getId() %>">
                <input type="hidden" name="date" id="selectedDateInput" value="<%= selectedDate %>">

                <% if (allSessions != null && !allSessions.isEmpty()) { %>
                    <div style="margin-top: 30px;">
                        <h4 style="margin-bottom: 20px;"><i class="fas fa-calendar-alt"></i> Available Sessions</h4>
                        <div class="sessions-grid">
                        <% for (Session s : allSessions) {
                               String statusClass = s.getSessionStatus() != null ? s.getSessionStatus().toLowerCase() : "";
                               boolean isDisabled = !"available".equals(statusClass);
                        %>
                            <label class="session-card <%= statusClass %>">
                                <input type="radio"
                                       name="sessionID"
                                       value="<%= s.getSessionID() %>"
                                       <%= isDisabled ? "disabled" : "" %>
                                       required>

                                <div class="session-time">
                                    <i class="fas fa-clock"></i>
                                    <span class="time-slot"><%= s.getFormattedStartTime() %> - <%= s.getFormattedEndTime() %></span>
                                </div>
                                <div class="session-status">
                                    <i class="fas fa-calendar-check"></i>
                                    <%= "available".equals(statusClass) ? "AVAILABLE" : "UNAVAILABLE" %>
                                </div>
                            </label>
                        <% } %>
                        </div>
                    </div>

                    <div style="margin-top: 30px;">
                        <label style="display: block; margin-bottom: 12px; font-weight: 600; color: #5D2E8C;">
                            <i class="fas fa-pencil-alt"></i> Reason for Appointment
                        </label>
                        <textarea name="reason" 
                                  rows="4" 
                                  style="width: 100%; border-radius: 8px; border: 2px solid #e8e3f0; padding: 12px; font-family: inherit; font-size: 1rem;" 
                                  placeholder="Please describe the reason for your appointment..."
                                  required></textarea>
                    </div>

                    <div class="form-buttons" style="margin-top: 30px;">
                        <button type="submit" class="btn-submit">
                            <i class="fas fa-check-circle"></i> Book Appointment
                        </button>
                    </div>
                <% } else if (selectedDate != null) { %>
                    <div style="margin-top: 30px; padding: 20px; background: #f5f7fa; border-radius: 8px; text-align: center;">
                        <i class="fas fa-info-circle" style="color: #6a3ba0; font-size: 2rem;"></i>
                        <p style="color: #6a3ba0; margin-top: 10px;">No available sessions for this date. Please choose another date.</p>
                    </div>
                <% } %>
            </form>
        </section>
    </div>

    <!-- Success Modal -->
    <% if (successMessage != null && !successMessage.isEmpty()) { %>
        <div class="status-modal-overlay" style="display: flex;">
            <div class="status-modal">
                <div class="modal-header">
                    <h3><i class="fas fa-check-circle"></i> Appointment Booked Successfully</h3>
                    <button class="modal-close" onclick="window.location.href='studentDashboard.jsp'">&times;</button>
                </div>
                <div class="modal-body">
                    <p class="modal-message"><%= successMessage %></p>
                    <button class="btn-submit" onclick="window.location.href='studentDashboard.jsp'">Back to Dashboard</button>
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

        // Initialize when document is loaded
        document.addEventListener('DOMContentLoaded', function() {
            const dateInput = document.getElementById('sessionDateInput');
            
            // Make calendar icon clickable to open date picker
            const calendarIcon = document.querySelector('.fa-calendar');
            if (calendarIcon) {
                calendarIcon.addEventListener('click', function() {
                    dateInput.click();
                });
            }

            // Handle session card selection
            initializeSessionCards();
        });
        
        function initializeSessionCards() {
            // Get all session cards (labels)
            const sessionCards = document.querySelectorAll('.session-card.available');
            const radioButtons = document.querySelectorAll('.session-card input[type="radio"]');
            
            // Add click event to each available session card
            sessionCards.forEach(card => {
                card.addEventListener('click', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    
                    // Remove 'selected' class from all cards
                    document.querySelectorAll('.session-card').forEach(c => {
                        c.classList.remove('selected');
                    });
                    
                    // Add 'selected' class to clicked card
                    this.classList.add('selected');
                    
                    // Find and check the radio button inside this card
                    const radio = this.querySelector('input[type="radio"]');
                    if (radio && !radio.disabled) {
                        radio.checked = true;
                    }
                });
                
                // Make card cursor pointer
                card.style.cursor = 'pointer';
            });
            
            // Add change event to radio buttons for backup
            radioButtons.forEach(radio => {
                radio.addEventListener('change', function() {
                    if (this.checked && !this.disabled) {
                        // Remove 'selected' class from all cards
                        document.querySelectorAll('.session-card').forEach(c => {
                            c.classList.remove('selected');
                        });
                        
                        // Add 'selected' class to parent card
                        const card = this.closest('.session-card');
                        if (card) {
                            card.classList.add('selected');
                        }
                    }
                });
            });
        }
    </script>

</body>
</html>