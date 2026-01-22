package com.counselling.controller;

import com.counselling.dao.StudentDAO;
import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/studentServlet")
public class StudentServlet extends HttpServlet {

    private StudentDAO studentDAO = new StudentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int totalStudents = studentDAO.getTotalStudents();

            request.getSession().setAttribute("totalStudents", totalStudents);

            RequestDispatcher rd = request.getRequestDispatcher("counselorDashboard.jsp");
            rd.forward(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
