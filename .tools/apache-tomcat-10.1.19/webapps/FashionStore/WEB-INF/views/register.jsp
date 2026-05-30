<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Create Account — FashionStore</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth.css">
</head>
<body>

<div class="auth-wrapper">

  <!-- ── Left: Visual Panel ── -->
  <div class="auth-panel auth-panel--visual">
    <div class="visual-content">
      <div class="visual-logo">FASHION<span>.</span></div>
      <p class="visual-tagline">Your Style &nbsp;·&nbsp; Your Story</p>

      <div class="visual-accent"></div>

      <div class="visual-lines">
        <div class="visual-line active">Explore</div>
        <div class="visual-line">Collect</div>
        <div class="visual-line">Express</div>
      </div>
    </div>
  </div>

  <!-- ── Right: Form Panel ── -->
  <div class="auth-panel auth-panel--form">
    <div class="auth-form-container" style="max-width:480px;">

      <p class="auth-subheading" style="margin-bottom:32px; letter-spacing:3px;">
        FASHION<span style="color:var(--gold);">STORE</span>
      </p>

      <h1 class="auth-heading">Create<br>account.</h1>
      <p class="auth-subheading">
        Already have one?
        <a href="${pageContext.request.contextPath}/user?action=login">Sign in</a>
      </p>

      <!-- Error alert -->
      <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-error">${error}</div>
      <% } %>

      <form action="${pageContext.request.contextPath}/user" method="post" novalidate>
        <input type="hidden" name="action" value="register">

        <!-- Account details -->
        <div class="form-section-label">Account</div>

        <div class="form-group">
          <label for="name">Full name</label>
          <input
            type="text"
            id="name"
            name="name"
            placeholder="Jane Doe"
            required
            autocomplete="name"
          >
        </div>

        <div class="form-row">
          <div class="form-group">
            <label for="email">Email address</label>
            <input
              type="email"
              id="email"
              name="email"
              placeholder="you@example.com"
              value="${emailValue}"
              required
              autocomplete="email"
            >
          </div>
          <div class="form-group">
            <label for="password">Password</label>
            <input
              type="password"
              id="password"
              name="password"
              placeholder="Min. 6 characters"
              required
              autocomplete="new-password"
            >
          </div>
        </div>

        <!-- Delivery address -->
        <div class="form-section-label">Delivery address</div>

        <div class="form-group">
          <label for="addressLine">Street address</label>
          <input
            type="text"
            id="addressLine"
            name="addressLine"
            placeholder="123, MG Road"
            autocomplete="street-address"
          >
        </div>

        <div class="form-row">
          <div class="form-group">
            <label for="city">City</label>
            <input
              type="text"
              id="city"
              name="city"
              placeholder="Bengaluru"
              autocomplete="address-level2"
            >
          </div>
          <div class="form-group">
            <label for="state">State</label>
            <input
              type="text"
              id="state"
              name="state"
              placeholder="Karnataka"
              autocomplete="address-level1"
            >
          </div>
        </div>

        <div class="form-group">
          <label for="pincode">Pincode</label>
          <input
            type="text"
            id="pincode"
            name="pincode"
            placeholder="560001"
            maxlength="6"
            autocomplete="postal-code"
          >
        </div>

        <button type="submit" class="btn-primary">Create Account</button>
      </form>

    </div>
  </div>

</div>

<script>
  const lines = document.querySelectorAll('.visual-line');
  let current = 0;
  setInterval(() => {
    lines.forEach(l => l.classList.remove('active'));
    current = (current + 1) % lines.length;
    lines[current].classList.add('active');
  }, 2000);
</script>

</body>
</html>
