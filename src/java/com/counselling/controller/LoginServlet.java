package com.counselling.controller;

import com.counselling.dao.UserDAO;
import com.counselling.model.Counselor;
import com.counselling.model.Student;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String roleID = request.getParameter("roleID");
        String password = request.getParameter("password");
        String role = request.getParameter("role"); 
        
        UserDAO dao = new UserDAO();
        
        try {
            HttpSession session = request.getSession();
            
            if ("S".equals(role)) {
                Student student = dao.authenticate(roleID, password, role);
                if (student != null) {
                    session.setAttribute("user", student);
                    session.setAttribute("role", "S");
                    session.setAttribute("userName", student.getUserName());
                    response.sendRedirect("StudentDashboardServlet?loginSuccess=true");
                } else {
                    request.setAttribute("errorMessage", "Invalid ID or Password. Please try again.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                }
                
            } else if ("C".equals(role)) {
                Counselor counselor = dao.authenticateCounselor(roleID, password);
                if (counselor != null) {
                    session.setAttribute("user", counselor);
                    session.setAttribute("role", "C");
                    session.setAttribute("userName", counselor.getUserName());
                    response.sendRedirect("counselorDashboard.jsp?loginSuccess=true");
                } else {
                    request.setAttribute("errorMessage", "Invalid ID or Password. Please try again.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                }
                
            } else {
                request.setAttribute("errorMessage", "Role not recognized.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=server");
        }
    }
}