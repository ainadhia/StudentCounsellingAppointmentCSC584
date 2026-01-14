package com.counselling.controller;

import com.counselling.dao.UserDAO;
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
        
        // 1. Ambil data dari form login.jsp
        String roleID = request.getParameter("roleID");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        UserDAO dao = new UserDAO();
        
        try {
            // 2. Panggil fungsi authenticate dari UserDAO
            // Pastikan UserDAO anda mempunyai method authenticate()
            Student user = dao.authenticate(roleID, password, role);

            if (user != null) {
                // 3. Login Berjaya: Cipta Session
                HttpSession session = request.getSession();
                session.setAttribute("user", user);
                session.setAttribute("role", role);
                session.setAttribute("userName", user.getUserName());

                // 4. Redirect berdasarkan Role dengan parameter loginSuccess
                if ("S".equals(role)) {
                    response.sendRedirect("studentDashboard.jsp?loginSuccess=true");
                } else if ("C".equals(role)) {
                    response.sendRedirect("counselorDashboard.html?loginSuccess=true");
                }
            } else {
                // 5. Login Gagal: Hantar ralat ke login.jsp
                request.setAttribute("errorMessage", "Invalid ID or Password. Please try again.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=server");
        }
    }
}