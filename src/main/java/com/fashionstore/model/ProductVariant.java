package com.fashionstore.model;

public class ProductVariant {

    private int id;
    private int productId;
    private String size;
    private int stock;

    // Default Constructor
    public ProductVariant() {
    }

    // Parameterized Constructor
    public ProductVariant(int id, int productId, String size, int stock) {
        this.id = id;
        this.productId = productId;
        this.size = size;
        this.stock = stock;
    }

    // Getters and Setters

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getSize() {
        return size;
    }

    public void setSize(String size) {
        this.size = size;
    }

    public int getStock() {
        return stock;
    }

    public void setStock(int stock) {
        this.stock = stock;
    }
}
