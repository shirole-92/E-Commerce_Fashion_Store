<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.fashionstore.model.User" %>
<%@ page import="com.fashionstore.model.CartItemView" %>
<%
    List<CartItemView> cartItems = (List<CartItemView>) request.getAttribute("cartItems");
    double totalAmount = request.getAttribute("totalAmount") != null ? (double) request.getAttribute("totalAmount") : 0;
    int cartCount = request.getAttribute("cartCount") != null ? (int) request.getAttribute("cartCount") : 0;
    User user = (User) session.getAttribute("user");
    boolean isEmpty = cartItems == null || cartItems.isEmpty();
    double deliveryCharge = totalAmount >= 999 ? 0 : 99;
    double grandTotal = totalAmount + deliveryCharge;
    boolean added = "true".equals(request.getParameter("added"));
    boolean orderFailed = "orderFailed".equals(request.getParameter("error"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Cart — FashionStore</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cart.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/toast.css">
  <% if (added) { %>
    <meta name="toast-message" content="Item added to your cart!" data-type="success" data-sub="Review your cart before checkout">
  <% } %>
  <% if (orderFailed) { %>
    <meta name="toast-message" content="Failed to place order" data-type="error" data-sub="Please try again or contact support">
  <% } %>
</head>
<body>
<nav class="top-nav">
  <a href="${pageContext.request.contextPath}/products" class="nav-logo">FASHION<span>.</span></a>
  <ul class="nav-links">
    <li><a href="${pageContext.request.contextPath}/products">Shop</a></li>
    <li><a href="${pageContext.request.contextPath}/user?action=profile"><%= user.getName().split(" ")[0] %></a></li>
    <li><a href="${pageContext.request.contextPath}/order?action=myOrders">Orders</a></li>
    <li><a href="${pageContext.request.contextPath}/cart" class="nav-cart active">Cart<% if (cartCount > 0) { %><span class="nav-cart-badge"><%= cartCount %></span><% } %></a></li>
    <li><a href="${pageContext.request.contextPath}/user?action=logout">Sign out</a></li>
  </ul>
</nav>

<div class="page-body">
  <div class="page-header">
    <p class="page-eyebrow">Shopping</p>
    <h1 class="page-title">My Cart<% if (!isEmpty) { %> <span style="font-size:20px;color:var(--muted);font-family:'Barlow',sans-serif;font-weight:300;">(<%= cartCount %> <%= cartCount == 1 ? "item" : "items" %>)</span><% } %></h1>
  </div>

  <div class="cart-layout">
    <% if (!isEmpty) { %>
      <div class="cart-items-wrap">
        <% for (CartItemView view : cartItems) { %>
          <div class="cart-item">
            <div class="cart-item-img-wrap">
              <% if (view.getProduct().getImageUrl() != null && !view.getProduct().getImageUrl().isEmpty()) { %>
                <img class="cart-item-img" src="${pageContext.request.contextPath}<%= view.getProduct().getImageUrl() %>" alt="<%= view.getProduct().getName() %>">
              <% } else { %>
                <div class="cart-item-img-placeholder">&#9900;</div>
              <% } %>
            </div>
            <div class="cart-item-details">
              <p class="cart-item-category"><%= view.getProduct().getCategoryId() == 1 ? "Men" : "Women" %></p>
              <h3 class="cart-item-name"><%= view.getProduct().getName() %></h3>
              <div class="cart-item-meta">
                <span>Size: <%= view.getSize() %></span>
                <span>&#8377;<%= String.format("%.0f", view.getProduct().getPrice()) %> each</span>
              </div>
              <form action="${pageContext.request.contextPath}/cart" method="post" id="qtyForm_<%= view.getItem().getId() %>">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="cartItemId" value="<%= view.getItem().getId() %>">
                <input type="hidden" name="quantity" id="qtyHidden_<%= view.getItem().getId() %>" value="<%= view.getItem().getQuantity() %>">
              </form>
              <div class="qty-control">
                <button type="button" class="qty-btn" onclick="changeQty(<%= view.getItem().getId() %>, -1)">&#8722;</button>
                <div class="qty-display" id="qtyDisplay_<%= view.getItem().getId() %>"><%= view.getItem().getQuantity() %></div>
                <button type="button" class="qty-btn" onclick="changeQty(<%= view.getItem().getId() %>, 1)">&#43;</button>
              </div>
            </div>
            <div class="cart-item-actions">
              <p class="cart-item-total">&#8377;<%= String.format("%.0f", view.getItemTotal()) %></p>
              <form action="${pageContext.request.contextPath}/cart" method="post">
                <input type="hidden" name="action" value="remove">
                <input type="hidden" name="cartItemId" value="<%= view.getItem().getId() %>">
                <button type="submit" class="btn-remove"
                        onclick="Toast.info('Item removed from cart')">Remove</button>
              </form>
            </div>
          </div>
        <% } %>
      </div>

      <div class="order-summary">
        <p class="summary-title">Order Summary</p>
        <div class="summary-row"><span>Subtotal (<%= cartCount %> items)</span><span>&#8377;<%= String.format("%.0f", totalAmount) %></span></div>
        <div class="summary-row">
          <span>Delivery</span>
          <span><% if (deliveryCharge == 0) { %><span style="color:var(--success);">Free</span><% } else { %>&#8377;<%= String.format("%.0f", deliveryCharge) %><% } %></span>
        </div>
        <% if (deliveryCharge > 0) { %>
          <p style="font-size:11px;color:var(--muted);margin-bottom:4px;">Add &#8377;<%= String.format("%.0f", 999 - totalAmount) %> more for free delivery</p>
        <% } %>
        <div class="summary-row total"><span>Total</span><span class="summary-val">&#8377;<%= String.format("%.0f", grandTotal) %></span></div>
        <p class="summary-note">Taxes included. Free delivery above ₹999.</p>
        <button type="button" class="btn-checkout" onclick="showConfirmModal()">Proceed to Checkout</button>
        <a href="${pageContext.request.contextPath}/products" class="btn-continue">Continue Shopping</a>
      </div>

    <% } else { %>
      <div class="empty-cart">
        <div class="empty-cart-icon">
          <svg width="80" height="80" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="0.8">
            <path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/>
            <line x1="3" y1="6" x2="21" y2="6"/>
            <path d="M16 10a4 4 0 01-8 0"/>
          </svg>
        </div>
        <h2>Your cart is empty</h2>
        <p>Browse our collection and add something you love.</p>
        <a href="${pageContext.request.contextPath}/products">Browse Collection</a>
      </div>
    <% } %>
  </div>

  <footer class="site-footer">
    <div class="footer-logo">FASHION<span>.</span></div>
    <p class="footer-note">&copy; 2025 FashionStore. All rights reserved.</p>
  </footer>
</div>


<!-- ── Confirmation Modal ── -->
<div id="confirmModal" style="
  display:none;
  position:fixed;
  inset:0;
  z-index:9999;
  background:rgba(0,0,0,0.75);
  backdrop-filter:blur(4px);
  align-items:center;
  justify-content:center;
">
  <div style="
    background:#111;
    border:1px solid #2e2e2e;
    border-radius:4px;
    padding:40px;
    max-width:420px;
    width:90%;
    position:relative;
    box-shadow:0 24px 64px rgba(0,0,0,0.8);
  ">
    <!-- Gold accent top bar -->
    <div style="position:absolute;top:0;left:0;right:0;height:2px;background:#c9a84c;border-radius:4px 4px 0 0;"></div>

    <!-- Icon -->
    <div style="text-align:center;margin-bottom:20px;">
      <div style="
        width:56px;height:56px;
        background:rgba(201,168,76,0.1);
        border:1px solid #8a6f2e;
        border-radius:50%;
        display:inline-flex;
        align-items:center;
        justify-content:center;
        font-size:22px;
      ">&#128722;</div>
    </div>

    <!-- Title -->
    <h2 style="
      font-family:'Playfair Display',serif;
      font-size:24px;
      font-weight:700;
      color:#f5f5f0;
      text-align:center;
      margin-bottom:8px;
      letter-spacing:-0.5px;
    ">Confirm Your Order</h2>

    <p style="
      font-size:13px;
      color:#777;
      text-align:center;
      margin-bottom:24px;
      line-height:1.6;
    ">You are about to place an order for</p>

    <!-- Amount -->
    <div style="
      background:#1a1a1a;
      border:1px solid #2e2e2e;
      border-radius:4px;
      padding:16px 24px;
      display:flex;
      justify-content:space-between;
      align-items:center;
      margin-bottom:8px;
    ">
      <span style="font-size:12px;letter-spacing:1px;color:#777;text-transform:uppercase;">Total Amount</span>
      <span style="font-family:'Playfair Display',serif;font-size:22px;font-weight:700;color:#c9a84c;" id="modalTotal"></span>
    </div>

    <div style="
      display:flex;
      justify-content:space-between;
      align-items:center;
      margin-bottom:28px;
      padding:0 4px;
    ">
      <span style="font-size:11px;color:#555;">Delivery to <%= user != null ? user.getAddressLine() != null && !user.getAddressLine().isEmpty() ? user.getAddressLine() : user.getCity() != null ? user.getCity() : "your address" : "your address" %></span>
      <span style="font-size:11px;color:<%= deliveryCharge == 0 ? "#2ecc71" : "#c9a84c" %>;">
        Delivery: <%= deliveryCharge == 0 ? "Free" : "₹" + String.format("%.0f", deliveryCharge) %>
      </span>
    </div>

    <!-- Buttons -->
    <div style="display:flex;gap:12px;">
      <button onclick="hideConfirmModal()" style="
        flex:1;
        padding:13px;
        background:transparent;
        color:#999;
        border:1px solid #2e2e2e;
        border-radius:2px;
        font-family:'Barlow',sans-serif;
        font-size:11px;
        font-weight:500;
        letter-spacing:2px;
        text-transform:uppercase;
        cursor:pointer;
        transition:border-color 0.2s,color 0.2s;
      " onmouseover="this.style.borderColor='#c9a84c';this.style.color='#c9a84c'"
         onmouseout="this.style.borderColor='#2e2e2e';this.style.color='#999'">
        Cancel
      </button>
      <a href="${pageContext.request.contextPath}/order?action=placeOrder" style="
        flex:1;
        padding:13px;
        background:#c9a84c;
        color:#0a0a0a;
        border:none;
        border-radius:2px;
        font-family:'Barlow',sans-serif;
        font-size:11px;
        font-weight:600;
        letter-spacing:2px;
        text-transform:uppercase;
        cursor:pointer;
        text-align:center;
        text-decoration:none;
        display:flex;
        align-items:center;
        justify-content:center;
        transition:background 0.2s;
      " onmouseover="this.style.background='#d4b05a'"
         onmouseout="this.style.background='#c9a84c'">
        Confirm Order
      </a>
    </div>

    <!-- Close X -->
    <button onclick="hideConfirmModal()" style="
      position:absolute;
      top:16px;right:16px;
      background:transparent;
      border:none;
      color:#555;
      font-size:18px;
      cursor:pointer;
      line-height:1;
      transition:color 0.2s;
    " onmouseover="this.style.color='#f5f5f0'"
       onmouseout="this.style.color='#555'">&#x2715;</button>
  </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
<script>
  function changeQty(itemId, delta) {
    const display = document.getElementById('qtyDisplay_' + itemId);
    const hidden  = document.getElementById('qtyHidden_'  + itemId);
    const form    = document.getElementById('qtyForm_'    + itemId);
    let current = parseInt(display.textContent);
    let newVal  = current + delta;
    if (newVal < 1) newVal = 1;
    if (newVal > 10) newVal = 10;
    display.textContent = newVal;
    hidden.value = newVal;
    Toast.info('Quantity updated');
    setTimeout(() => form.submit(), 400);
  }

  function showConfirmModal() {
    // Get grand total from page
    const totalEl = document.querySelector('.summary-val');
    document.getElementById('modalTotal').textContent = totalEl ? totalEl.textContent : '';
    const modal = document.getElementById('confirmModal');
    modal.style.display = 'flex';
    // Prevent background scroll
    document.body.style.overflow = 'hidden';
  }

  function hideConfirmModal() {
    document.getElementById('confirmModal').style.display = 'none';
    document.body.style.overflow = '';
  }

  // Close on backdrop click
  document.getElementById('confirmModal').addEventListener('click', function(e) {
    if (e.target === this) hideConfirmModal();
  });

  // Close on Escape key
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') hideConfirmModal();
  });
</script>
</body>
</html>
