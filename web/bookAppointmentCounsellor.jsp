<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- Import Model agar bisa digunakan dalam Scriptlet --%>
<%@page import="java.util.List"%>
<%@page import="com.counselling.model.Session"%>
<%@page import="com.counselling.model.Student"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Book Appointment | Counselor Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/global-style.css">
    <style>
        /* Smooth animation for the modal appearance */
        .status-modal-overlay {
            transition: opacity 0.3s ease;
        }
        .status-modal {
            animation: modalSlideUp 0.4s ease-out;
        }
        @keyframes modalSlideUp {
            from { transform: translateY(30px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
    </style>
</head>
<body>

    <nav class="navbar">
        <div class="navbar-logo">
            <span class="logo-text">COUNSELOR SYSTEM</span>
        </div>

        <ul class="navbar-menu">
            <li>
                <a href="counsellorDashboard.jsp">
                    <span class="menu-text">
                        <span>|</span>
                        <span>Dashboard</span>
                    </span>
                </a>
            </li>
            <li>
                <a href="listOfStudent.jsp">
                    <span class="menu-text">
                        <span>|</span>
                        <span>List of Students</span>
                    </span>
                </a>
            </li>
            <li class="active">
                <a href="bookAppointmentCounsellor.jsp">
                    <span class="menu-text">
                        <span>|</span>
                        <span>Appointment</span>
                    </span>
                </a>
            </li>
            <li>
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

    <div class="main-content">
        <%
            // Mengambil data dari request attribute (pengganti EL ${...})
            String errorMessage = (String) request.getAttribute("errorMessage");
            String successMessage = (String) request.getAttribute("successMessage");
            String selectedDate = (String) request.getAttribute("selectedDate");
            Student foundStudent = (Student) request.getAttribute("foundStudent");
            List<Session> allSessions = (List<Session>) request.getAttribute("allSessions");
            String studentIDParam = request.getParameter("studentID") != null ? request.getParameter("studentID") : "";
        %>

        <div class="main-header">
            <div>
                <h1>Book Appointment</h1>
                <p class="welcome-subtitle">Search for a student and assign an available session slot.</p>
            </div>
            <div class="header-date">
                <%= new java.text.SimpleDateFormat("EEEE, MMMM d, yyyy").format(new java.util.Date()) %>
            </div>
        </div>

    <section class="content-section">
        <div class="section-header">
            <h4><i class="fas fa-user-graduate"></i> Search Student</h4>
        </div>
        <form action="AppointmentController" method="GET" style="display: flex; gap: 15px; align-items: center;">
            <input type="hidden" name="action" value="searchStudent">
            <input type="text" name="studentID" class="date-input" 
                   value="<%= studentIDParam %>" placeholder="Enter Student ID" required>
            <button type="submit" class="add-session-btn">
                <i class="fas fa-search"></i> Search
            </button>
        </form>

        <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="error-message" style="margin-top: 20px; padding: 15px;">
                <i class="fas fa-exclamation-circle"></i> <%= errorMessage %>
            </div>
        <% } %>
    </section>

    <% if (foundStudent != null) { %>
        <div class="cards">
            <div class="card">
                <div class="card-content">
                    <h3>Student Information</h3>
                    <div class="card-number" style="font-size: 1.8em;"><%= foundStudent.getFullName() %></div>
                    <div class="card-detail">ID: <%= foundStudent.getStudentID() %></div>
                </div>
            </div>
        </div>

        <section class="content-section">
            <div class="section-header">
                <h4><i class="fas fa-clock"></i> Select Session Slot</h4>
                <div style="display: flex; align-items: center; gap: 10px;">
                    <label>Choose Date:</label>
                    <input type="date"
                           id="dateInput"
                           class="date-input"
                           onchange="loadSessions(this.value)">
                </div>
            </div>
            
            <script>
                // Set minimum date to tomorrow (disable today and past dates)
                document.addEventListener('DOMContentLoaded', function() {
                    const dateInput = document.getElementById('dateInput');
                    const hiddenDateInput = document.getElementById('selectedDateInput');
                    const today = new Date();
                    const tomorrow = new Date(today);
                    tomorrow.setDate(tomorrow.getDate() + 1);
                    
                    const tomorrowStr = tomorrow.toISOString().split('T')[0];
                    dateInput.min = tomorrowStr;
                    
                    const currentDate = "<%= selectedDate != null ? selectedDate : "" %>";
                    
                    if (!currentDate || currentDate === "") {
                        dateInput.value = tomorrowStr;
                        if(hiddenDateInput) hiddenDateInput.value = tomorrowStr;
                        // Load sessions logic is handled below to avoid infinite loops
                    } else {
                        dateInput.value = currentDate;
                        if(hiddenDateInput) hiddenDateInput.value = currentDate;
                    }
                });
                
                document.getElementById('dateInput').addEventListener('change', function(e) {
                    const today = new Date();
                    const tomorrow = new Date(today);
                    tomorrow.setDate(tomorrow.getDate() + 1);
                    const minDate = tomorrow.toISOString().split('T')[0];
                    
                    if (this.value && this.value < minDate) {
                        alert('You cannot book an appointment for today or past dates. Please select a future date.');
                        this.value = minDate;
                        document.getElementById('selectedDateInput').value = minDate;
                        loadSessions(minDate);
                    } else {
                        document.getElementById('selectedDateInput').value = this.value;
                    }
                });
            </script>

            <form action="AppointmentController" method="POST">
                <input type="hidden" name="action" value="confirmBooking">
                <input type="hidden" name="studentID" value="<%= foundStudent.getStudentID() %>">
                <input type="hidden" name="studentInternalID" value="<%= foundStudent.getId() %>">
                <input type="hidden" name="date" id="selectedDateInput" value="">

                <div class="sessions-grid">
                <% 
                   if (allSessions != null && !allSessions.isEmpty()) { 
                       for (Session s : allSessions) {
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
                            <span class="session-time-text"><%= s.getFormattedStartTime() %> - <%= s.getFormattedEndTime() %></span>
                        </div>
                        <div class="session-status-pill <%= statusClass %>">
                            <i class="fas fa-calendar-check"></i>
                            <%= "available".equals(statusClass) ? "AVAILABLE" : "UNAVAILABLE" %>
                        </div>
                    </label>
                <% 
                       } 
                   } else { 
                %>
                    <div class="no-sessions" style="grid-column: 1/-1;">
                        <i class="fas fa-calendar-times"></i>
                        <h3>No Sessions Found</h3>
                        <p>There are no sessions scheduled for the selected date. Please try another date.</p>
                    </div>
                <% } %>
                </div>

                <% if (allSessions != null && !allSessions.isEmpty()) { %>
                    <div style="margin-top: 20px;">
                        <label style="display: block; margin-bottom: 8px; font-weight: bold;">Appointment Description / Notes:</label>
                        <textarea name="description" rows="3" style="width: 100%; border-radius: 8px; border: 2px solid #ddd; padding: 10px;" placeholder="Briefly describe the purpose of this appointment..."></textarea>
                    </div>

                    <div class="form-buttons" style="margin-top: 20px;">
                        <button type="submit" class="btn-submit">
                            Book Appointment
                        </button>
                    </div>
                <% } %>
            </form>
        </section>
    <% } %>

        <%-- IMPROVED MODAL LOGIC --%>
        <% if (successMessage != null && !successMessage.isEmpty()) { %>
            <div id="successPopup" class="status-modal-overlay" style="display: flex;">
                <div class="status-modal">
                    <div class="modal-header">
                        <h3><i class="fas fa-check-circle"></i> Appointment Created</h3>
                        <button class="modal-close" onclick="closeSuccessModal()">&times;</button>
                    </div>
                    <div class="modal-body">
                        <p class="modal-message"><%= successMessage %></p>
                        <button class="btn-submit" onclick="closeSuccessModal()">OK</button>
                    </div>
                </div>
            </div>
        <% } %>
    </div>

    <script>
        // Modal Control Function
        function closeSuccessModal() {
            const modal = document.getElementById('successPopup');
            if (modal) {
                modal.style.display = 'none';
            }
            // Clean the URL to prevent the popup from reappearing on refresh
            if (window.history.replaceState) {
                const url = window.location.protocol + "//" + window.location.host + window.location.pathname;
                window.history.replaceState({path:url}, '', url);
            }
        }

        function loadSessions(date) {
            const studentID = "<%= foundStudent != null ? foundStudent.getStudentID() : "" %>";
            if (studentID) {
                window.location.href = "AppointmentController?action=searchStudent&studentID=" + studentID + "&date=" + date;
            }
        }

        // Highlight selected card when clicked
        document.addEventListener('DOMContentLoaded', function() {
            const radios = document.querySelectorAll('.sessions-grid .session-card input[type="radio"]');
            
            radios.forEach(r => {
                const card = r.closest('.session-card');
                
                r.addEventListener('change', () => {
                    document.querySelectorAll('.session-card').forEach(c => c.classList.remove('selected'));
                    if (card) card.classList.add('selected');
                });
                
                if (card && !r.disabled) {
                    card.addEventListener('click', (e) => {
                        if (e.target.tagName !== 'TEXTAREA' && e.target.tagName !== 'INPUT') {
                            r.checked = true;
                            r.dispatchEvent(new Event('change', { bubbles: true }));
                        }
                    });
                }
            });
        });
    </script>

</body>
</html>