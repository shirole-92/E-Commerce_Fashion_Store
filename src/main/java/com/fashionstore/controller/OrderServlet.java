package com.fashionstore.controller;

import java.io.IOException;
import java.util.List;

import com.fashionstore.dao.OrderDAO;
import com.fashionstore.dao.CartDAO;
import com.fashionstore.dao.ProductDAO;
import com.fashionstore.dao.impl.OrderDAOImpl;
import com.fashionstore.dao.impl.CartDAOImpl;
import com.fashionstore.dao.impl.ProductDAOImpl;
import com.fashionstore.model.Order;
import com.fashionstore.model.OrderItem;
import com.fashionstore.model.Product;
import com.fashionstore.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/order")
public class OrderServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private OrderDAO   orderDAO   = new OrderDAOImpl();
    private CartDAO    cartDAO    = new CartDAOImpl();
    private ProductDAO productDAO = new ProductDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user?action=login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "myOrders";

        switch (action) {
            case "checkout":
                handleCheckout(request, response, user);
                break;

            case "placeOrder":  
                handlePlaceOrder(request, response, user);  
                break;
            case "orderDetail": 
                handleOrderDetail(request, response, user); 
                break;

            case "cancelOrder":  // ✅ ADDED
                handleCancelOrder(request, response, user); 
                break;

            case "myOrders":
            default:            
                handleMyOrders(request, response, user);    
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user?action=login");
            return;
        }

        String action = request.getParameter("action");
        if ("placeOrder".equals(action)) {
            handlePlaceOrder(request, response, user);
        } else {
            doGet(request, response);
        }
    }

    // ================= CHECKOUT =================
    private void handleCheckout(HttpServletRequest request, HttpServletResponse response, User user) throws ServletException, IOException {
        List<com.fashionstore.model.CartItem> items = cartDAO.getCartItemsByUserId(user.getId());
        if (items == null || items.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        List<com.fashionstore.model.CartItemView> cartItems = new java.util.ArrayList<>();
        double totalAmount = 0;

        for (com.fashionstore.model.CartItem item : items) {
            com.fashionstore.model.Product product = productDAO.getProductById(item.getProductId());
            java.util.List<com.fashionstore.model.ProductVariant> variants = productDAO.getVariantsByProductId(item.getProductId());

            String size = "N/A";
            for (com.fashionstore.model.ProductVariant v : variants) {
                if (v.getId() == item.getVariantId()) {
                    size = v.getSize();
                    break;
                }
            }

            if (product != null) {
                double itemTotal = product.getPrice() * item.getQuantity();
                totalAmount += itemTotal;
                cartItems.add(new com.fashionstore.model.CartItemView(item, product, size, itemTotal));
            }
        }

        request.setAttribute("cartItems", cartItems);
        request.setAttribute("totalAmount", totalAmount);
        request.setAttribute("cartCount", cartItems.size());

        request.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(request, response);
    }

    // ================= PLACE ORDER =================
    private void handlePlaceOrder(HttpServletRequest request,
                                 HttpServletResponse response, User user)
            throws IOException {

        String paymentMethod = request.getParameter("paymentMethod");
        if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
            paymentMethod = "Cash on Delivery";
        }

        int cartSize = cartDAO.getCartItemsByUserId(user.getId()).size();

        if (cartSize == 0) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        boolean success = orderDAO.placeOrder(user.getId(), paymentMethod);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/order?action=myOrders&placed=true");
        } else {
            response.sendRedirect(request.getContextPath() + "/cart?error=orderFailed");
        }
    }

    // ================= MY ORDERS =================
    private void handleMyOrders(HttpServletRequest request,
                               HttpServletResponse response, User user)
            throws ServletException, IOException {

        List<Order> orders = orderDAO.getOrdersByUserId(user.getId());
        request.setAttribute("orders", orders);

        if ("true".equals(request.getParameter("placed"))) {
            request.setAttribute("successMsg", "Your order has been placed successfully!");
        }

        if ("true".equals(request.getParameter("cancelled"))) {
            request.setAttribute("successMsg", "Order cancelled successfully!");
        }

        request.getRequestDispatcher("/WEB-INF/views/orders.jsp")
               .forward(request, response);
    }

    // ================= ORDER DETAIL =================
    private void handleOrderDetail(HttpServletRequest request,
                                   HttpServletResponse response, User user)
            throws ServletException, IOException {

        String orderIdParam = request.getParameter("orderId");

        if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/order?action=myOrders");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdParam.trim());

            Order order = orderDAO.getOrderById(orderId);

            if (order == null || order.getUserId() != user.getId()) {
                response.sendRedirect(request.getContextPath() + "/order?action=myOrders");
                return;
            }

            List<OrderItem> orderItems = orderDAO.getOrderItemsByOrderId(orderId);

            for (OrderItem item : orderItems) {
                Product product = productDAO.getProductById(item.getProductId());
                if (product != null) {
                    item.setProductName(product.getName());
                    item.setProductImage(product.getImageUrl());
                    item.setCategoryId(product.getCategoryId());
                }
            }

            request.setAttribute("order", order);
            request.setAttribute("orderItems", orderItems);

            request.getRequestDispatcher("/WEB-INF/views/order-detail.jsp")
                   .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/order?action=myOrders");
        }
    }

    // ================= CANCEL ORDER =================
    private void handleCancelOrder(HttpServletRequest request,
                                   HttpServletResponse response, User user)
            throws IOException {

        System.out.println("cancelOrder method called!"); // ✅ DEBUG

        String orderIdParam = request.getParameter("orderId");

        if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/order?action=myOrders");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdParam.trim());

            boolean success = orderDAO.cancelOrder(orderId, user.getId());

            if (success) {
                response.sendRedirect(request.getContextPath() + "/order?action=myOrders&cancelled=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/order?action=myOrders&error=cancelFailed");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/order?action=myOrders");
        }
    }
}