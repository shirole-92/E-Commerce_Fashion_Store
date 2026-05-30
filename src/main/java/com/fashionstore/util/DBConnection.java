package com.fashionstore.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

public class DBConnection {

    private static final String URL = "jdbc:sqlite:fashion_store.db";
    private static boolean initialized = false;

    public static Connection getConnection() {
        Connection connection = null;

        try {
            Class.forName("org.sqlite.JDBC");
            connection = DriverManager.getConnection(URL);
            
            if (!initialized) {
                initializeDatabase(connection);
                initialized = true;
            }
        } catch (ClassNotFoundException e) {
            System.out.println("SQLite Driver not found!");
            e.printStackTrace();
        } catch (SQLException e) {
            System.out.println("Connection Failed!");
            e.printStackTrace();
        }

        return connection;
    }

    private static void initializeDatabase(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("CREATE TABLE IF NOT EXISTS users (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                    "name TEXT, email TEXT, password TEXT, " +
                    "address_line TEXT, city TEXT, state TEXT, pincode TEXT)");

            stmt.execute("CREATE TABLE IF NOT EXISTS categories (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)");

            stmt.execute("CREATE TABLE IF NOT EXISTS products (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, " +
                    "description TEXT, price REAL, category_id INTEGER, image_url TEXT)");

            stmt.execute("CREATE TABLE IF NOT EXISTS product_variants (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER, " +
                    "size TEXT, stock INTEGER)");

            stmt.execute("CREATE TABLE IF NOT EXISTS cart (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER)");

            stmt.execute("CREATE TABLE IF NOT EXISTS cart_items (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, cart_id INTEGER, " +
                    "product_id INTEGER, variant_id INTEGER, quantity INTEGER)");

            stmt.execute("CREATE TABLE IF NOT EXISTS orders (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, " +
                    "total_amount REAL, order_date TIMESTAMP, status TEXT)");

            stmt.execute("CREATE TABLE IF NOT EXISTS order_items (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, order_id INTEGER, " +
                    "product_id INTEGER, variant_id INTEGER, quantity INTEGER, price REAL)");
            
            System.out.println("SQLite Database initialized successfully.");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
