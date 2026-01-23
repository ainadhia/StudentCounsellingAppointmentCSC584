<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Register Account | Student Counselling Appointment</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            :root {
                --uitm-purple: #42145F; 
                --uitm-gold: #FFCC00;
                --bg-light: #f4f7fc; 
                --white: #ffffff;
                --text-purple: #5D2E8C; 
                --border-color: #e6e1f7;
                --input-bg: #fafbff;
            }

            * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', sans-serif; }

            body { 
                display: flex; 
                justify-content: center; 
                align-items: center; 
                min-height: 100vh; 
                background-color: var(--bg-light); 
                padding: 40px 20px; 
            }

            .auth-container { 
                width: 100%; 
                max-width: 850px; 
                background: var(--white); 
                border-radius: 20px; 
                box-shadow: 0 15px 35px rgba(66, 20, 95, 0.1); 
                overflow: hidden; 
            }

            .auth-footer {
                text-align: center;
                margin-top: 10px;
                margin-bottom: 25px;
            }

            .auth-divider {
                border: 0;
                border-top: 1px solid #eee;
                margin-bottom: 20px;
                width: 100%;
            }

            .auth-footer p {
                color: #636e72;
                font-size: 0.95em;
            }

            .auth-footer a {
                color: var(--uitm-purple);
                font-weight: 700;
                text-decoration: none;
                margin-left: 5px;
            }

            .form-header { 
                background: var(--uitm-purple); 
                color: var(--white); 
                padding: 30px; 
                text-align: center; 
            }

            .form-header p {
                font-size: 1.2em;
                font-weight: 600;
                letter-spacing: 1px;
            }

            .gold-divider { height: 6px; background-color: #A56CD1; width: 100%; }

            .form-content { padding: 40px 50px; }

            .form-row { 
                display: flex; 
                flex-wrap: wrap; 
                gap: 25px; 
                margin-bottom: 25px;
            }

            .form-group { 
                flex: 1; 
                min-width: calc(50% - 25px);
                position: relative; 
            }

            .dynamic-section .form-row .form-group {
                min-width: calc(33.33% - 25px);
            }

            .form-group label { 
                display: block; 
                margin-bottom: 8px; 
                color: var(--text-purple); 
                font-weight: 700; 
                font-size: 0.85em; 
                text-transform: uppercase; 
                letter-spacing: 0.5px;
            }

            .form-group input { 
                width: 100%; 
                padding: 14px 16px; 
                border: 2px solid var(--border-color); 
                border-radius: 10px; 
                font-size: 0.95em; 
                background-color: var(--input-bg);
                transition: all 0.3s ease;
            }

            .form-group input:focus {
                outline: none;
                border-color: var(--uitm-purple);
                background-color: var(--white);
                box-shadow: 0 0 0 4px rgba(66, 20, 95, 0.05);
            }

            input::-ms-reveal, input::-ms-clear, input::-webkit-contacts-auto-fill-button { display: none !important; }

            .pass-toggle { 
                position: absolute; 
                right: 15px; 
                top: 38px;
                cursor: pointer; 
                color: #8B7BA6; 
                z-index: 5;
                padding: 5px;
            }

            .dynamic-section { 
                padding: 30px; 
                background-color: #f8f7fc; 
                border-radius: 15px; 
                border-left: 6px solid #A56CD1; 
                margin-bottom: 30px; 
                box-shadow: 0 4px 12px rgba(0,0,0,0.03);
            }

            .btn-register { 
                width: 100%; 
                padding: 18px; 
                background: linear-gradient(135deg, var(--uitm-purple) 0%, #5D2E8C 100%);
                color: white; 
                border: none; 
                border-radius: 12px; 
                font-weight: 700; 
                text-transform: uppercase; 
                cursor: pointer; 
                transition: 0.3s; 
                font-size: 1em;
                letter-spacing: 1px;
                margin-top: 10px;
            }

            .btn-register:hover { 
                transform: translateY(-2px);
                box-shadow: 0 8px 20px rgba(66, 20, 95, 0.2);
                filter: brightness(1.1);
            }

            .error-message {
                color: #d63031;
                font-size: 0.75em;
                margin-top: 5px;
                display: none;
                font-weight: 600;
            }

            .form-group.has-error input {
                border-color: #d63031;
                background-color: #fff5f5;
            }

            .form-group.has-error .error-message {
                display: block;
            }

            @media (max-width: 768px) {
                .form-group { min-width: 100%; }
                .dynamic-section .form-row .form-group { min-width: 100%; }
                .form-content { padding: 30px 25px; }
            }
        </style>
    </head>
    <body>
        <div class="auth-container">
            <div class="form-header"><p>REGISTRATION<br>STUDENT COUNSELLING APPOINTMENT</p></div>
            <div class="gold-divider"></div>
            <div class="form-content">
                <form action="RegisterServlet" method="POST" onsubmit="return validateForm()">
                    <div class="form-row">
                        <div class="form-group <%= "true".equals(request.getAttribute("usernameError")) ? "has-error" : "" %>">
                            <label>Username *</label>
                            <input type="text" name="username" placeholder="Enter username" required value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>">
                            <% if ("true".equals(request.getAttribute("usernameError"))) { %>
                                <div class="error-message" style="display: block;"><%= request.getAttribute("usernameErrorMsg") %></div>
                            <% } else { %>
                                <div class="error-message"></div>
                            <% } %>
                        </div>
                        <div class="form-group">
                            <label>Full Name *</label>
                            <input type="text" name="fullname" placeholder="Enter your full name" required value="<%= request.getParameter("fullname") != null ? request.getParameter("fullname") : "" %>">
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group <%= "true".equals(request.getAttribute("emailError")) ? "has-error" : "" %>">
                            <label>Email Address *</label>
                            <input type="text" name="email" placeholder="example@uitm.edu.my" required value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>">
                            <% if ("true".equals(request.getAttribute("emailError"))) { %>
                                <div class="error-message" style="display: block;"><%= request.getAttribute("emailErrorMsg") %></div>
                            <% } else { %>
                                <div class="error-message"></div>
                            <% } %>
                        </div>
                       <div class="form-group <%= "true".equals(request.getAttribute("phoneError")) ? "has-error" : "" %>">
                            <label>Phone Number *</label>
                            <input type="text" name="phone" id="phone" placeholder="01XXXXXXXX" required value="<%= request.getParameter("phone") != null ? request.getParameter("phone") : "" %>" oninput="this.value = this.value.replace(/[^0-9]/g, '');">
                            <% if ("true".equals(request.getAttribute("phoneError"))) { %>
                                <div class="error-message" style="display: block;"><%= request.getAttribute("phoneErrorMsg") %></div>
                            <% } else { %>
                                <div class="error-message"></div>
                            <% } %>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Password *</label>
                            <input type="password" name="password" id="p1" placeholder="••••••••" required value="<%= request.getParameter("password") != null ? request.getParameter("password") : "" %>">
                            <i class="fas fa-eye-slash pass-toggle" onclick="togglePass('p1', this)"></i>
                        </div>
                        <div class="form-group <%= "true".equals(request.getAttribute("passwordError")) ? "has-error" : "" %>">
                            <label>Confirm Password *</label>
                            <input type="password" name="confirm" id="p2" placeholder="••••••••" required value="<%= request.getParameter("confirm") != null ? request.getParameter("confirm") : "" %>">
                            <i class="fas fa-eye-slash pass-toggle" onclick="togglePass('p2', this)"></i>
                            <% if ("true".equals(request.getAttribute("passwordError"))) { %>
                                <div class="error-message" style="display: block;"><%= request.getAttribute("passwordErrorMsg") %></div>
                            <% } else { %>
                                <div class="error-message"></div>
                            <% } %>
                        </div>
                    </div>

                    <div class="dynamic-section">
                        <div class="form-row">
                            <div class="form-group <%= "true".equals(request.getAttribute("studentIDError")) ? "has-error" : "" %>">
                                <label>Student ID *</label>
                                <input type="text" name="studentID" placeholder="202XXXXXXXXX" required value="<%= request.getParameter("studentID") != null ? request.getParameter("studentID") : "" %>">
                                <% if ("true".equals(request.getAttribute("studentIDError"))) { %>
                                    <div class="error-message" style="display: block;"><%= request.getAttribute("studentIDErrorMsg") %></div>
                                <% } else { %>
                                    <div class="error-message"></div>
                                <% } %>
                            </div>
                            <div class="form-group">
                                <label>Faculty *</label>
                                <input type="text" name="faculty" placeholder="e.g. FSKM" required value="<%= request.getParameter("faculty") != null ? request.getParameter("faculty") : "" %>">
                            </div>
                            <div class="form-group">
                                <label>Program *</label>
                                <input type="text" name="program" placeholder="e.g. CS240" required value="<%= request.getParameter("program") != null ? request.getParameter("program") : "" %>">
                            </div>
                        </div>
                    </div>

                    <input type="hidden" name="role" value="S">

                    <div class="auth-footer">
                        <hr class="auth-divider">
                        <p>Already have an account? <a href="login.jsp">Sign In Here</a></p>
                    </div>

                    <button type="submit" class="btn-register">Register</button>
                </form>
            </div>
        </div>

        <script>
            document.querySelectorAll('input').forEach(input => {
                input.addEventListener('input', function() {
                    const formGroup = this.closest('.form-group');
                    if (formGroup) {
                        formGroup.classList.remove('has-error');
                        const errorMsg = formGroup.querySelector('.error-message');
                        if (errorMsg) {
                            errorMsg.style.display = 'none';
                            errorMsg.textContent = '';
                        }
                    }
                });
            });

            function togglePass(id, el) {
                const input = document.getElementById(id);
                if (input.type === "password") { 
                    input.type = "text"; 
                    el.classList.replace('fa-eye-slash', 'fa-eye'); 
                } else { 
                    input.type = "password"; 
                    el.classList.replace('fa-eye', 'fa-eye-slash'); 
                }
            }

            function validateForm() {
                let isValid = true;
                const p1 = document.getElementById('p1');
                const p2 = document.getElementById('p2');
                const email = document.querySelector('input[name="email"]');
                const phone = document.getElementById('phone');

                document.querySelectorAll('.form-group').forEach(group => {
                    group.classList.remove('has-error');
                });

                if (!email.value.includes('@')) {
                    email.parentElement.classList.add('has-error');
                    email.parentElement.querySelector('.error-message').textContent = 'Email must contain @';
                    email.parentElement.querySelector('.error-message').style.display = 'block';
                    isValid = false;
                }

                if (phone.value.length === 0 || isNaN(phone.value)) {
                    phone.parentElement.classList.add('has-error');
                    phone.parentElement.querySelector('.error-message').textContent = 'Phone number must contain only numbers';
                    phone.parentElement.querySelector('.error-message').style.display = 'block';
                    isValid = false;
                }

                if (p1.value !== p2.value) {
                    p2.parentElement.classList.add('has-error');
                    p2.parentElement.querySelector('.error-message').textContent = 'Passwords do not match';
                    p2.parentElement.querySelector('.error-message').style.display = 'block';
                    isValid = false;
                }

                return isValid;
            }
        </script>
    </body>
</html>