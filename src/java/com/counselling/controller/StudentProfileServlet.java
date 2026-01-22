package com.counselling.controller;

import com.counselling.dao.StudentProfileDAO;
import com.counselling.model.Student;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(name="StudentProfileServlet", urlPatterns={"/StudentProfileServlet"})
public class StudentProfileServlet extends HttpServlet {

    private final StudentProfileDAO dao = new StudentProfileDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Object obj = session.getAttribute("user");
        if (!(obj instanceof Student)) {
            response.sendRedirect(request.getContextPath() + "/unauthorized.jsp");
            return;
        }

        Student sessionStudent = (Student) obj;

        // studentId paling stabil: Student.getStudentID(), kalau null fallback username
        String studentId = sessionStudent.getStudentID();
        if (studentId == null || studentId.trim().isEmpty()) {
            studentId = sessionStudent.getUserName();
        }

        try {
            // fetch data terbaru dari DB
            Student fresh = dao.getStudentByStudentId(studentId);

            if (fresh != null) {
                // update balik session supaya JSP guna data terbaru
                session.setAttribute("user", fresh);
            }

            request.getRequestDispatcher("/studentProfile.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/studentProfile.jsp?updated=false");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Object obj = session.getAttribute("user");
        if (!(obj instanceof Student)) {
            response.sendRedirect(request.getContextPath() + "/unauthorized.jsp");
            return;
        }

        Student sessionStudent = (Student) obj;

        String studentId = request.getParameter("studentId");
        if (studentId == null || studentId.trim().isEmpty()) {
            // fallback
            studentId = sessionStudent.getStudentID();
            if (studentId == null || studentId.trim().isEmpty()) studentId = sessionStudent.getUserName();
        }

        // editable fields
        String fullName = request.getParameter("fullName");
        String userPhoneNum = request.getParameter("userPhoneNum");
        String userEmail = request.getParameter("userEmail");
        String faculty = request.getParameter("faculty");
        String program = request.getParameter("program");

        try {
            boolean ok = dao.updateStudentProfile(studentId, fullName, userPhoneNum, userEmail, faculty, program);

            if (ok) {
                // refresh session data
                Student fresh = dao.getStudentByStudentId(studentId);
                if (fresh != null) session.setAttribute("user", fresh);

                response.sendRedirect(request.getContextPath() + "/StudentProfileServlet?updated=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/StudentProfileServlet?updated=false");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/StudentProfileServlet?updated=false");
        }
    }
}
