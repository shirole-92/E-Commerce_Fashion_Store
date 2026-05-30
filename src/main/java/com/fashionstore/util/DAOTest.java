package com.fashionstore.util;

import java.util.List;

import com.fashionstore.dao.CartDAO;
import com.fashionstore.dao.CategoryDAO;
import com.fashionstore.dao.OrderDAO;
import com.fashionstore.dao.ProductDAO;
import com.fashionstore.dao.UserDAO;
import com.fashionstore.dao.impl.CartDAOImpl;
import com.fashionstore.dao.impl.CategoryDAOImpl;
import com.fashionstore.dao.impl.OrderDAOImpl;
import com.fashionstore.dao.impl.ProductDAOImpl;
import com.fashionstore.dao.impl.UserDAOImpl;
import com.fashionstore.model.CartItem;
import com.fashionstore.model.Category;
import com.fashionstore.model.Order;
import com.fashionstore.model.Product;
import com.fashionstore.model.User;

public class DAOTest {

    public static void main(String[] args) {

        // ===== ProductDAO Test =====
        ProductDAO productDAO = new ProductDAOImpl();
        List<Product> products = productDAO.getAllProducts();

        System.out.println("---- Products ----");
        for (Product p : products) {
            System.out.println(p.getId() + " - " + p.getName() + " - " + p.getPrice());
        }

        // ===== CategoryDAO Test =====
        CategoryDAO categoryDAO = new CategoryDAOImpl();
        List<Category> categories = categoryDAO.getAllCategories();

        System.out.println("\n---- Categories ----");
        for (Category c : categories) {
            System.out.println(c.getId() + " - " + c.getName());
        }

        // ===== UserDAO Test (Fetch only) =====
        UserDAO userDAO = new UserDAOImpl();
        User user = userDAO.getUserById(1); // make sure ID exists

        System.out.println("\n---- User ----");
        if (user != null) {
            System.out.println(user.getName() + " - " + user.getEmail());
        } else {
            System.out.println("User not found");
        }

        // ===== CartDAO Test =====
        CartDAO cartDAO = new CartDAOImpl();

        System.out.println("\n---- Cart Items ----");
        List<CartItem> cartItems = cartDAO.getCartItemsByUserId(1); // ensure user exists

        for (CartItem item : cartItems) {
            System.out.println("Product: " + item.getProductId() +
                               " Variant: " + item.getVariantId() +
                               " Qty: " + item.getQuantity());
        }

        // ===== OrderDAO Test =====
        OrderDAO orderDAO = new OrderDAOImpl();

        System.out.println("\n---- Orders ----");
        List<Order> orders = orderDAO.getOrdersByUserId(1);

        for (Order o : orders) {
            System.out.println("Order ID: " + o.getId() +
                               " Total: " + o.getTotalAmount() +
                               " Status: " + o.getStatus());
        }

        System.out.println("\n✅ DAO Testing Completed");
    }
}