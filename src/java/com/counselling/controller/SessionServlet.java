package com.counselling.controller;

import com.counselling.dao.SessionDAO;
import com.counselling.model.Session;
import com.counselling.model.Student; // Guna model user anda
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/SessionServlet")
public class SessionServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession sessionObj = request.getSession();
        Student counselor = (Student) sessionObj.getAttribute("user");
        
        if (counselor == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String startTime = request.getParameter("startTime");
        String endTime = request.getParameter("endTime");
        
        Session newSession = new Session();
        newSession.setStartTime(startTime);
        newSession.setEndTime(endTime);
        newSession.setCounselorId(counselor.getCounselorID());

        SessionDAO dao = new SessionDAO();
        try {
            if (dao.addSession(newSession)) {
                response.sendRedirect("manageSessions.jsp?success=added");
            } else {
                response.sendRedirect("manageSessions.jsp?error=failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("manageSessions.jsp?error=exception");
        }
    }
}