package com.fashionstore.dao.impl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.fashionstore.dao.ProductDAO;
import com.fashionstore.model.Product;
import com.fashionstore.model.ProductVariant;
import com.fashionstore.util.DBConnection;

public class ProductDAOImpl implements ProductDAO {

    // ── Resolve sort parameter to safe SQL ORDER BY ──
    private String resolveOrderBy(String sortBy) {
        if (sortBy == null) return "id ASC";
        switch (sortBy) {
            case "price_asc":  return "price ASC";
            case "price_desc": return "price DESC";
            case "name_asc":   return "name ASC";
            case "name_desc":  return "name DESC";
            case "newest":     return "id DESC";
            default:           return "id ASC";
        }
    }

    @Override
    public List<Product> getAllProducts() {
        return getAllProductsSorted(null);
    }

    @Override
    public List<Product> getAllProductsSorted(String sortBy) {

        List<Product> products = new ArrayList<>();
        String query = "SELECT * FROM products ORDER BY " + resolveOrderBy(sortBy);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                products.add(mapProduct(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return products;
    }

    @Override
    public Product getProductById(int productId) {

        Product product = null;
        String query = "SELECT * FROM products WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setInt(1, productId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                product = mapProduct(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return product;
    }

    @Override
    public List<Product> getProductsByCategory(int categoryId) {

        List<Product> products = new ArrayList<>();
        String query = "SELECT * FROM products WHERE category_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setInt(1, categoryId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                products.add(mapProduct(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return products;
    }

    @Override
    public List<Product> searchProducts(String keyword) {

        List<Product> products = new ArrayList<>();
        String query = "SELECT * FROM products WHERE name LIKE ? OR description LIKE ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, "%" + keyword + "%");
            ps.setString(2, "%" + keyword + "%");
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                products.add(mapProduct(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return products;
    }

    @Override
    public List<Product> filterProducts(Integer categoryId, String keyword, String sortBy) {

        List<Product> products = new ArrayList<>();
        StringBuilder query = new StringBuilder("SELECT * FROM products WHERE 1=1");

        if (categoryId != null) {
            query.append(" AND category_id = ?");
        }

        if (keyword != null && !keyword.isEmpty()) {
            query.append(" AND (name LIKE ? OR description LIKE ?)");
        }

        query.append(" ORDER BY ").append(resolveOrderBy(sortBy));

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query.toString())) {

            int index = 1;

            if (categoryId != null) {
                ps.setInt(index++, categoryId);
            }

            if (keyword != null && !keyword.isEmpty()) {
                ps.setString(index++, "%" + keyword + "%");
                ps.setString(index++, "%" + keyword + "%");
            }

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                products.add(mapProduct(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return products;
    }

    @Override
    public List<ProductVariant> getVariantsByProductId(int productId) {

        List<ProductVariant> variants = new ArrayList<>();
        String query = "SELECT * FROM product_variants WHERE product_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setInt(1, productId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                ProductVariant variant = new ProductVariant();
                variant.setId(rs.getInt("id"));
                variant.setProductId(rs.getInt("product_id"));
                variant.setSize(rs.getString("size"));
                variant.setStock(rs.getInt("stock"));

                variants.add(variant);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return variants;
    }

    // ── Helper to map ResultSet → Product ──
    private Product mapProduct(ResultSet rs) throws Exception {
        Product product = new Product();
        product.setId(rs.getInt("id"));
        product.setName(rs.getString("name"));
        product.setDescription(rs.getString("description"));
        product.setPrice(rs.getDouble("price"));
        product.setCategoryId(rs.getInt("category_id"));
        product.setImageUrl(rs.getString("image_url"));
        return product;
    }
}
