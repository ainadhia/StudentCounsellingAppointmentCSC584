<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="com.counselling.model.Student"%>
<%@page import="com.counselling.util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Student counselor = (Student) session.getAttribute("user");
    String cID = (counselor != null) ? counselor.getCounselorID() : "CNSL2023001";
    String cName = (counselor != null) ? counselor.getFullName() : "Senior Counselor";

    String popupMsg = "";
    String popupType = "";
    
    String selectedDate = request.getParameter("date");
    if(selectedDate == null || selectedDate.equals("")) {
        selectedDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String startTime = request.getParameter("startTime");
        String endTime = request.getParameter("endTime");
        String sDate = request.getParameter("sessionDate");

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.createConnection();
            String sql = "INSERT INTO SESSION (STARTTIME, ENDTIME, SESSIONSTATUS, COUNSELORID, SESSIONDATE) VALUES (?, ?, 'Available', ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setString(1, startTime);
            ps.setString(2, endTime);
            ps.setString(3, cID);
            ps.setString(4, sDate);
            ps.executeUpdate();
            popupMsg = "Session successfully added!";
            popupType = "success";
        } catch (Exception e) {
            popupMsg = "Error: " + e.getMessage();
            popupType = "error";
        } finally {
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Manage Counseling Sessions</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            :root { --purple: #51245C; --light-purple: #A56CD1; --bg: #f8f7fc; }
            body { display: flex; background: var(--bg); margin: 0; font-family: 'Segoe UI', sans-serif; }

            .sidebar { width: 280px; background: var(--purple); color: white; height: 100vh; position: fixed; padding: 30px 20px; }
            .avatar { width: 80px; height: 80px; background: #CB95E8; border-radius: 50%; margin: 0 auto 15px; display: flex; align-items: center; justify-content: center; font-size: 2em; font-weight: bold; border: 3px solid rgba(255,255,255,0.3); }

            .main-content { flex: 1; margin-left: 280px; padding: 40px; }
            .card { background: white; padding: 30px; border-radius: 15px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); }

            .header-section { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
            .date-input { padding: 10px; border: 1px solid #ddd; border-radius: 8px; width: 200px; }

            .sessions-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 20px; margin-top: 30px; }
            .session-card { background: white; border: 1px solid #e6e1f7; border-radius: 12px; padding: 20px; text-align: center; transition: 0.3s; }
            .session-card:hover { transform: translateY(-5px); box-shadow: 0 5px 15px rgba(165,108,209,0.2); }
            .time-text { font-size: 1.1em; font-weight: 600; color: var(--purple); margin-bottom: 5px; }
            .duration { color: #8B7BA6; font-size: 0.85em; margin-bottom: 12px; }

            .badge { padding: 5px 15px; border-radius: 20px; font-size: 0.75em; font-weight: bold; text-transform: uppercase; }
            .available { background: #e8f6ef; color: #155724; }
            .booked { background: #fdecea; color: #721c24; }

            .btn-add { background: var(--light-purple); color: white; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer; font-weight: 600; }

            #addModal { display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); justify-content:center; align-items:center; z-index:1000; }
            .modal-content { background:white; padding:30px; border-radius:15px; width:400px; }
        </style>
    </head>
    <body>

        <div class="sidebar">
            <div class="avatar"><%= cName.substring(0,2).toUpperCase() %></div>
            <div style="text-align:center;">
                <p style="font-weight:600; margin:0;"><%= cName %></p>
                <small>ID: <%= cID %></small>
            </div>
            <ul style="list-style:none; padding:40px 0;">
                <li style="padding:15px 0; border-bottom:1px solid rgba(255,255,255,0.1);"><i class="fas fa-tasks"></i> Manage Sessions</li>
            </ul>
        </div>

        <div class="main-content">
            <h1 style="color:var(--purple); margin:0;">Manage Counseling Sessions</h1>
            <p style="color:#8B7BA6; margin-bottom:40px;">Create, manage, and view available session slots.</p>

            <div class="card">
                <div class="header-section">
                    <div>
                        <label style="display:block; font-weight:600; margin-bottom:5px;"><i class="fas fa-calendar-day"></i> Select Session Date</label>
                        <input type="date" id="dateFilter" class="date-input" value="<%= selectedDate %>" onchange="filterDate(this.value)">
                    </div>
                    <button class="btn-add" onclick="showModal()"><i class="fas fa-plus-circle"></i> Add New Session</button>
                </div>

                <h3 style="color:var(--purple); border-bottom:1px solid #eee; padding-bottom:15px;"><i class="fas fa-list-ul"></i> Existing Sessions on This Date</h3>

                <div class="sessions-grid">
                    <%
                        Connection connLoad = null;
                        PreparedStatement psLoad = null;
                        ResultSet rs = null;
                        try {
                            connLoad = DBConnection.createConnection();
                            String query = "SELECT * FROM SESSION WHERE COUNSELORID = ? AND SESSIONDATE = ? ORDER BY STARTTIME ASC";
                            psLoad = connLoad.prepareStatement(query);
                            psLoad.setString(1, cID);
                            psLoad.setString(2, selectedDate);
                            rs = psLoad.executeQuery();

                            while(rs.next()){
                                String status = rs.getString("SESSIONSTATUS");
                    %>
                        <div class="session-card">
                            <div class="time-text"><%= rs.getString("STARTTIME").substring(0,5) %> - <%= rs.getString("ENDTIME").substring(0,5) %></div>
                            <div class="duration">1 hour</div>
                            <span class="badge <%= status.toLowerCase() %>"><%= status %></span>
                        </div>
                    <%
                            }
                        } catch(Exception e) { out.println(e.getMessage()); }
                        finally {
                            if (rs != null) rs.close();
                            if (psLoad != null) psLoad.close();
                            if (connLoad != null) connLoad.close();
                        }
                    %>
                </div>
            </div>
        </div>

        <div id="addModal">
            <div class="modal-content">
                <h3 style="color:var(--purple); margin-top:0;">Add New Session</h3>
                <form method="POST">
                    <input type="hidden" name="sessionDate" value="<%= selectedDate %>">
                    <label style="display:block; margin-bottom:5px;">Start Time</label>
                    <input type="time" name="startTime" class="date-input" style="width:100%; margin-bottom:15px;" required>
                    <label style="display:block; margin-bottom:5px;">End Time</label>
                    <input type="time" name="endTime" class="date-input" style="width:100%; margin-bottom:20px;" required>
                    <div style="display:flex; justify-content:flex-end; gap:10px;">
                        <button type="button" onclick="hideModal()" style="background:#eee; border:none; padding:10px 20px; border-radius:8px; cursor:pointer;">Cancel</button>
                        <button type="submit" class="btn-add">Confirm & Create</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            function filterDate(val) { window.location.href = "manageSessionCounselor.jsp?date=" + val; }
            function showModal() { document.getElementById('addModal').style.display = 'flex'; }
            function hideModal() { document.getElementById('addModal').style.display = 'none'; }

            <% if(!popupMsg.equals("")) { %>
                alert("<%= popupMsg %>");
            <% } %>
        </script>

    </body>
</html>