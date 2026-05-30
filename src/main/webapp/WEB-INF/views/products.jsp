<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.fashionstore.model.Product" %>
<%@ page import="com.fashionstore.model.User" %>
<%
    List<Product> products = (List<Product>) request.getAttribute("products");
    User user = (User) session.getAttribute("user");
    int cartCount = request.getAttribute("cartCount") != null ? (int) request.getAttribute("cartCount") : 0;
    String keyword = request.getParameter("search");
    String categoryId = request.getParameter("categoryId");
    if (keyword == null) keyword = "";
    if (categoryId == null) categoryId = "";
    int productCount = (products != null) ? products.size() : 0;
    String activeLabel = "All Products";
    if ("1".equals(categoryId)) activeLabel = "Men";
    else if ("2".equals(categoryId)) activeLabel = "Women";
    else if ("4".equals(categoryId)) activeLabel = "Kids";
    else if (!keyword.isEmpty()) activeLabel = "Search: " + keyword;
    String sortBy = request.getAttribute("sortBy") != null ? (String) request.getAttribute("sortBy") : "newest";
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= activeLabel %> — FashionStore</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/products.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/toast.css">
</head>
<body>
<nav class="top-nav">
  <a href="${pageContext.request.contextPath}/index.jsp" class="nav-logo">FASHION<span>.</span></a>
  <form class="nav-search-form" action="${pageContext.request.contextPath}/products" method="get">
    <input class="nav-search-input" type="text" name="search" placeholder="Search products..." value="<%= keyword %>" autocomplete="off">
    <button class="nav-search-btn" type="submit">&#8981;</button>
  </form>
  <ul class="nav-links">
    <% if (user != null) { %>
      <li><a href="${pageContext.request.contextPath}/user?action=profile"><%= user.getName().split(" ")[0] %></a></li>
      <li><a href="${pageContext.request.contextPath}/order?action=myOrders">Orders</a></li>
      <li><a href="${pageContext.request.contextPath}/cart" class="nav-cart">Cart<% if (cartCount > 0) { %><span class="nav-cart-badge"><%= cartCount %></span><% } %></a></li>
      <li><a href="${pageContext.request.contextPath}/user?action=logout">Sign out</a></li>
    <% } else { %>
      <li><a href="${pageContext.request.contextPath}/user?action=login">Sign in</a></li>
      <li><a href="${pageContext.request.contextPath}/user?action=register">Register</a></li>
    <% } %>
  </ul>
</nav>
<div class="page-body">
  <div class="hero-strip">
    <div class="hero-text">
      <p class="hero-eyebrow">New Collection · 2026</p>
      <h1 class="hero-title"><%= activeLabel %></h1>
      <p class="hero-count"><%= productCount %> <%= productCount == 1 ? "piece" : "pieces" %></p>
    </div>
  </div>
  <div class="filter-bar">
    <a href="${pageContext.request.contextPath}/products" class="filter-link <%= categoryId.isEmpty() && keyword.isEmpty() ? "active" : "" %>">All</a>
    <div class="filter-divider"></div>
    <a href="${pageContext.request.contextPath}/products?categoryId=1" class="filter-link <%= "1".equals(categoryId) ? "active" : "" %>">Men</a>
    <div class="filter-divider"></div>
    <a href="${pageContext.request.contextPath}/products?categoryId=2" class="filter-link <%= "2".equals(categoryId) ? "active" : "" %>">Women</a>
    <div class="filter-divider"></div>
    <a href="${pageContext.request.contextPath}/products?categoryId=4" class="filter-link <%= "4".equals(categoryId) ? "active" : "" %>">Kids</a>
    <% if (!keyword.isEmpty()) { %>
      <div class="filter-divider"></div>
      <span class="filter-link active">&ldquo;<%= keyword %>&rdquo;&nbsp;<a href="${pageContext.request.contextPath}/products" style="color:var(--muted);font-size:10px;text-decoration:none;">✕</a></span>
    <% } %>

    <!-- Sort dropdown -->
    <div style="margin-left:auto; display:flex; align-items:center; padding-right:24px;">
      <form id="sortForm" action="${pageContext.request.contextPath}/products" method="get" style="display:flex;align-items:center;gap:10px;">
        <% if (!categoryId.isEmpty()) { %>
          <input type="hidden" name="categoryId" value="<%= categoryId %>">
        <% } %>
        <% if (!keyword.isEmpty()) { %>
          <input type="hidden" name="search" value="<%= keyword %>">
        <% } %>
        <label style="font-size:10px;letter-spacing:2px;text-transform:uppercase;color:var(--muted);font-weight:500;">Sort</label>
        <select name="sort" onchange="document.getElementById('sortForm').submit()"
                style="background:var(--graphite);border:1px solid var(--border);color:var(--light);font-family:'Barlow',sans-serif;font-size:11px;padding:6px 12px;border-radius:2px;cursor:pointer;outline:none;">
          <option value="newest"     <%= "newest".equals(sortBy)     ? "selected" : "" %>>Newest</option>
          <option value="price_asc"  <%= "price_asc".equals(sortBy)  ? "selected" : "" %>>Price: Low to High</option>
          <option value="price_desc" <%= "price_desc".equals(sortBy) ? "selected" : "" %>>Price: High to Low</option>
          <option value="name_asc"   <%= "name_asc".equals(sortBy)   ? "selected" : "" %>>Name: A to Z</option>
          <option value="name_desc"  <%= "name_desc".equals(sortBy)  ? "selected" : "" %>>Name: Z to A</option>
        </select>
      </form>
    </div>
  </div>
  <div class="shop-layout">
    <div class="product-grid">
      <% if (products != null && !products.isEmpty()) { for (Product p : products) { %>
        <div class="product-card">
          <div class="card-img-wrap">
            <% if (p.getImageUrl() != null && !p.getImageUrl().isEmpty()) { %>
              <img class="product-img" src="${pageContext.request.contextPath}<%= p.getImageUrl() %>" alt="<%= p.getName() %>" loading="lazy">
            <% } else { %>
              <div class="product-img-placeholder">
                <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21,15 16,10 5,21"/></svg>
              </div>
            <% } %>
          </div>
          <div class="card-body">
            <p class="product-category-tag"><%= "1".equals(String.valueOf(p.getCategoryId())) ? "Men" : "2".equals(String.valueOf(p.getCategoryId())) ? "Women" : "Kids" %></p>
            <h3 class="product-name"><%= p.getName() %></h3>
            <p class="product-price">&#8377;<%= String.format("%.0f", p.getPrice()) %></p>
          </div>
          <div class="card-actions">
            <a href="${pageContext.request.contextPath}/product-details?id=<%= p.getId() %>" class="btn-view">View Details</a>
          </div>
        </div>
      <% } } else { %>
        <div class="empty-state">
          <div class="empty-state-icon"><svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="0.8"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg></div>
          <h3>Nothing found</h3>
          <p>We couldn't find any products matching your criteria.</p>
          <a href="${pageContext.request.contextPath}/products">Browse all products</a>
        </div>
      <% } %>
    </div>
  </div>
  <footer class="site-footer">
    <div class="footer-logo">FASHION<span>.</span></div>
    <p class="footer-note">&copy; 2025 FashionStore. All rights reserved.</p>
  </footer>
</div>
<script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
</body>
</html>
