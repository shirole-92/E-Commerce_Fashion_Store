package com.fashionstore.controller;

import java.io.IOException;
import java.util.List;

import com.fashionstore.dao.CartDAO;
import com.fashionstore.dao.CategoryDAO;
import com.fashionstore.dao.ProductDAO;
import com.fashionstore.dao.impl.CartDAOImpl;
import com.fashionstore.dao.impl.CategoryDAOImpl;
import com.fashionstore.dao.impl.ProductDAOImpl;
import com.fashionstore.model.Product;
import com.fashionstore.model.ProductVariant;
import com.fashionstore.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/product-details")
public class ProductDetailServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private ProductDAO  productDAO  = new ProductDAOImpl();
    private CartDAO     cartDAO     = new CartDAOImpl();
    private CategoryDAO categoryDAO = new CategoryDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");

        // Validate product ID
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/products");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/products");
            return;
        }

        // Load product
        Product product = productDAO.getProductById(productId);

        if (product == null) {
            request.setAttribute("error", "Product not found.");
            response.sendRedirect(request.getContextPath() + "/products");
            return;
        }

        // Load variants (sizes + stock)
        List<ProductVariant> variants = productDAO.getVariantsByProductId(productId);

        // Load related products (same category, exclude current)
        List<Product> allInCategory = productDAO.getProductsByCategory(product.getCategoryId());
        allInCategory.removeIf(p -> p.getId() == productId);

        // Limit related to 4
        List<Product> related = allInCategory.size() > 4
                ? allInCategory.subList(0, 4)
                : allInCategory;

        // Cart count for nav badge
        User user = (User) request.getSession().getAttribute("user");
        if (user != null) {
            int count = cartDAO.getCartItemsByUserId(user.getId()).size();
            request.setAttribute("cartCount", count);
        }

        // Category name for breadcrumb
        String categoryName = "Unknown";
        if (product.getCategoryId() == 1)      categoryName = "Men";
        else if (product.getCategoryId() == 2) categoryName = "Women";

        request.setAttribute("product",      product);
        request.setAttribute("variants",     variants);
        request.setAttribute("related",      related);
        request.setAttribute("categoryName", categoryName);

        request.getRequestDispatcher("/WEB-INF/views/product-details.jsp")
               .forward(request, response);
    }

    // -------------------------------------------------------
    // POST — Add to cart
    // -------------------------------------------------------
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Must be logged in
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user?action=login");
            return;
        }

        String productIdParam = request.getParameter("productId");
        String variantIdParam = request.getParameter("variantId");
        String quantityParam  = request.getParameter("quantity");

        // Validate params
        if (productIdParam == null || variantIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/products");
            return;
        }

        try {
            int productId = Integer.parseInt(productIdParam.trim());
            int variantId = Integer.parseInt(variantIdParam.trim());
            int quantity  = (quantityParam != null && !quantityParam.isEmpty())
                    ? Integer.parseInt(quantityParam.trim()) : 1;

            if (quantity < 1) quantity = 1;

            boolean success = cartDAO.addToCart(user.getId(), productId, variantId, quantity);

            if (success) {
                // Redirect to cart after adding
                response.sendRedirect(request.getContextPath() + "/cart?added=true");
            } else {
                // Redirect back to product page with error
                response.sendRedirect(request.getContextPath()
                        + "/product-details?id=" + productId + "&error=cart");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/products");
        }
    }
}
