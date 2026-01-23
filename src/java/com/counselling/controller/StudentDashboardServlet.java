package com.counselling.controller;

import com.counselling.dao.StudentDashboardDAO;
import com.counselling.model.RecentSession;
import com.counselling.model.Student;

import java.io.IOException;
import java.util.List;
import javax.servlet.annotation.WebServlet;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.*;

@WebServlet(name="StudentDashboardServlet", urlPatterns={"/StudentDashboardServlet"})
public class StudentDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Object obj = session.getAttribute("user");
        if (!(obj instanceof Student)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Student student = (Student) obj;

        String studentId = student.getStudentID();
        if (studentId == null || studentId.trim().isEmpty()) {
            studentId = student.getUserName();
        }

        StudentDashboardDAO dao = new StudentDashboardDAO();

        int upcoming = 0, completed = 0, Pending = 0;
        int[] counts = dao.getCounts(studentId);
        if (counts != null && counts.length >= 3) {
            upcoming = counts[0];
            completed = counts[1];
            Pending = counts[2];
        }

        List<RecentSession> recent = dao.getRecentSessions(studentId, 5);

        request.setAttribute("activeMenu", "dashboard");
        request.setAttribute("upcoming", upcoming);
        request.setAttribute("complete", completed);
        request.setAttribute("Pending", Pending);
        request.setAttribute("recentSessions", recent);

        RequestDispatcher rd = request.getRequestDispatcher("studentDashboard.jsp");
        rd.forward(request, response);
    }
}
