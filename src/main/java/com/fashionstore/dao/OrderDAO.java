package com.fashionstore.dao;

import java.util.List;

import com.fashionstore.model.Order;
import com.fashionstore.model.OrderItem;

public interface OrderDAO {

    // Place order (create order + order items)
    boolean placeOrder(int userId, String paymentMethod);

    // Get all orders for a user (My Orders page)
    List<Order> getOrdersByUserId(int userId);

    // Get single order by ID
    Order getOrderById(int orderId);

    // Get order items for a specific order (Order Details page)
    List<OrderItem> getOrderItemsByOrderId(int orderId);

    // Cancel order (only if status is PLACED)
    boolean cancelOrder(int orderId, int userId);
}