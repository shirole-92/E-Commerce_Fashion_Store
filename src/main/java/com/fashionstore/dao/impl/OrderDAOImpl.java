package com.fashionstore.dao.impl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.fashionstore.dao.OrderDAO;
import com.fashionstore.model.Order;
import com.fashionstore.model.OrderItem;
import com.fashionstore.util.DBConnection;

public class OrderDAOImpl implements OrderDAO {

    @Override
    public boolean placeOrder(int userId, String paymentMethod) {

        String getCartQuery = "SELECT id FROM cart WHERE user_id = ?";
        String getItemsQuery = "SELECT * FROM cart_items WHERE cart_id = ?";
        String insertOrderQuery = "INSERT INTO orders (user_id, total_amount, order_date, status, payment_method) VALUES (?, ?, ?, ?, ?)";
        String insertOrderItemQuery = "INSERT INTO order_items (order_id, product_id, variant_id, quantity, price) VALUES (?, ?, ?, ?, ?)";
        String getProductPriceQuery = "SELECT price FROM products WHERE id = ?";
        String clearCartQuery = "DELETE FROM cart_items WHERE cart_id = ?";

        try (Connection conn = DBConnection.getConnection()) {

            conn.setAutoCommit(false); // transaction start

            // 1. Get cart ID
            PreparedStatement cartPs = conn.prepareStatement(getCartQuery);
            cartPs.setInt(1, userId);
            ResultSet cartRs = cartPs.executeQuery();

            if (!cartRs.next()) {
                return false;
            }

            int cartId = cartRs.getInt("id");

            // 2. Get cart items
            PreparedStatement itemsPs = conn.prepareStatement(getItemsQuery);
            itemsPs.setInt(1, cartId);
            ResultSet itemsRs = itemsPs.executeQuery();

            List<OrderItem> orderItems = new ArrayList<>();
            double totalAmount = 0;

            while (itemsRs.next()) {

                int productId = itemsRs.getInt("product_id");
                int variantId = itemsRs.getInt("variant_id");
                int quantity = itemsRs.getInt("quantity");

                // get price
                PreparedStatement pricePs = conn.prepareStatement(getProductPriceQuery);
                pricePs.setInt(1, productId);
                ResultSet priceRs = pricePs.executeQuery();

                double price = 0;
                if (priceRs.next()) {
                    price = priceRs.getDouble("price");
                }

                totalAmount += price * quantity;

                OrderItem item = new OrderItem();
                item.setProductId(productId);
                item.setVariantId(variantId);
                item.setQuantity(quantity);
                item.setPrice(price);

                orderItems.add(item);
            }

            // 3. Insert into orders table
            PreparedStatement orderPs = conn.prepareStatement(insertOrderQuery, Statement.RETURN_GENERATED_KEYS);
            orderPs.setInt(1, userId);
            orderPs.setDouble(2, totalAmount);
            orderPs.setTimestamp(3, new Timestamp(System.currentTimeMillis()));
            orderPs.setString(4, "PLACED");
            orderPs.setString(5, paymentMethod);

            int orderInserted = orderPs.executeUpdate();

            if (orderInserted == 0) {
                conn.rollback();
                return false;
            }

            ResultSet generatedKeys = orderPs.getGeneratedKeys();
            int orderId = 0;

            if (generatedKeys.next()) {
                orderId = generatedKeys.getInt(1);
            }

            // 4. Insert order items
            PreparedStatement orderItemPs = conn.prepareStatement(insertOrderItemQuery);

            for (OrderItem item : orderItems) {

                orderItemPs.setInt(1, orderId);
                orderItemPs.setInt(2, item.getProductId());
                orderItemPs.setInt(3, item.getVariantId());
                orderItemPs.setInt(4, item.getQuantity());
                orderItemPs.setDouble(5, item.getPrice());

                orderItemPs.addBatch();
            }

            orderItemPs.executeBatch();

            // 5. Clear cart
            PreparedStatement clearPs = conn.prepareStatement(clearCartQuery);
            clearPs.setInt(1, cartId);
            clearPs.executeUpdate();

            conn.commit(); // success

            return true;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public List<Order> getOrdersByUserId(int userId) {

        List<Order> orders = new ArrayList<>();
        String query = "SELECT * FROM orders WHERE user_id = ? ORDER BY order_date DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Order order = new Order();

                order.setId(rs.getInt("id"));
                order.setUserId(rs.getInt("user_id"));
                order.setTotalAmount(rs.getDouble("total_amount"));
                order.setOrderDate(rs.getTimestamp("order_date"));
                order.setStatus(rs.getString("status"));
                order.setPaymentMethod(rs.getString("payment_method"));

                orders.add(order);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return orders;
    }

    @Override
    public Order getOrderById(int orderId) {

        Order order = null;
        String query = "SELECT * FROM orders WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                order = new Order();

                order.setId(rs.getInt("id"));
                order.setUserId(rs.getInt("user_id"));
                order.setTotalAmount(rs.getDouble("total_amount"));
                order.setOrderDate(rs.getTimestamp("order_date"));
                order.setStatus(rs.getString("status"));
                order.setPaymentMethod(rs.getString("payment_method"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return order;
    }

    @Override
    public List<OrderItem> getOrderItemsByOrderId(int orderId) {

        List<OrderItem> items = new ArrayList<>();
        String query = "SELECT * FROM order_items WHERE order_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                OrderItem item = new OrderItem();

                item.setId(rs.getInt("id"));
                item.setOrderId(rs.getInt("order_id"));
                item.setProductId(rs.getInt("product_id"));
                item.setVariantId(rs.getInt("variant_id"));
                item.setQuantity(rs.getInt("quantity"));
                item.setPrice(rs.getDouble("price"));

                items.add(item);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return items;
    }
    
    @Override
    public boolean cancelOrder(int orderId, int userId) {

        String query = "UPDATE orders SET status = 'CANCELLED' " +
                       "WHERE id = ? AND user_id = ? AND status = 'PLACED'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setInt(1, orderId);
            ps.setInt(2, userId);

            int rows = ps.executeUpdate();

            System.out.println("Rows updated = " + rows); // debug

            return rows > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}