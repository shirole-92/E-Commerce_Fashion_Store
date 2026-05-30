package com.fashionstore.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.fashionstore.dao.CartDAO;
import com.fashionstore.dao.ProductDAO;
import com.fashionstore.dao.impl.CartDAOImpl;
import com.fashionstore.dao.impl.ProductDAOImpl;
import com.fashionstore.model.CartItem;
import com.fashionstore.model.CartItemView;
import com.fashionstore.model.Product;
import com.fashionstore.model.ProductVariant;
import com.fashionstore.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

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

        List<CartItem> cartItems = cartDAO.getCartItemsByUserId(user.getId());

        List<CartItemView> viewItems = new ArrayList<>();
        double totalAmount = 0;

        for (CartItem item : cartItems) {
            Product product = productDAO.getProductById(item.getProductId());
            List<ProductVariant> variants = productDAO.getVariantsByProductId(item.getProductId());

            String size = "N/A";
            for (ProductVariant v : variants) {
                if (v.getId() == item.getVariantId()) {
                    size = v.getSize();
                    break;
                }
            }

            if (product != null) {
                double itemTotal = product.getPrice() * item.getQuantity();
                totalAmount += itemTotal;
                viewItems.add(new CartItemView(item, product, size, itemTotal));
            }
        }

        request.setAttribute("cartItems",   viewItems);
        request.setAttribute("totalAmount", totalAmount);
        request.setAttribute("cartCount",   cartItems.size());

        if ("true".equals(request.getParameter("added"))) {
            request.setAttribute("successMsg", "Item added to your cart.");
        }

        request.getRequestDispatcher("/WEB-INF/views/cart.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user?action=login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        switch (action) {
            case "update": handleUpdate(request, response); break;
            case "remove": handleRemove(request, response); break;
            default: response.sendRedirect(request.getContextPath() + "/cart"); break;
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int cartItemId = Integer.parseInt(request.getParameter("cartItemId").trim());
            int quantity   = Integer.parseInt(request.getParameter("quantity").trim());
            if (quantity < 1)  quantity = 1;
            if (quantity > 10) quantity = 10;
            cartDAO.updateCartItemQuantity(cartItemId, quantity);
        } catch (NumberFormatException e) { /* ignore */ }
        response.sendRedirect(request.getContextPath() + "/cart");
    }

    private void handleRemove(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int cartItemId = Integer.parseInt(request.getParameter("cartItemId").trim());
            cartDAO.removeCartItem(cartItemId);
        } catch (NumberFormatException e) { /* ignore */ }
        response.sendRedirect(request.getContextPath() + "/cart");
    }
}
