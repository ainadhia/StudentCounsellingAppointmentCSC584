package com.counselling.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class DBConnection {
    public static Connection createConnection() {
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

    
    public static Connection getConnection() {
        return createConnection();
    }

    public PreparedStatement prepareStatement(String studentSql) {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    public void close() {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }
}

