package com.fashionstore.dao;

import java.util.List;

import com.fashionstore.model.Category;

public interface CategoryDAO {

    // Get all categories (for filter/menu)
    List<Category> getAllCategories();

    // Get category by ID
    Category getCategoryById(int categoryId);
}