package com.fashionstore.util;

import java.sql.Connection;

public class DBConnectionTest {

    public static void main(String[] args) {

        Connection conn = DBConnection.getConnection();

        if (conn != null) {
            System.out.println("Connection SUCCESSFUL!");
        } else {
            System.out.println("Connection FAILED!");
        }

        // Optional: close connection
        try {
            if (conn != null) {
                conn.close();
                System.out.println("Connection closed.");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}