<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | UiTM Counselling</title>
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

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        
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
            max-width: 500px; /* Saiz lebih kecil dan fokus untuk Login */
            background: var(--white); 
            border-radius: 20px; 
            box-shadow: 0 15px 35px rgba(66, 20, 95, 0.1); 
            overflow: hidden; 
        }
        
        /* Container untuk Link Navigasi */
        .auth-footer {
            text-align: center;
            margin-top: 10px;    /* Jarak dari elemen atas */
            margin-bottom: 25px; /* Jarak sebelum butang */
        }

        /* Garisan Pemisah yang seragam */
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
            text-transform: uppercase;
        }

        .gold-divider { height: 6px; background-color: var(--uitm-gold); width: 100%; }

        .form-content { padding: 40px 50px; }

        .form-row { 
            display: flex; 
            flex-direction: column; 
            gap: 25px; 
            margin-bottom: 25px; 
        }

        .form-group { 
            position: relative; 
            width: 100%; 
        }

        .form-group label { 
            display: block; 
            margin-bottom: 10px; 
            color: var(--text-purple); 
            font-weight: 700; 
            font-size: 0.85em; 
            text-transform: uppercase; 
            letter-spacing: 0.5px;
        }

        .form-group input { 
            width: 100%; 
            padding: 14px 45px 14px 16px; 
            border: 2px solid var(--border-color); 
            border-radius: 12px; 
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

        /* Padam ikon mata default pelayar */
        input::-ms-reveal, input::-ms-clear { display: none !important; }

        .pass-toggle { 
            position: absolute; 
            right: 15px; 
            top: 42px; /* Kedudukan selari dengan input */
            cursor: pointer; 
            color: #8B7BA6; 
            z-index: 5;
            padding: 5px;
        }

        .role-selection-box { 
            background-color: #f8f9ff; 
            padding: 25px 30px; 
            border-radius: 15px; 
            border: 2px dashed var(--border-color); 
            margin-bottom: 30px; 
        }

        .role-selection-box p {
            margin-bottom: 15px;
            font-weight: 800;
            color: var(--text-purple);
            font-size: 0.85em;
            text-transform: uppercase;
        }

        .btn-login { 
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
        }

        .btn-login:hover { 
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(66, 20, 95, 0.2);
            filter: brightness(1.1);
        }

        .error-banner { 
            background: #fce4e4; 
            color: #d63031; 
            padding: 15px; 
            border-radius: 10px; 
            border: 1px solid #d63031; 
            margin-bottom: 25px; 
            font-weight: bold; 
            text-align: center;
            font-size: 0.9em;
        }

        .success-banner { 
            background: #e8f5e9; 
            color: #2e7d32; 
            padding: 15px; 
            border-radius: 10px; 
            border: 1px solid #2e7d32; 
            margin-bottom: 25px; 
            font-weight: bold; 
            text-align: center;
            font-size: 0.9em;
        }
        
        .register-link { 
            text-align: center; 
            margin-top: 30px; 
            border-top: 1px solid #eee; 
            padding-top: 20px; 
        }
        
        .register-link p {
            color: #636e72;
            font-size: 0.95em;
        }

        .register-link a { 
            color: var(--uitm-purple); 
            font-weight: 700; 
            text-decoration: none;
            margin-left: 5px;
        }
        
        .register-link a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="auth-container">
        <div class="form-header"><p>UiTM Counselling Login</p></div>
        <div class="gold-divider"></div>
        
        <div class="form-content">
            
            <%-- Mesej Berjaya (Diterima dari RegisterServlet) --%>
            <% if ("true".equals(request.getParameter("success"))) { %>
                <div class="success-banner">
                    <i class="fas fa-check-circle"></i> Registration successful! Please login.
                </div>
            <% } %>

            <%-- Mesej Ralat (Diterima dari LoginServlet) --%>
            <% 
                String error = (String) request.getAttribute("errorMessage");
                if (error != null && !error.isEmpty()) { 
            %>
                <div class="error-banner">
                    <i class="fas fa-exclamation-circle"></i> <%= error %>
                </div>
            <% } %>

            <form action="LoginServlet" method="POST">
                <div class="role-selection-box">
                    <p>Sign In As *</p>
                    <div style="display:flex; gap:40px;">
                        <label style="cursor:pointer; display:flex; align-items:center; gap:8px; font-weight:600; color:var(--text-purple);">
                            <input type="radio" name="role" value="S" checked onclick="updateLabel('S')" style="accent-color: var(--uitm-purple); width: 18px; height: 18px;"> Student
                        </label>
                        <label style="cursor:pointer; display:flex; align-items:center; gap:8px; font-weight:600; color:var(--text-purple);">
                            <input type="radio" name="role" value="C" onclick="updateLabel('C')" style="accent-color: var(--uitm-purple); width: 18px; height: 18px;"> Counselor
                        </label>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label id="idLabel">Student ID *</label>
                        <input type="text" name="roleID" id="roleID" placeholder="Enter your Student ID" required>
                    </div>

                    <div class="form-group">
                        <label>Password *</label>
                        <input type="password" name="password" id="p1" placeholder="••••••••" required>
                        <i class="fas fa-eye-slash pass-toggle" onclick="togglePass('p1', this)"></i>
                    </div>
                </div>

                <div style="text-align: center; margin-bottom: 20px; border-bottom: 1px solid #eee; padding-bottom: 20px;">
                    <p style="color: #636e72; font-size: 0.95em;">
                <div class="auth-footer">
                        <hr class="auth-divider">
                        <p>Don't have an account? <a href="register.jsp">Register Now</a></p>
                    </div>

                    <button type="submit" class="btn-login">Sign In</button>
                    

        </div>
    </div>

    <script>
        // Tukar label secara dinamik mengikut Role
        function updateLabel(role) {
            const label = document.getElementById('idLabel');
            const input = document.getElementById('roleID');
            if (role === 'S') {
                label.innerText = 'Student ID *';
                input.placeholder = 'Enter your Student ID';
            } else {
                label.innerText = 'Counselor ID *';
                input.placeholder = 'Enter your Counselor ID';
            }
        }

        // Fungsi sorok/papar password
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
    </script>
</body>
</html>