package com.fashionstore.dao.impl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.fashionstore.dao.CartDAO;
import com.fashionstore.model.Cart;
import com.fashionstore.model.CartItem;
import com.fashionstore.util.DBConnection;

public class CartDAOImpl implements CartDAO {

    @Override
    public Cart getCartByUserId(int userId) {

        Cart cart = null;
        String query = "SELECT * FROM cart WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                cart = new Cart();
                cart.setId(rs.getInt("id"));
                cart.setUserId(rs.getInt("user_id"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return cart;
    }

    @Override
    public boolean createCart(int userId) {

        String query = "INSERT INTO cart (user_id) VALUES (?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean addToCart(int userId, int productId, int variantId, int quantity) {

        Cart cart = getCartByUserId(userId);

        if (cart == null) {
            createCart(userId);
            cart = getCartByUserId(userId);
        }

        String checkQuery = "SELECT * FROM cart_items WHERE cart_id=? AND product_id=? AND variant_id=?";
        String insertQuery = "INSERT INTO cart_items (cart_id, product_id, variant_id, quantity) VALUES (?, ?, ?, ?)";
        String updateQuery = "UPDATE cart_items SET quantity = quantity + ? WHERE cart_id=? AND product_id=? AND variant_id=?";

        try (Connection conn = DBConnection.getConnection()) {

            PreparedStatement checkPs = conn.prepareStatement(checkQuery);
            checkPs.setInt(1, cart.getId());
            checkPs.setInt(2, productId);
            checkPs.setInt(3, variantId);

            ResultSet rs = checkPs.executeQuery();

            if (rs.next()) {
                PreparedStatement updatePs = conn.prepareStatement(updateQuery);
                updatePs.setInt(1, quantity);
                updatePs.setInt(2, cart.getId());
                updatePs.setInt(3, productId);
                updatePs.setInt(4, variantId);
                return updatePs.executeUpdate() > 0;
            } else {
                PreparedStatement insertPs = conn.prepareStatement(insertQuery);
                insertPs.setInt(1, cart.getId());
                insertPs.setInt(2, productId);
                insertPs.setInt(3, variantId);
                insertPs.setInt(4, quantity);
                return insertPs.executeUpdate() > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public List<CartItem> getCartItemsByUserId(int userId) {

        List<CartItem> items = new ArrayList<>();
        String query = "SELECT ci.* FROM cart_items ci JOIN cart c ON ci.cart_id = c.id WHERE c.user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                CartItem item = new CartItem();

                item.setId(rs.getInt("id"));
                item.setCartId(rs.getInt("cart_id"));
                item.setProductId(rs.getInt("product_id"));
                item.setVariantId(rs.getInt("variant_id"));
                item.setQuantity(rs.getInt("quantity"));

                items.add(item);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return items;
    }

    @Override
    public boolean updateCartItemQuantity(int cartItemId, int quantity) {

        String query = "UPDATE cart_items SET quantity=? WHERE id=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setInt(1, quantity);
            ps.setInt(2, cartItemId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean removeCartItem(int cartItemId) {

        String query = "DELETE FROM cart_items WHERE id=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setInt(1, cartItemId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean clearCart(int userId) {

        String query = "DELETE ci FROM cart_items ci JOIN cart c ON ci.cart_id = c.id WHERE c.user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}