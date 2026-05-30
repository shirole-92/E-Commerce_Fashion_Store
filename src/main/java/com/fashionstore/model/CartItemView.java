package com.fashionstore.model;

public class CartItemView {

    private final CartItem item;
    private final Product  product;
    private final String   size;
    private final double   itemTotal;

    public CartItemView(CartItem item, Product product, String size, double itemTotal) {
        this.item      = item;
        this.product   = product;
        this.size      = size;
        this.itemTotal = itemTotal;
    }

    public CartItem getItem()      { return item; }
    public Product  getProduct()   { return product; }
    public String   getSize()      { return size; }
    public double   getItemTotal() { return itemTotal; }
}
