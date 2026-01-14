package com.counselling.controller;

import com.counselling.dao.UserDAO;
import com.counselling.model.Student;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        UserDAO dao = new UserDAO();
        String username = request.getParameter("username");
        String role = request.getParameter("role");
        String roleID = (role.equals("S")) ? request.getParameter("studentID") : request.getParameter("counselorID");

        try {
            // Semakan keunikan
            if (dao.isUsernameTaken(username)) {
                request.setAttribute("errorMessage", "Username already exists!");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
            if (dao.isIDTaken(roleID, role)) {
                request.setAttribute("errorMessage", "ID Number already registered!");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            Student s = new Student();
            s.setUserName(username);
            s.setFullName(request.getParameter("fullname"));
            s.setUserEmail(request.getParameter("email"));
            s.setUserPassword(request.getParameter("password"));
            s.setUserPhoneNum(request.getParameter("phone"));
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