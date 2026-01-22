package com.counselling.controller;

import com.counselling.dao.StudentListDAO;
import com.counselling.model.ListStudent; // Use this model
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ListStudents") // This is the URL mapping
public class StudentServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        StudentListDAO dao = new StudentListDAO();
        
        // Use ListStudent to match your existing model file
        List<ListStudent> list = dao.getAllStudents(); 
        request.setAttribute("studentList", list);
        
        // Check for loginSuccess parameter
        String loginSuccess = request.getParameter("loginSuccess");
        if ("true".equals(loginSuccess)) {
            request.setAttribute("loginSuccess", true);
        }

        // Forward to the JSP page
        request.getRequestDispatcher("listOfStudent.jsp").forward(request, response);
    }
}
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
