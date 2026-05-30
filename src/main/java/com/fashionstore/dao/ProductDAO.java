package com.fashionstore.dao;

import java.util.List;

import com.fashionstore.model.Product;
import com.fashionstore.model.ProductVariant;

public interface ProductDAO {

    // Get all products
    List<Product> getAllProducts();

    // Get all products with sorting
    List<Product> getAllProductsSorted(String sortBy);

    // Get product by ID (for product details page)
    Product getProductById(int productId);

    // Get products by category (Men / Women filter)
    List<Product> getProductsByCategory(int categoryId);

    // Search products (e.g., "black t-shirt")
    List<Product> searchProducts(String keyword);

    // Combined filter + search + sort
    List<Product> filterProducts(Integer categoryId, String keyword, String sortBy);

    // Get variants (sizes) for a product
    List<ProductVariant> getVariantsByProductId(int productId);
}
