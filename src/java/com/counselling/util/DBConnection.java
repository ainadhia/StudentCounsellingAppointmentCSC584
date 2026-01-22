package com.counselling.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    public static Connection getConnection() {
        Connection con = null;
        try {
            Class.forName("org.apache.derby.jdbc.ClientDriver");
            // Ensure this URL matches your Services tab in NetBeans
            String url = "jdbc:derby://localhost:1527/CounsellingDB";
            con = DriverManager.getConnection(url, "app", "app");
            System.out.println("DEBUG: Connection established successfully.");
        } catch (ClassNotFoundException | SQLException e) {
            System.err.println("DEBUG: Connection Failed: " + e.getMessage());
            e.printStackTrace();
        }
        return con;
    }
}