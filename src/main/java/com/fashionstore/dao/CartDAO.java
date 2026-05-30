package com.fashionstore.dao;

import java.util.List;

import com.fashionstore.model.Cart;
import com.fashionstore.model.CartItem;

public interface CartDAO {

    // Get cart by user ID
    Cart getCartByUserId(int userId);

    // Create cart for user (if not exists)
    boolean createCart(int userId);

    // Add item to cart
    boolean addToCart(int userId, int productId, int variantId, int quantity);

    // Get all cart items for a user
    List<CartItem> getCartItemsByUserId(int userId);

    // Update quantity of a cart item
    boolean updateCartItemQuantity(int cartItemId, int quantity);

    // Remove item from cart
    boolean removeCartItem(int cartItemId);

    // Clear cart (after order placed)
    boolean clearCart(int userId);
}
