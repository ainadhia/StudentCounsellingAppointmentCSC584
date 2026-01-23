package com.counselling.controller;

import com.counselling.dao.StudentListDAO;
import com.counselling.model.ListStudent; 
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ListStudents") 
public class StudentServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        StudentListDAO dao = new StudentListDAO();
        
        List<ListStudent> list = dao.getAllStudents(); 
        request.setAttribute("studentList", list);
        
        String loginSuccess = request.getParameter("loginSuccess");
        if ("true".equals(loginSuccess)) {
            request.setAttribute("loginSuccess", true);
        }

        request.getRequestDispatcher("listOfStudent.jsp").forward(request, response);
    }
}
