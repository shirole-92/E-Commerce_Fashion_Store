package com.fashionstore.model;

public class OrderItem {

    private int    id;
    private int    orderId;
    private int    productId;
    private int    variantId;
    private int    quantity;
    private double price;

    // Enriched fields (not in DB — set by OrderServlet)
    private String productName;
    private String productImage;
    private int    categoryId;

    // ── Getters & Setters ──

    public int    getId()           { return id; }
    public void   setId(int id)     { this.id = id; }

    public int    getOrderId()              { return orderId; }
    public void   setOrderId(int orderId)   { this.orderId = orderId; }

    public int    getProductId()                { return productId; }
    public void   setProductId(int productId)   { this.productId = productId; }

    public int    getVariantId()                { return variantId; }
    public void   setVariantId(int variantId)   { this.variantId = variantId; }

    public int    getQuantity()               { return quantity; }
    public void   setQuantity(int quantity)   { this.quantity = quantity; }

    public double getPrice()              { return price; }
    public void   setPrice(double price)  { this.price = price; }

    public String getProductName()                    { return productName; }
    public void   setProductName(String productName)  { this.productName = productName; }

    public String getProductImage()                     { return productImage; }
    public void   setProductImage(String productImage)  { this.productImage = productImage; }

    public int    getCategoryId()                 { return categoryId; }
    public void   setCategoryId(int categoryId)   { this.categoryId = categoryId; }
}
