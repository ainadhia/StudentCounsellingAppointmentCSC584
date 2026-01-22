package com.counselling.util;
import java.sql.*;

public class DBConnection {
    public static Connection createConnection() {
        Connection conn = null;
        try {
            Class.forName("org.apache.derby.jdbc.ClientDriver");
            // Guna URL dari tab Services anda
            conn = DriverManager.getConnection("jdbc:derby://localhost:1527/CounsellingDB", "app", "app");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return conn;
    }
}