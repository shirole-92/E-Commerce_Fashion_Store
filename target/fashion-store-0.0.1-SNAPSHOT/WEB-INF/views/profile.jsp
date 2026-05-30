<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.fashionstore.model.User" %>
<%
    User user = (User) request.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/user?action=login"); return; }
    String[] nameParts = user.getName().trim().split("\\s+");
    String initials = nameParts.length >= 2
        ? String.valueOf(nameParts[0].charAt(0)) + String.valueOf(nameParts[nameParts.length-1].charAt(0))
        : String.valueOf(nameParts[0].charAt(0));
    initials = initials.toUpperCase();
    int cartCount = request.getAttribute("cartCount") != null ? (int) request.getAttribute("cartCount") : 0;
    boolean hasSuccess = request.getAttribute("success") != null;
    boolean hasError   = request.getAttribute("error") != null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Account — FashionStore</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/toast.css">
  <% if (hasSuccess) { %>
    <meta name="toast-message" content="Profile updated successfully!" data-type="success">
  <% } %>
  <% if (hasError) { %>
    <meta name="toast-message" content="${error}" data-type="error">
  <% } %>
</head>
<body>
<nav class="top-nav">
  <a href="${pageContext.request.contextPath}/products" class="nav-logo">FASHION<span>.</span></a>
  <ul class="nav-links">
    <li><a href="${pageContext.request.contextPath}/products">Shop</a></li>
    <li><a href="${pageContext.request.contextPath}/order?action=myOrders">Orders</a></li>
    <li><a href="${pageContext.request.contextPath}/user?action=profile" class="active">Account</a></li>
    <li><a href="${pageContext.request.contextPath}/cart" class="nav-cart">Cart<% if (cartCount > 0) { %><span class="nav-cart-badge"><%= cartCount %></span><% } %></a></li>
    <li><a href="${pageContext.request.contextPath}/user?action=logout">Sign out</a></li>
  </ul>
</nav>
<div class="main-with-nav">
  <div class="profile-wrapper">
    <div class="profile-header">
      <div class="profile-header-left">
        <p class="eyebrow">My Account</p>
        <h1><%= user.getName() %></h1>
      </div>
      <div class="profile-avatar"><%= initials %></div>
    </div>

    <form action="${pageContext.request.contextPath}/user" method="post" novalidate>
      <input type="hidden" name="action" value="updateProfile">
      <div class="profile-grid">
        <div class="profile-card">
          <p class="profile-card-title">Personal Information</p>
          <div class="form-group">
            <label for="name">Full name</label>
            <input type="text" id="name" name="name" value="<%= user.getName() %>" required>
          </div>
          <div class="form-group">
            <label for="email">Email address</label>
            <input type="email" id="email" name="email" value="<%= user.getEmail() %>" required>
          </div>
          <div class="form-group">
            <label for="password">New password</label>
            <input type="password" id="password" name="password" placeholder="Leave blank to keep current" autocomplete="new-password">
          </div>
        </div>
        <div class="profile-card">
          <p class="profile-card-title">Delivery Address</p>
          <div class="form-group">
            <label for="addressLine">Street address</label>
            <input type="text" id="addressLine" name="addressLine" value="<%= user.getAddressLine() != null ? user.getAddressLine() : "" %>" placeholder="123, MG Road">
          </div>
          <div class="form-row">
            <div class="form-group">
              <label for="city">City</label>
              <input type="text" id="city" name="city" value="<%= user.getCity() != null ? user.getCity() : "" %>" placeholder="Bengaluru">
            </div>
            <div class="form-group">
              <label for="state">State</label>
              <input type="text" id="state" name="state" value="<%= user.getState() != null ? user.getState() : "" %>" placeholder="Karnataka">
            </div>
          </div>
          <div class="form-group">
            <label for="pincode">Pincode</label>
            <input type="text" id="pincode" name="pincode" value="<%= user.getPincode() != null ? user.getPincode() : "" %>" placeholder="560001" maxlength="6">
          </div>
        </div>
        <div class="profile-card profile-card--full" style="padding:24px 32px;display:flex;align-items:center;justify-content:space-between;">
          <p style="font-size:12px;color:var(--muted);">Changes saved here update your account and delivery address.</p>
          <button type="submit" class="btn-primary" style="width:auto;padding:14px 40px;white-space:nowrap;">Save Changes</button>
        </div>
      </div>
    </form>

    <div class="divider"></div>
    <div style="display:flex;gap:16px;flex-wrap:wrap;">
      <a href="${pageContext.request.contextPath}/order?action=myOrders" class="btn-secondary" style="width:auto;padding:12px 32px;">View Orders</a>
      <a href="${pageContext.request.contextPath}/products" class="btn-secondary" style="width:auto;padding:12px 32px;">Continue Shopping</a>
      <a href="${pageContext.request.contextPath}/user?action=logout" class="btn-secondary" style="width:auto;padding:12px 32px;border-color:var(--danger);color:var(--danger);">Sign Out</a>
    </div>
  </div>
</div>
<script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
</body>
</html>
