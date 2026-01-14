package com.counselling.controller;

import com.counselling.dao.SessionDAO;
import com.counselling.model.Session;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/SessionServlet")
public class SessionServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String startTime = request.getParameter("startTime");
        String endTime = request.getParameter("endTime");
        String sessionDate = request.getParameter("sessionDate");
        String counselorID = request.getParameter("counselorID");

        Session sessionObj = new Session();
        sessionObj.setStartTime(startTime);
        sessionObj.setEndTime(endTime);
        sessionObj.setSessionDate(sessionDate);
        sessionObj.setCounselorID(counselorID);

        SessionDAO dao = new SessionDAO();
        if (dao.addSession(sessionObj)) {
            response.sendRedirect("manageSessionCounselor.jsp?date=" + sessionDate + "&success=1");
        } else {
            response.sendRedirect("manageSessionCounselor.jsp?date=" + sessionDate + "&error=1");
        }
    }
}