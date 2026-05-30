<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.fashionstore.model.Order" %>
<%@ page import="com.fashionstore.model.OrderItem" %>
<%@ page import="com.fashionstore.model.User" %>
<%
    Order order           = (Order) request.getAttribute("order");
    List<OrderItem> items = (List<OrderItem>) request.getAttribute("orderItems");
    User user             = (User) session.getAttribute("user");
    SimpleDateFormat sdf  = new SimpleDateFormat("dd MMM yyyy, hh:mm a");

    String status = order.getStatus().toUpperCase();

    // Timeline step states: 0=pending, 1=active, 2=done
    int placedState    = 0;
    int shippedState   = 0;
    int deliveredState = 0;

    if (status.equals("PLACED")) {
        placedState = 1;
    } else if (status.equals("SHIPPED")) {
        placedState    = 2;
        shippedState   = 1;
    } else if (status.equals("DELIVERED")) {
        placedState    = 2;
        shippedState   = 2;
        deliveredState = 1;
    } else if (status.equals("CANCELLED")) {
        placedState = 2; // show placed as done but cancelled
    }

    String statusClass = "status-placed";
    if (status.equals("SHIPPED"))    statusClass = "status-shipped";
    if (status.equals("DELIVERED"))  statusClass = "status-delivered";
    if (status.equals("CANCELLED"))  statusClass = "status-cancelled";
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Order #<%= order.getId() %> — FashionStore</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/order.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/toast.css">
  <style>

    /* ── ORDER TRACKING TIMELINE ─────────────── */

    .tracking-section {
      max-width: 960px;
      margin: 0 auto;
      padding: 32px 48px 0;
    }

    .tracking-card {
      background: var(--coal);
      border: 1px solid var(--border);
      border-radius: 4px;
      padding: 32px 40px;
      margin-bottom: 24px;
    }

    .tracking-title {
      font-size: 10px;
      letter-spacing: 3px;
      text-transform: uppercase;
      color: var(--muted);
      font-weight: 500;
      margin-bottom: 32px;
      padding-bottom: 16px;
      border-bottom: 1px solid var(--border);
    }

    .timeline {
      display: flex;
      align-items: flex-start;
      position: relative;
    }

    /* connecting line */
    .timeline::before {
      content: '';
      position: absolute;
      top: 18px;
      left: calc(16.66% + 18px);
      right: calc(16.66% + 18px);
      height: 1px;
      background: var(--border);
      z-index: 0;
    }

    .timeline-step {
      flex: 1;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 12px;
      position: relative;
      z-index: 1;
    }

    /* dot */
    .step-dot {
      width: 36px;
      height: 36px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 14px;
      font-weight: 600;
      transition: all 0.3s ease;
      position: relative;
    }

    /* pending */
    .step-dot.pending {
      background: var(--graphite);
      border: 1px solid var(--border);
      color: var(--muted);
    }

    /* active — current status */
    .step-dot.active {
      background: var(--gold);
      border: 2px solid var(--gold);
      color: var(--black);
      box-shadow: 0 0 0 4px rgba(201,168,76,0.15);
    }

    /* done — passed */
    .step-dot.done {
      background: var(--graphite);
      border: 1px solid var(--gold-dim);
      color: var(--gold);
    }

    /* cancelled */
    .step-dot.cancelled {
      background: rgba(192,57,43,0.1);
      border: 1px solid var(--danger);
      color: var(--danger);
    }

    /* connecting line fill for completed steps */
    .timeline-line {
      position: absolute;
      top: 18px;
      height: 1px;
      z-index: 0;
    }

    .timeline-line.done-line {
      background: var(--gold-dim);
    }

    .step-label {
      font-size: 11px;
      font-weight: 500;
      letter-spacing: 1px;
      text-transform: uppercase;
      text-align: center;
    }

    .step-label.pending   { color: var(--muted); }
    .step-label.active    { color: var(--gold); }
    .step-label.done      { color: var(--silver); }
    .step-label.cancelled { color: var(--danger); }

    .step-date {
      font-size: 11px;
      color: var(--muted);
      text-align: center;
      letter-spacing: 0.3px;
    }

    /* cancelled banner */
    .cancelled-banner {
      background: rgba(192,57,43,0.08);
      border: 1px solid var(--danger);
      border-radius: 4px;
      padding: 14px 20px;
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 24px;
    }

    .cancelled-banner-icon {
      color: var(--danger);
      font-size: 16px;
      flex-shrink: 0;
    }

    .cancelled-banner-text {
      font-size: 13px;
      color: #e57373;
    }

    /* item image */
    .order-item-row {
      display: grid;
      grid-template-columns: 72px 1fr auto;
      gap: 16px;
      padding: 16px 0;
      border-bottom: 1px solid var(--border);
      align-items: center;
    }

    .order-item-row:last-child { border-bottom: none; }

    .order-item-img {
      width: 72px;
      height: 96px;
      object-fit: cover;
      object-position: top;
      background: var(--graphite);
      display: block;
      border-radius: 2px;
    }

    .order-item-img-placeholder {
      width: 72px;
      height: 96px;
      background: var(--graphite);
      display: flex;
      align-items: center;
      justify-content: center;
      color: var(--muted);
      font-size: 22px;
      border-radius: 2px;
    }

  </style>
</head>
<body>

<!-- ── Nav ── -->
<nav class="top-nav">
  <a href="${pageContext.request.contextPath}/products" class="nav-logo">FASHION<span>.</span></a>
  <ul class="nav-links">
    <li><a href="${pageContext.request.contextPath}/products">Shop</a></li>
    <li><a href="${pageContext.request.contextPath}/user?action=profile"><%= user.getName().split(" ")[0] %></a></li>
    <li><a href="${pageContext.request.contextPath}/order?action=myOrders" class="active">Orders</a></li>
    <li><a href="${pageContext.request.contextPath}/cart">Cart</a></li>
    <li><a href="${pageContext.request.contextPath}/user?action=logout">Sign out</a></li>
  </ul>
</nav>

<div class="page-body">

  <!-- ── Breadcrumb ── -->
  <div class="breadcrumb">
    <a href="${pageContext.request.contextPath}/order?action=myOrders">My Orders</a>
    <span class="breadcrumb-sep">&#8250;</span>
    <span class="breadcrumb-current">Order #<%= order.getId() %></span>
  </div>

  <!-- ── Flash messages ── -->
  <% if (request.getParameter("cancelled") != null) { %>
    <div style="max-width:960px;margin:16px auto 0;padding:0 48px;">
      <div style="background:rgba(46,204,113,0.08);border-left:3px solid #2ecc71;padding:12px 16px;font-size:13px;color:#66bb6a;border-radius:2px;">
        &#10003; &nbsp;Order cancelled successfully.
      </div>
    </div>
  <% } %>
  <% if ("true".equals(request.getParameter("cancelError"))) { %>
    <div style="max-width:960px;margin:16px auto 0;padding:0 48px;">
      <div style="background:rgba(192,57,43,0.1);border-left:3px solid #c0392b;padding:12px 16px;font-size:13px;color:#e57373;border-radius:2px;">
        &#10005; &nbsp;This order cannot be cancelled. It may already be shipped or delivered.
      </div>
    </div>
  <% } %>

  <!-- ── Tracking Timeline ── -->
  <div class="tracking-section">

    <% if (status.equals("CANCELLED")) { %>
      <div class="cancelled-banner">
        <span class="cancelled-banner-icon">✕</span>
        <span class="cancelled-banner-text">This order was cancelled.</span>
      </div>
    <% } else { %>

    <div class="tracking-card">
      <p class="tracking-title">Order Status</p>

      <div class="timeline">

        <!-- Step 1: Placed -->
        <div class="timeline-step">
          <div class="step-dot <%= placedState == 1 ? "active" : placedState == 2 ? "done" : "pending" %>">
            <%= placedState == 2 ? "✓" : "1" %>
          </div>
          <span class="step-label <%= placedState == 1 ? "active" : placedState == 2 ? "done" : "pending" %>">
            Order Placed
          </span>
          <span class="step-date"><%= sdf.format(order.getOrderDate()) %></span>
        </div>

        <!-- Step 2: Shipped -->
        <div class="timeline-step">
          <div class="step-dot <%= shippedState == 1 ? "active" : shippedState == 2 ? "done" : "pending" %>">
            <%= shippedState == 2 ? "✓" : "2" %>
          </div>
          <span class="step-label <%= shippedState == 1 ? "active" : shippedState == 2 ? "done" : "pending" %>">
            Shipped
          </span>
          <span class="step-date">
            <%= shippedState > 0 ? "In transit" : "Pending" %>
          </span>
        </div>

        <!-- Step 3: Delivered -->
        <div class="timeline-step">
          <div class="step-dot <%= deliveredState == 1 ? "active" : deliveredState == 2 ? "done" : "pending" %>">
            <%= deliveredState == 2 ? "✓" : "3" %>
          </div>
          <span class="step-label <%= deliveredState == 1 ? "active" : deliveredState == 2 ? "done" : "pending" %>">
            Delivered
          </span>
          <span class="step-date">
            <%= deliveredState > 0 ? "Delivered" : "Estimated 3-5 days" %>
          </span>
        </div>

      </div>
    </div>

    <% } %>
  </div>

  <!-- ── Detail Grid ── -->
  <div class="detail-grid">

    <!-- Left: Items -->
    <div class="detail-card">
      <p class="detail-card-title">Order Items</p>

      <% if (items != null && !items.isEmpty()) {
           for (OrderItem item : items) {
             String catName = item.getCategoryId() == 1 ? "Men" : "Women";
             String name    = item.getProductName() != null ? item.getProductName() : "Product #" + item.getProductId();
             String img     = item.getProductImage();
      %>
        <div class="order-item-row">
          <% if (img != null && !img.isEmpty()) { %>
            <img class="order-item-img"
                 src="${pageContext.request.contextPath}<%= img %>"
                 alt="<%= name %>">
          <% } else { %>
            <div class="order-item-img-placeholder">&#9900;</div>
          <% } %>
          <div>
            <p class="order-item-name"><%= name %></p>
            <p class="order-item-meta">
              <%= catName %> &nbsp;·&nbsp;
              Qty: <%= item.getQuantity() %> &nbsp;·&nbsp;
              &#8377;<%= String.format("%.0f", item.getPrice()) %> each
            </p>
          </div>
          <p class="order-item-price">
            &#8377;<%= String.format("%.0f", item.getPrice() * item.getQuantity()) %>
          </p>
        </div>
      <%   }
         } else { %>
        <p style="color:var(--muted);font-size:13px;">No items found.</p>
      <% } %>
    </div>

    <!-- Right: Summary -->
    <div class="detail-summary">

      <div class="summary-card">
        <p class="summary-card-title">Order Summary</p>
        <div class="summary-row">
          <span>Order ID</span>
          <span>#<%= order.getId() %></span>
        </div>
        <div class="summary-row">
          <span>Date</span>
          <span><%= sdf.format(order.getOrderDate()) %></span>
        </div>
        <div class="summary-row">
          <span>Status</span>
          <span class="order-status <%= statusClass %>"><%= order.getStatus() %></span>
        </div>
        <div class="summary-row total">
          <span>Total</span>
          <span>&#8377;<%= String.format("%.0f", order.getTotalAmount()) %></span>
        </div>
      </div>

      <div class="summary-card">
        <p class="summary-card-title">Delivery Address</p>
        <div class="info-row">
          <span class="info-label">Name</span>
          <span class="info-value"><%= user.getName() %></span>
        </div>
        <% if (user.getAddressLine() != null && !user.getAddressLine().isEmpty()) { %>
          <div class="info-row">
            <span class="info-label">Address</span>
            <span class="info-value"><%= user.getAddressLine() %></span>
          </div>
        <% } %>
        <% if (user.getCity() != null && !user.getCity().isEmpty()) { %>
          <div class="info-row">
            <span class="info-label">City</span>
            <span class="info-value">
              <%= user.getCity() %>, <%= user.getState() %> — <%= user.getPincode() %>
            </span>
          </div>
        <% } %>
      </div>

      <% if ("PLACED".equalsIgnoreCase(order.getStatus())) { %>
        <a href="${pageContext.request.contextPath}/order?action=cancelOrder&orderId=<%= order.getId() %>"
           id="cancelBtn"
           style="
             display:block;
             width:100%;
             padding:13px;
             margin-bottom:12px;
             background:transparent;
             color:#e57373;
             border:1px solid #c0392b;
             border-radius:2px;
             font-family:'Barlow',sans-serif;
             font-size:10px;
             font-weight:500;
             letter-spacing:2px;
             text-transform:uppercase;
             text-align:center;
             text-decoration:none;
             transition:background 0.2s,color 0.2s;
           "
           onmouseover="this.style.background='rgba(192,57,43,0.1)'"
           onmouseout="this.style.background='transparent'"
           onclick="cancelOrder(event, '<%= order.getId() %>')">
          &#10005; &nbsp;Cancel Order
        </a>
      <% } %>

      <a href="${pageContext.request.contextPath}/order?action=myOrders" class="btn-back">
        &#8592; &nbsp;Back to Orders
      </a>

    </div>
  </div>

  <footer class="site-footer">
    <div class="footer-logo">FASHION<span>.</span></div>
    <p class="footer-note">&copy; 2025 FashionStore. All rights reserved.</p>
  </footer>

</div>

<script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
<!-- Cancel Confirmation Modal -->
<div id="cancelModal" style="
  display:none;position:fixed;inset:0;z-index:9999;
  background:rgba(0,0,0,0.75);backdrop-filter:blur(4px);
  align-items:center;justify-content:center;
">
  <div style="
    background:#111;border:1px solid #2e2e2e;border-radius:4px;
    padding:36px;max-width:380px;width:90%;position:relative;
    box-shadow:0 24px 64px rgba(0,0,0,0.8);
  ">
    <div style="position:absolute;top:0;left:0;right:0;height:2px;background:#c0392b;border-radius:4px 4px 0 0;"></div>
    <div style="text-align:center;margin-bottom:16px;">
      <div style="width:52px;height:52px;background:rgba(192,57,43,0.1);border:1px solid #c0392b;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:20px;color:#e57373;">✕</div>
    </div>
    <h3 style="font-family:'Playfair Display',serif;font-size:22px;font-weight:700;color:#f5f5f0;text-align:center;margin-bottom:8px;">Cancel Order?</h3>
    <p style="font-size:13px;color:#777;text-align:center;margin-bottom:28px;line-height:1.6;">This action cannot be undone. Your order will be marked as cancelled.</p>
    <div style="display:flex;gap:12px;">
      <button onclick="document.getElementById('cancelModal').style.display='none';document.body.style.overflow='';" style="
        flex:1;padding:12px;background:transparent;color:#999;border:1px solid #2e2e2e;
        border-radius:2px;font-family:'Barlow',sans-serif;font-size:11px;font-weight:500;
        letter-spacing:2px;text-transform:uppercase;cursor:pointer;
      ">Keep Order</button>
      <a id="cancelConfirmBtn" href="#" style="
        flex:1;padding:12px;background:#c0392b;color:#fff;border:none;border-radius:2px;
        font-family:'Barlow',sans-serif;font-size:11px;font-weight:600;
        letter-spacing:2px;text-transform:uppercase;cursor:pointer;
        text-align:center;text-decoration:none;display:flex;align-items:center;justify-content:center;
      ">Yes, Cancel</a>
    </div>
  </div>
</div>

<script>
  function cancelOrder(e, orderId) {
    e.preventDefault();
    const modal = document.getElementById('cancelModal');
    const confirmBtn = document.getElementById('cancelConfirmBtn');
    confirmBtn.href = '${pageContext.request.contextPath}/order?action=cancelOrder&orderId=' + orderId;
    modal.style.display = 'flex';
    document.body.style.overflow = 'hidden';
  }

  // Close on backdrop click
  document.getElementById('cancelModal').addEventListener('click', function(e) {
    if (e.target === this) {
      this.style.display = 'none';
      document.body.style.overflow = '';
    }
  });

  // Close on Escape
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
      document.getElementById('cancelModal').style.display = 'none';
      document.body.style.overflow = '';
    }
  });
</script>
</body>
</html>
