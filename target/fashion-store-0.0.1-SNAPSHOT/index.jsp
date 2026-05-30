<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.fashionstore.model.User" %>
<%
    User user = (User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>FashionStore — Curated Style</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css?v=2">
</head>
<body>

<!-- ── Nav ── -->
<nav class="top-nav">
  <a href="${pageContext.request.contextPath}/index.jsp" class="nav-logo">FASHION<span>.</span></a>
  <ul class="nav-links">
    <li><a href="${pageContext.request.contextPath}/products">Shop</a></li>
    <li><a href="${pageContext.request.contextPath}/products?categoryId=1">Men</a></li>
    <li><a href="${pageContext.request.contextPath}/products?categoryId=2">Women</a></li>
    <li><a href="${pageContext.request.contextPath}/products?categoryId=4">Kids</a></li>
    <% if (user != null) { %>
      <li><a href="${pageContext.request.contextPath}/order?action=myOrders">Orders</a></li>
      <li><a href="${pageContext.request.contextPath}/cart">Cart</a></li>
      <li><a href="${pageContext.request.contextPath}/user?action=profile"><%= user.getName().split(" ")[0] %></a></li>
    <% } else { %>
      <li><a href="${pageContext.request.contextPath}/user?action=login">Sign in</a></li>
      <li><a href="${pageContext.request.contextPath}/user?action=register" class="nav-register">Register</a></li>
    <% } %>
  </ul>
</nav>

<!-- ── Hero ── -->
<section class="hero">
  <div class="hero-inner">
    <p class="hero-eyebrow">New Collection &nbsp;·&nbsp; 2026</p>
    <h1 class="hero-title">
      Dress for<br>the life you<br><span>want.</span>
    </h1>
    <p class="hero-sub">
      Curated fashion for men and women.<br>
      Premium quality, timeless style.
    </p>
    <div class="hero-actions">
      <a href="${pageContext.request.contextPath}/products" class="btn-primary">
        Shop Collection
      </a>
      <a href="${pageContext.request.contextPath}/products?categoryId=2" class="btn-ghost">
        Women's Edit
      </a>
    </div>
  </div>

  <!-- Decorative grid lines -->
  <div class="hero-grid" aria-hidden="true">
    <div class="grid-line"></div>
    <div class="grid-line"></div>
    <div class="grid-line"></div>
    <div class="grid-line"></div>
  </div>

  <!-- Scroll indicator -->
  <div class="scroll-hint" aria-hidden="true">
    <div class="scroll-line"></div>
    <span>Scroll</span>
  </div>
</section>

<!-- ── Category Split ── -->
<section class="category-split">

  <a href="${pageContext.request.contextPath}/products?categoryId=1" class="cat-panel">
    <div class="cat-bg cat-bg--men"></div>
    <div class="cat-content">
      <p class="cat-label">Men</p>
      <h2 class="cat-title">Sharp.<br>Refined.</h2>
      <span class="cat-link">Explore Men's →</span>
    </div>
  </a>

  <a href="${pageContext.request.contextPath}/products?categoryId=2" class="cat-panel">
    <div class="cat-bg cat-bg--women"></div>
    <div class="cat-content">
      <p class="cat-label">Women</p>
      <h2 class="cat-title">Bold.<br>Effortless.</h2>
      <span class="cat-link">Explore Women's →</span>
    </div>
  </a>

</section>

<!-- ── Value Props ── -->
<section class="props-section">
  <div class="props-grid">
    <div class="prop-item">
      <div class="prop-icon">&#9632;</div>
      <h3 class="prop-title">Premium Quality</h3>
      <p class="prop-desc">Every piece is selected for craftsmanship, fit, and longevity.</p>
    </div>
    <div class="prop-item">
      <div class="prop-icon">&#9632;</div>
      <h3 class="prop-title">Free Delivery</h3>
      <p class="prop-desc">Complimentary shipping on all orders above ₹999.</p>
    </div>
    <div class="prop-item">
      <div class="prop-icon">&#9632;</div>
      <h3 class="prop-title">Easy Returns</h3>
      <p class="prop-desc">Not the right fit? Return within 30 days, no questions asked.</p>
    </div>
    <div class="prop-item">
      <div class="prop-icon">&#9632;</div>
      <h3 class="prop-title">Secure Checkout</h3>
      <p class="prop-desc">Your data and payments are always safe with us.</p>
    </div>
  </div>
</section>

<!-- ── CTA Banner ── -->
<section class="cta-banner">
  <div class="cta-inner">
    <p class="cta-eyebrow">Limited Time</p>
    <h2 class="cta-title">Free delivery on orders above ₹999</h2>
    <a href="${pageContext.request.contextPath}/products" class="btn-primary">
      Shop Now
    </a>
  </div>
</section>

<!-- ── Footer ── -->
<footer class="site-footer">
  <div class="footer-top">
    <div class="footer-brand">
      <div class="footer-logo">FASHION<span>.</span></div>
      <p class="footer-tagline">Curated Style &nbsp;·&nbsp; Premium Quality</p>
    </div>
    <div class="footer-links">
      <div class="footer-col">
        <p class="footer-col-title">Shop</p>
        <a href="${pageContext.request.contextPath}/products">All Products</a>
        <a href="${pageContext.request.contextPath}/products?categoryId=1">Men</a>
        <a href="${pageContext.request.contextPath}/products?categoryId=2">Women</a>
        <a href="${pageContext.request.contextPath}/products?categoryId=4">Kids</a>
      </div>
      <div class="footer-col">
        <p class="footer-col-title">Account</p>
        <% if (user != null) { %>
          <a href="${pageContext.request.contextPath}/user?action=profile">My Profile</a>
          <a href="${pageContext.request.contextPath}/order?action=myOrders">My Orders</a>
          <a href="${pageContext.request.contextPath}/user?action=logout">Sign Out</a>
        <% } else { %>
          <a href="${pageContext.request.contextPath}/user?action=login">Sign In</a>
          <a href="${pageContext.request.contextPath}/user?action=register">Register</a>
        <% } %>
      </div>
    </div>
  </div>
  <div class="footer-bottom">
    <p>&copy; 2026 FashionStore. All rights reserved.</p>
  </div>
</footer>

<script>
  // Scroll indicator fade
  window.addEventListener('scroll', () => {
    const hint = document.querySelector('.scroll-hint');
    if (hint) hint.style.opacity = window.scrollY > 80 ? '0' : '1';
  });
</script>

</body>
</html>
