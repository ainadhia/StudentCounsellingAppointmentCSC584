<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counselling.model.Student"%>

<%
    Object obj = session.getAttribute("user");
    if (obj == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    if (!(obj instanceof Student)) {
        response.sendRedirect(request.getContextPath() + "/unauthorized.jsp");
        return;
    }

    Student student = (Student) obj;

    String displayName = (student.getFullName() != null && !student.getFullName().trim().isEmpty())
            ? student.getFullName()
            : student.getUserName();

    String studentId = student.getStudentID();
    if (studentId == null || studentId.trim().isEmpty()) studentId = student.getUserName();

    String faculty = (student.getFaculty() != null && !student.getFaculty().trim().isEmpty()) ? student.getFaculty() : "-";
    String program = (student.getProgram() != null && !student.getProgram().trim().isEmpty()) ? student.getProgram() : "-";

    String phone = (student.getUserPhoneNum() != null) ? student.getUserPhoneNum() : "";
    String email = (student.getUserEmail() != null) ? student.getUserEmail() : "";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Profile</title>

    <link rel="stylesheet" href="<%=request.getContextPath()%>/student.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>

<body>

<div class="navbar">
    <div class="navbar-header">
        <h2>UiTM Counselling</h2>
    </div>

    <ul class="navbar-menu">
        <li>
            <a href="<%=request.getContextPath()%>/StudentDashboardServlet">

                <span class="menu-text"><span>|</span><span>Dashboard</span></span>
            </a>
        </li>

        <li class="dropdown">
    <a href="#">
        <span class="menu-text">
            <span>|</span>
            <span>Appointment</span>
        </span>
        <i class="fa-solid fa-caret-down"></i>
    </a>
    <ul class="dropdown-menu">
        <li><a href="<%=request.getContextPath()%>/StudentAppointmentServlet">Manage Appointment</a></li>
    </ul>
</li>


        <li>
            <a href="<%=request.getContextPath()%>/StudentHistoryServlet">
                <span class="menu-text"><span>|</span><span>History</span></span>
            </a>
        </li>

        <li class="active">
            <a href="<%=request.getContextPath()%>/StudentProfileServlet">
                <span class="menu-text"><span>|</span><span>Profile</span></span>
            </a>
        </li>

        <li class="logout">
            <a href="<%=request.getContextPath()%>/LogoutServlet">
                <span class="menu-text"><span>|</span><span>Logout</span></span>
            </a>
        </li>
    </ul>
</div>

<div class="main-content">

    <header class="main-header profile-header">
        <div class="header-left">
            <h1>My Profile</h1>
            <p class="welcome-subtitle">View and update your profile information</p>
        </div>
    </header>

    <%
        String updated = request.getParameter("updated"); // true / false / null
        if ("true".equals(updated)) {
    %>
        <script>alert("Profile updated successfully!");</script>
    <%
        } else if ("false".equals(updated)) {
    %>
        <script>alert("Update failed. Please try again.");</script>
    <%
        }
    %>

    <div class="profile-card">
        <div class="profile-card-header">
            <h2>Personal Information</h2>
            <p class="muted">Only selected fields can be edited.</p>
        </div>

        <form id="profileForm" action="<%=request.getContextPath()%>/StudentProfileServlet" method="POST">

            <div class="form-row">
                <div class="form-group">
                    <label>User Name</label>
                    <input type="text" name="userName" value="<%= student.getUserName() %>" disabled>
                </div>

                <div class="form-group">
                    <label>Full Name</label>
                    <input type="text" name="fullName" value="<%= displayName %>" disabled>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Student ID</label>
                    <input type="text" name="studentId" value="<%= studentId %>" disabled>
                </div>

                <div class="form-group">
                    <label>Phone Number</label>
                    <input type="text" name="userPhoneNum" value="<%= phone %>" disabled>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group full-width">
                    <label>Email</label>
                    <input type="email" name="userEmail" value="<%= email %>" disabled>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Faculty</label>
                    <input type="text" name="faculty" value="<%= faculty %>" disabled>
                </div>

                <div class="form-group">
                    <label>Program</label>
                    <input type="text" name="program" value="<%= program %>" disabled>
                </div>
            </div>

            <div class="form-actions">
                <button type="button" id="updateBtn" class="btn-primary">
                    <i class="fa-solid fa-pen-to-square"></i> Update
                </button>

                <button type="submit" id="saveBtn" class="btn-primary" disabled>
                    <i class="fa-solid fa-floppy-disk"></i> Save
                </button>
            </div>

        </form>
    </div>
</div>

<script>
    const updateBtn = document.getElementById('updateBtn');
    const saveBtn = document.getElementById('saveBtn');

    const editableFields = ['fullName', 'userPhoneNum', 'userEmail', 'faculty', 'program'];
    const inputs = document.querySelectorAll('#profileForm input');

    updateBtn.addEventListener('click', () => {
        inputs.forEach(input => {
            if (editableFields.includes(input.name)) {
                input.disabled = false;
            }
        });
        saveBtn.disabled = false;
        updateBtn.disabled = true;
    });
</script>

</body>
</html>

