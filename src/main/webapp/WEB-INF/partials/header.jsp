<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.fashionstore.model.User" %>

<%
    User user = (User) session.getAttribute("user");
    Integer cartCount = (Integer) request.getAttribute("cartCount");

    if (cartCount == null) {
        cartCount = 0;
    }
%>

<div class="header">

    <div class="logo">
        <a href="${pageContext.request.contextPath}/products">Fashion Store</a>
    </div>

    <form action="${pageContext.request.contextPath}/products" method="get" class="search-box">
        <input type="text" name="search" placeholder="Search products...">
        <button type="submit">Search</button>
    </form>

    <div class="nav-links">

        <a href="${pageContext.request.contextPath}/products">Home</a>

        <a href="${pageContext.request.contextPath}/cart">
            Cart (<%= cartCount %>)
        </a>

        <% if (user != null) { %>

            <span>Hi, <%= user.getName() %></span>

            <a href="${pageContext.request.contextPath}/logout">Logout</a>

        <% } else { %>

            <a href="${pageContext.request.contextPath}/login">Login</a>

        <% } %>

    </div>

</div>