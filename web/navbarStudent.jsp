<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String active = (request.getAttribute("activeMenu") == null) ? "" : request.getAttribute("activeMenu").toString();
%>

<nav class="top-nav">
  <div class="nav-left">
    <span class="brand">UiTM Counselling</span>
  </div>

  <ul class="nav-links">
    <li class="<%= "dashboard".equals(active) ? "active" : "" %>">
      <a href="StudentDashboardServlet"><i class="fa-solid fa-chart-line"></i> Dashboard</a>
    </li>

    <li class="dropdown <%= "appointment".equals(active) ? "active" : "" %>">
      <a href="#"><i class="fa-regular fa-calendar"></i> Appointment <i class="fa-solid fa-caret-down"></i></a>
      <ul class="dropdown-menu">
        <li><a href="StudentAppointmentServlet">Manage Appointment</a></li>
      </ul>
    </li>

    <li class="<%= "history".equals(active) ? "active" : "" %>">
      <a href="StudentHistoryServlet"><i class="fa-regular fa-clock"></i> History</a>
    </li>

    <li class="<%= "profile".equals(active) ? "active" : "" %>">
      <a href="StudentProfileServlet"><i class="fa-regular fa-user"></i> Profile</a>
    </li>

    <li class="logout">
      <a href="LogoutServlet"><i class="fa-solid fa-right-from-bracket"></i> Logout</a>
    </li>
  </ul>
</nav>
