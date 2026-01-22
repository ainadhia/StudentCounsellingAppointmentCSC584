package com.counselling.controller;

import com.counselling.dao.UserDAO;
import com.counselling.model.Student;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        UserDAO dao = new UserDAO();
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirm = request.getParameter("confirm");
        String role = request.getParameter("role");
        String roleID = (role.equals("S")) ? request.getParameter("studentID") : request.getParameter("counselorID");

        boolean hasError = false;

        try {
            // Validate email format
            if (!email.contains("@")) {
                request.setAttribute("emailError", "true");
                request.setAttribute("emailErrorMsg", "Email must contain @");
                hasError = true;
            }

            // Validate phone is numbers
            if (!phone.matches("\\d+")) {
                request.setAttribute("phoneError", "true");
                request.setAttribute("phoneErrorMsg", "Phone number must contain only numbers");
                hasError = true;
            }

            // Validate passwords match
            if (!password.equals(confirm)) {
                request.setAttribute("passwordError", "true");
                request.setAttribute("passwordErrorMsg", "Passwords do not match");
                hasError = true;
            }

            // Check username duplication
            if (dao.isUsernameTaken(username)) {
                request.setAttribute("usernameError", "true");
                request.setAttribute("usernameErrorMsg", "Username already taken by another user");
                hasError = true;
            }

            // Check ID duplication
            if (dao.isIDTaken(roleID, role)) {
                request.setAttribute("studentIDError", "true");
                request.setAttribute("studentIDErrorMsg", "ID Number already registered");
                hasError = true;
            }

            if (hasError) {
                // Keep form data visible
                request.setAttribute("username", username);
                request.setAttribute("email", email);
                request.setAttribute("phone", phone);
                request.setAttribute("password", password);
                request.setAttribute("confirm", confirm);
                request.setAttribute("role", role);
                request.setAttribute("roleID", roleID);
                
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            // Create student object
            Student s = new Student();
            s.setUserName(username);
            s.setFullName(request.getParameter("fullname"));
            s.setUserEmail(email);
            s.setUserPassword(password);
            s.setUserPhoneNum(phone);
            s.setRole(role);

            if (role.equals("S")) {
                s.setStudentID(roleID);
                s.setFaculty(request.getParameter("faculty"));
                s.setProgram(request.getParameter("program"));
            } else {
                s.setCounselorID(roleID);
                s.setRoomNo(request.getParameter("roomNo"));
            }

            if (dao.registerUser(s)) {
                response.sendRedirect("login.jsp?success=true");
            } else {
                response.sendRedirect("register.jsp?error=database");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("register.jsp?error=server");
        }
    }
}