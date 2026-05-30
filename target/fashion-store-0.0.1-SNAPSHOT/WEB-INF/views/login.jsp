<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Sign In — FashionStore</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth.css">
</head>
<body>

<div class="auth-wrapper">

  <!-- ── Left: Form Panel ── -->
  <div class="auth-panel auth-panel--form">
    <div class="auth-form-container">

      <p class="auth-subheading" style="margin-bottom:32px; letter-spacing:3px;">
        FASHION<span style="color:var(--gold);">STORE</span>
      </p>

      <h1 class="auth-heading">Welcome<br>back.</h1>
      <p class="auth-subheading">
        New here?
        <a href="${pageContext.request.contextPath}/user?action=register">Create an account</a>
      </p>

      <!-- Error alert -->
      <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-error">${error}</div>
      <% } %>

      <form action="${pageContext.request.contextPath}/user" method="post" novalidate>
        <input type="hidden" name="action" value="login">

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
            placeholder="••••••••"
            required
            autocomplete="current-password"
          >
        </div>

        <button type="submit" class="btn-primary">Sign In</button>
      </form>

      <a href="${pageContext.request.contextPath}/products" class="btn-secondary">
        Continue as guest
      </a>

    </div>
  </div>

  <!-- ── Right: Visual Panel ── -->
  <div class="auth-panel auth-panel--visual">
    <div class="visual-content">
      <div class="visual-logo">FASHION<span>.</span></div>
      <p class="visual-tagline">Curated Style &nbsp;·&nbsp; Premium Quality</p>

      <div class="visual-accent"></div>

      <div class="visual-lines">
        <div class="visual-line">Discover</div>
        <div class="visual-line active">Define</div>
        <div class="visual-line">Elevate</div>
      </div>
    </div>
  </div>

</div>

<script>
  // Animate visual lines on load
  const lines = document.querySelectorAll('.visual-line');
  let current = 1;
  setInterval(() => {
    lines.forEach(l => l.classList.remove('active'));
    current = (current + 1) % lines.length;
    lines[current].classList.add('active');
  }, 2000);
</script>

</body>
</html>
