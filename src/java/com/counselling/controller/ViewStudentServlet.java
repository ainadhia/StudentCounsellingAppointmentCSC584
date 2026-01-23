package com.counselling.controller;

import com.counselling.dao.StudentListDAO;
import com.counselling.model.Student;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/viewStudent")
public class ViewStudentServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String studentID = request.getParameter("id");
        
        StudentListDAO dao = new StudentListDAO();
        Student s = dao.getStudentById(studentID);
        
        if (s != null) {
            request.setAttribute("student", s);
            request.getRequestDispatcher("viewStudent.jsp").forward(request, response);
        } else {
            response.sendRedirect("ListStudents?error=notFound");
        }
    }
}