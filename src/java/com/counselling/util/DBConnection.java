<<<<<<< HEAD
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
=======
/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.counselling.util;

//import java.sql.Connection;

/**
 *
 * @author Aina
 */
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    public static Connection createConnection() {
        Connection con = null;

        try {
            Class.forName("org.apache.derby.jdbc.ClientDriver");

            String url = "jdbc:derby://localhost:1527/CounsellingDB";
            String username = "app";
            String password = "app";

            con = DriverManager.getConnection(url, username, password);
            System.out.println("Database connection successful!");

        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }

        return con;
    }

    public static Connection getConnection() {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }
}

>>>>>>> cfe4021dbeaf489fd67b19fec1c67eb660810512
