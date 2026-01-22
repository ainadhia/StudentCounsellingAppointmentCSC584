<!DOCTYPE html>
<!--
To change this license header, choose License Headers in Project Properties.
To change this template file, choose Tools | Templates
and open the template in the editor.
-->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>List of Students - Counselor</title>
    <link rel="stylesheet" href="global-style.css">
    <style>
        /* Additional styles for student list page */
        .search-filter-bar {
            display: flex;
            gap: 15px;
            margin-bottom: 30px;
            flex-wrap: wrap;
            align-items: center;
        }

        .search-box {
            flex: 1;
            min-width: 250px;
        }

        .search-box input {
            width: 100%;
            padding: 14px 45px 14px 20px;
            border: 2px solid #e6e1f7;
            border-radius: 10px;
            font-size: 1em;
            transition: all 0.3s ease;
            background: white;
        }

        .search-box input:focus {
            outline: none;
            border-color: #CB95E8;
            box-shadow: 0 0 0 3px rgba(203, 149, 232, 0.1);
        }

        .filter-select {
            padding: 12px 20px;
            border: 2px solid #e6e1f7;
            border-radius: 10px;
            font-size: 0.95em;
            background: white;
            cursor: pointer;
            transition: all 0.3s ease;
            min-width: 150px;
        }

        .filter-select:hover, .filter-select:focus {
            border-color: #CB95E8;
            outline: none;
        }

        .btn-add {
            padding: 12px 24px;
            background: linear-gradient(135deg, #CB95E8 0%, #A56CD1 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(203, 149, 232, 0.3);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .btn-add:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(203, 149, 232, 0.4);
        }

        /* Student Cards Grid */
        .students-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 25px;
        }

        .student-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 8px 25px rgba(203, 149, 232, 0.12);
            border: 1px solid #f0ebfa;
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            position: relative;
            overflow: hidden;
        }

        .student-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: linear-gradient(90deg, #CB95E8 0%, #A56CD1 100%);
        }

        .student-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 35px rgba(203, 149, 232, 0.25);
            border-color: #CB95E8;
        }

        .student-header {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 20px;
        }

        .student-avatar {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: linear-gradient(135deg, #a56cd1 0%, #8a4ec7 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            font-size: 1.5em;
            border: 3px solid rgba(203, 149, 232, 0.2);
        }

        .student-info h3 {
            color: #5D2E8C;
            font-size: 1.2em;
            margin-bottom: 5px;
            font-weight: 600;
        }

        .student-id {
            color: #8B7BA6;
            font-size: 0.9em;
        }

        .student-details {
            margin-bottom: 20px;
        }

        .detail-item {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 10px;
            color: #666;
            font-size: 0.95em;
        }

        .detail-icon {
            color: #A56CD1;
            font-size: 1.1em;
        }

        .status-badge {
            display: inline-block;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .status-active {
            background: linear-gradient(135deg, #4cd964 0%, #5ac8fa 100%);
            color: white;
        }

        .status-pending {
            background: linear-gradient(135deg, #FFB347 0%, #FFCC70 100%);
            color: white;
        }

        .student-actions {
            display: flex;
            gap: 10px;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #f0ebfa;
        }

        .btn-action {
            flex: 1;
            padding: 10px;
            border: 2px solid #e6e1f7;
            background: white;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 0.9em;
            font-weight: 500;
            color: #8B7BA6;
        }

        .btn-action:hover {
            border-color: #CB95E8;
            background: #f8f7fc;
            color: #5D2E8C;
        }

        .btn-primary {
            background: linear-gradient(135deg, #CB95E8 0%, #A56CD1 100%);
            color: white;
            border: none;
        }

        .btn-primary:hover {
            background: linear-gradient(135deg, #A56CD1 0%, #8a4ec7 100%);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(203, 149, 232, 0.3);
        }
    </style>
</head>
<body>
    <!-- SIDEBAR (sama macam dashboard) -->
    <div class="sidebar">
        <div class="sidebar-header">
            <h2>COUNSELOR</h2>
            <div class="user-info">
                <div class="avatar">DR</div>
                <p>Dr. Sarah Ahmad</p>
                <small>Licensed Counselor</small>
                <small>📧 sarah.ahmad@edu.my</small>
            </div>
        </div>
        
        <ul class="sidebar-menu">
            <li>
                <a href="counselorDashboard.html">
                    <span class="menu-text">
                        <span>🏠</span>
                        <span>Dashboard</span>
                    </span>
                </a>
            </li>
            <li class="active">
                <a href="cViewList.html">
                    <span class="menu-text">
                        <span>👥</span>
                        <span>List of Students</span>
                    </span>
                </a>
            </li>
<!--            <li class="has-submenu">
                <a href="#" onclick="toggleSubmenu(event)">
                    <span class="menu-text">
                        <span>📅</span>
                        <span>Appointment</span>
                    </span>
                    <span class="arrow">▾</span>
                </a>
                <ul class="submenu">
                    <li><a href="#">➕ Create Appointment</a></li>
                    <li><a href="cAppointment.html">📋 Current Appointments</a></li>
                </ul>
            </li>-->
            <li>
                <a href="cAppointment.html">
                    <span class="menu-text">
                        <span>📅</span>
                        <span>Appointment</span>
                    </span>
                </a>
            </li>
            <li>
                <a href="#">
                    <span class="menu-text">
                        <span>💬</span>
                        <span>Session</span>
                    </span>
                </a>
            </li>
            <li class="logout">
                <a href="index.html">
                    <span class="menu-text">
                        <span>🚪</span>
                        <span>Logout</span>
                    </span>
                </a>
            </li>
        </ul>
    </div>

    <!-- MAIN CONTENT -->
    <div class="main-content">
        <!-- Header -->
        <div class="main-header">
            <div class="header-left">
                <h1>List of Students 👥</h1>
                <p class="welcome-subtitle">Manage and view all your student counseling cases</p>
            </div>
            <div class="header-date" id="currentDate">Loading...</div>
        </div>

        <!-- Summary Cards -->
        <div class="cards">
            <div class="card">
                <div class="card-icon">👨‍🎓</div>
                <div class="card-content">
                    <h3>Total Students</h3>
                    <div class="card-number">25</div>
                    <p class="card-detail">Under counseling</p>
                </div>
            </div>
            <div class="card">
                <div class="card-icon">✅</div>
                <div class="card-content">
                    <h3>Active Cases</h3>
                    <div class="card-number">18</div>
                    <p class="card-detail">Ongoing sessions</p>
                </div>
            </div>
            <div class="card">
                <div class="card-icon">⏸️</div>
                <div class="card-content">
                    <h3>On Hold</h3>
                    <div class="card-number">5</div>
                    <p class="card-detail">Temporarily paused</p>
                </div>
            </div>
            <div class="card">
                <div class="card-icon">🎉</div>
                <div class="card-content">
                    <h3>Completed</h3>
                    <div class="card-number">2</div>
                    <p class="card-detail">This month</p>
                </div>
            </div>
        </div>

        <!-- Search & Filter -->
        <div class="content-section">
            <div class="search-filter-bar">
                <div class="search-box">
                    <input type="text" id="searchInput" placeholder="🔍 Search by name, ID, or program..." onkeyup="searchStudents()">
                </div>
                <select class="filter-select" id="filterYear" onchange="filterStudents()">
                    <option value="all">All Years</option>
                    <option value="1">Year 1</option>
                    <option value="2">Year 2</option>
                    <option value="3">Year 3</option>
                    <option value="4">Year 4</option>
                </select>
                <select class="filter-select" id="filterStatus" onchange="filterStudents()">
                    <option value="all">All Status</option>
                    <option value="active">Active</option>
                    <option value="pending">Pending</option>
                    <option value="completed">Completed</option>
                </select>
                <button class="btn-add" onclick="addStudent()">
                    <span>➕</span>
                    <span>Add Student</span>
                </button>
            </div>

            <!-- Students Grid -->
            <div class="students-grid" id="studentsGrid">
                <!-- Student Card 1 -->
                <div class="student-card" data-year="2" data-status="active">
                    <div class="student-header">
                        <div class="student-avatar">AZ</div>
                        <div class="student-info">
                            <h3>Ahmad Zaki</h3>
                            <p class="student-id">STU2023001</p>
                        </div>
                    </div>
                    <div class="student-details">
                        <div class="detail-item">
                            <span class="detail-icon">📚</span>
                            <span>Computer Science - Year 2</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-icon">📧</span>
                            <span>ahmad.zaki@student.edu.my</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-icon">📞</span>
                            <span>012-345 6789</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-icon">💬</span>
                            <span>Last session: 15 Dec 2024</span>
                        </div>
                    </div>
                    <span class="status-badge status-active">Active</span>
                    <div class="student-actions">
                        <button class="btn-action btn-primary">View Profile</button>
                        <button class="btn-action">Schedule</button>
                        <button class="btn-action">Notes</button>
                    </div>
                </div>

                <!-- Student Card 2 -->
                <div class="student-card" data-year="3" data-status="active">
                    <div class="student-header">
                        <div class="student-avatar">SN</div>
                        <div class="student-info">
                            <h3>Siti Nurhaliza</h3>
                            <p class="student-id">STU2022045</p>
                        </div>
                    </div>
                    <div class="student-details">
                        <div class="detail-item">
                            <span class="detail-icon">📚</span>
                            <span>Business Admin - Year 3</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-icon">📧</span>
                            <span>siti.n@student.edu.my</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-icon">📞</span>
                            <span>013-456 7890</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-icon">💬</span>
                            <span>Last session: 13 Dec 2024</span>
                        </div>
                    </div>
                    <span class="status-badge status-active">Active</span>
                    <div class="student-actions">
                        <button class="btn-action btn-primary">View Profile</button>
                        <button class="btn-action">Schedule</button>
                        <button class="btn-action">Notes</button>
                    </div>
                </div>

                <!-- Student Card 3 -->
                <div class="student-card" data-year="1" data-status="pending">
                    <div class="student-header">
                        <div class="student-avatar">LW</div>
                        <div class="student-info">
                            <h3>Lim Wei Jie</h3>
                            <p class="student-id">STU2024012</p>
                        </div>
                    </div>
                    <div class="student-details">
                        <div class="detail-item">
                            <span class="detail-icon">📚</span>
                            <span>Engineering - Year 1</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-icon">📧</span>
                            <span>lim.wj@student.edu.my</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-icon">📞</span>
                            <span>014-567 8901</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-icon">💬</span>
                            <span>Appointment scheduled: 16 Dec 2024</span>
                        </div>
                    </div>
                    <span class="status-badge status-pending">Pending</span>
                    <div class="student-actions">
                        <button class="btn-action btn-primary">View Profile</button>
                        <button class="btn-action">Schedule</button>
                        <button class="btn-action">Notes</button>
                    </div>
                </div>

                <!-- Student Card 4 -->
                <div class="student-card" data-year="4" data-status="active">
                    <div class="student-header">
                        <div class="student-avatar">MH</div>
                        <div class="student-info">
                            <h3>Muhammad Hakim</h3>
                            <p class="student-id">STU2021078</p>
                        </div>
                    </div>
                    <div class="student-details">
                        <div class="detail-item">
                            <span class="detail-icon">📚</span>
                            <span>Accounting - Year 4</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-icon">📧</span>
                            <span>m.hakim@student.edu.my</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-icon">📞</span>
                            <span>015-678 9012</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-icon">💬</span>
                            <span>Last session: 10 Dec 2024</span>
                        </div>
                    </div>
                    <span class="status-badge status-active">Active</span>
                    <div class="student-actions">
                        <button class="btn-action btn-primary">View Profile</button>
                        <button class="btn-action">Schedule</button>
                        <button class="btn-action">Notes</button>
                    </div>
                </div>

                <!-- Student Card 5 -->
                <div class="student-card" data-year="2" data-status="active">
                    <div class="student-header">
                        <div class="student-avatar">FA</div>
                        <div class="student-info">
                            <h3>Farah Aisyah</h3>
                            <p class="student-id">STU2023034</p>
                        </div>
                    </div>
                    <div class="student-details">
                        <div class="detail-item">
                            <span class="detail-icon">📚</span>
                            <span>Psychology - Year 2</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-icon">📧</span>
                            <span>farah.a@student.edu.my</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-icon">📞</span>
                            <span>016-789 0123</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-icon">💬</span>
                            <span>Last session: 12 Dec 2024</span>
                        </div>
                    </div>
                    <span class="status-badge status-active">Active</span>
                    <div class="student-actions">
                        <button class="btn-action btn-primary">View Profile</button>
                        <button class="btn-action">Schedule</button>
                        <button class="btn-action">Notes</button>
                    </div>
                </div>

                <!-- Student Card 6 -->
                <div class="student-card" data-year="3" data-status="pending">
                    <div class="student-header">
                        <div class="student-avatar">RK</div>
                        <div class="student-info">
                            <h3>Raj Kumar</h3>
                            <p class="student-id">STU2022056</p>
                        </div>
                    </div>
                    <div class="student-details">
                        <div class="detail-item">
                            <span class="detail-icon">📚</span>
                            <span>Information Tech - Year 3</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-icon">📧</span>
                            <span>raj.k@student.edu.my</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-icon">📞</span>
                            <span>017-890 1234</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-icon">💬</span>
                            <span>Appointment scheduled: 18 Dec 2024</span>
                        </div>
                    </div>
                    <span class="status-badge status-pending">Pending</span>
                    <div class="student-actions">
                        <button class="btn-action btn-primary">View Profile</button>
                        <button class="btn-action">Schedule</button>
                        <button class="btn-action">Notes</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Update current date
        function updateDate() {
            const dateElement = document.getElementById('currentDate');
            const now = new Date();
            const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
            dateElement.textContent = now.toLocaleDateString('en-US', options);
        }

        // Toggle submenu
        function toggleSubmenu(event) {
            event.preventDefault();
            const parentLi = event.currentTarget.parentElement;
            const submenu = parentLi.querySelector('.submenu');
            const arrow = parentLi.querySelector('.arrow');
            
            submenu.classList.toggle('active');
            arrow.classList.toggle('rotate');
        }

        // Search students
        function searchStudents() {
            const input = document.getElementById('searchInput').value.toLowerCase();
            const cards = document.querySelectorAll('.student-card');
            
            cards.forEach(card => {
                const text = card.textContent.toLowerCase();
                if (text.includes(input)) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });
        }

        // Filter students
        function filterStudents() {
            const yearFilter = document.getElementById('filterYear').value;
            const statusFilter = document.getElementById('filterStatus').value;
            const cards = document.querySelectorAll('.student-card');
            
            cards.forEach(card => {
                const year = card.getAttribute('data-year');
                const status = card.getAttribute('data-status');
                
                let showCard = true;
                
                if (yearFilter !== 'all' && year !== yearFilter) {
                    showCard = false;
                }
                
                if (statusFilter !== 'all' && status !== statusFilter) {
                    showCard = false;
                }
                
                card.style.display = showCard ? 'block' : 'none';
            });
        }

        // Add student function (placeholder)
        function addStudent() {
            alert('Add Student form will open here');
        }

        // Initialize
        updateDate();
    </script>
</body>
</html>
