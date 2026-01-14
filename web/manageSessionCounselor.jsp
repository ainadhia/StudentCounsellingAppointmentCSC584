<%@page import="com.counselling.model.Session"%>
<%@page import="com.counselling.dao.SessionDAO"%>
<%@page import="com.counselling.model.Student"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Student counselor = (Student) session.getAttribute("user");
    String cID = (counselor != null) ? counselor.getCounselorID() : "CNSL2023001";
    String cName = (counselor != null) ? counselor.getFullName() : "Senior Counselor";

    String selectedDate = request.getParameter("date");
    if(selectedDate == null || selectedDate.equals("")) {
        selectedDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
    }

    SessionDAO dao = new SessionDAO();
    List<Session> sessionList = dao.getSessionsByDate(selectedDate, cID);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Sessions</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --purple: #51245C; --light-purple: #A56CD1; --bg: #f8f7fc; }
        body { display: flex; background: var(--bg); margin: 0; font-family: 'Segoe UI', sans-serif; min-height: 100vh; }
        .sidebar { width: 280px; background: var(--purple); color: white; position: fixed; height: 100vh; padding: 30px 20px; }
        .avatar { width: 80px; height: 80px; background: #CB95E8; border-radius: 50%; margin: 0 auto 15px; display: flex; align-items: center; justify-content: center; font-size: 2em; font-weight: bold; border: 3px solid rgba(255,255,255,0.3); }
        .main-content { flex: 1; margin-left: 280px; padding: 40px; }
        .card { background: white; padding: 30px; border-radius: 15px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); }
        .header-section { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 30px; border-bottom: 1px solid #eee; padding-bottom: 20px; }
        .sessions-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 20px; }
        .session-card { background: #fcfbff; border: 1px solid #e6e1f7; border-radius: 12px; padding: 25px; text-align: center; transition: 0.3s; }
        .session-card:hover { transform: translateY(-5px); box-shadow: 0 5px 15px rgba(165,108,209,0.2); }
        .time-text { font-size: 1.2em; font-weight: 700; color: var(--purple); }
        .badge { display: inline-block; margin-top: 10px; padding: 5px 15px; border-radius: 20px; font-size: 0.8em; font-weight: bold; }
        .available { background: #e8f6ef; color: #28a745; }
        .booked { background: #fdecea; color: #dc3545; }
        .btn-add { background: var(--light-purple); color: white; border: none; padding: 12px 25px; border-radius: 8px; cursor: pointer; font-weight: 600; }
        input[type="date"], input[type="time"] { padding: 10px; border: 1px solid #ddd; border-radius: 8px; }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="avatar"><%= cName.substring(0,2).toUpperCase() %></div>
        <div style="text-align:center;">
            <p style="font-weight:600; margin:0;"><%= cName %></p>
            <small>ID: <%= cID %></small>
        </div>
    </div>

    <div class="main-content">
        <h1 style="color:var(--purple);">Manage Counseling Sessions</h1>
        <div class="card">
            <div class="header-section">
                <form action="manageSessionCounselor.jsp" method="GET">
                    <label style="display:block; font-weight:600; margin-bottom:5px;">Select Date</label>
                    <input type="date" name="date" value="<%= selectedDate %>" onchange="this.form.submit()">
                </form>
                <div id="addForm" style="display:none; border:1px dashed var(--light-purple); padding:15px; border-radius:10px;">
                    <form action="SessionServlet" method="POST">
                        <input type="hidden" name="sessionDate" value="<%= selectedDate %>">
                        <input type="hidden" name="counselorID" value="<%= cID %>">
                        <input type="time" name="startTime" required>
                        <input type="time" name="endTime" required>
                        <button type="submit" class="btn-add">Confirm</button>
                    </form>
                </div>
                <button class="btn-add" onclick="document.getElementById('addForm').style.display='block'">+ Add New Session</button>
            </div>

            <div class="sessions-grid">
                <% for (Session s : sessionList) { %>
                    <div class="session-card">
                        <div class="time-text"><%= s.getStartTime() %> - <%= s.getEndTime() %></div>
                        <div class="badge <%= s.getSessionStatus().toLowerCase() %>"><%= s.getSessionStatus().toUpperCase() %></div>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>