package com.fashionstore.controller;

import java.io.IOException;

import com.fashionstore.dao.UserDAO;
import com.fashionstore.dao.impl.UserDAOImpl;
import com.fashionstore.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/user")
public class UserServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private UserDAO userDAO = new UserDAOImpl();

    // -------------------------------------------------------
    // GET — show login, register, or profile page
    // -------------------------------------------------------
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            action = "login";
        }

        switch (action) {

            case "register":
                request.getRequestDispatcher("/WEB-INF/views/register.jsp")
                       .forward(request, response);
                break;

            case "profile":
                // Must be logged in
                User sessionUser = (User) request.getSession().getAttribute("user");
                if (sessionUser == null) {
                    response.sendRedirect(request.getContextPath() + "/user?action=login");
                    return;
                }
                // Refresh user data from DB (in case it was updated elsewhere)
                User freshUser = userDAO.getUserById(sessionUser.getId());
                request.setAttribute("user", freshUser);
                request.getRequestDispatcher("/WEB-INF/views/profile.jsp")
                       .forward(request, response);
                break;

            case "logout":
                HttpSession session = request.getSession(false);
                if (session != null) {
                    session.invalidate();
                }
                response.sendRedirect(request.getContextPath() + "/user?action=login");
                break;

            case "login":
            default:
                // If already logged in, go to products
                if (request.getSession().getAttribute("user") != null) {
                    response.sendRedirect(request.getContextPath() + "/products");
                    return;
                }
                request.getRequestDispatcher("/WEB-INF/views/login.jsp")
                       .forward(request, response);
                break;
        }
    }

    // -------------------------------------------------------
    // POST — handle login, register, profile update
    // -------------------------------------------------------
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/user?action=login");
            return;
        }

        switch (action) {

            case "login":
                handleLogin(request, response);
                break;

            case "register":
                handleRegister(request, response);
                break;

            case "updateProfile":
                handleUpdateProfile(request, response);
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/user?action=login");
                break;
        }
    }

    // -------------------------------------------------------
    // Login logic
    // -------------------------------------------------------
    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email    = request.getParameter("email");
        String password = request.getParameter("password");

        // Basic validation
        if (email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {

            request.setAttribute("error", "Email and password are required.");
            request.getRequestDispatcher("/WEB-INF/views/login.jsp")
                   .forward(request, response);
            return;
        }

        User user = userDAO.loginUser(email.trim(), password.trim());

        if (user != null) {
            // Create session and store user
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setMaxInactiveInterval(30 * 60); // 30 minutes

            response.sendRedirect(request.getContextPath() + "/products");

        } else {
            request.setAttribute("error", "Invalid email or password.");
            request.setAttribute("emailValue", email); // preserve email field
            request.getRequestDispatcher("/WEB-INF/views/login.jsp")
                   .forward(request, response);
        }
    }

    // -------------------------------------------------------
    // Register logic
    // -------------------------------------------------------
    private void handleRegister(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name        = request.getParameter("name");
        String email       = request.getParameter("email");
        String password    = request.getParameter("password");
        String addressLine = request.getParameter("addressLine");
        String city        = request.getParameter("city");
        String state       = request.getParameter("state");
        String pincode     = request.getParameter("pincode");

        // Basic validation
        if (name == null || name.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {

            request.setAttribute("error", "Name, email, and password are required.");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp")
                   .forward(request, response);
            return;
        }

        // Check if email already taken
        if (userDAO.isEmailExists(email.trim())) {
            request.setAttribute("error", "An account with this email already exists.");
            request.setAttribute("emailValue", email);
            request.getRequestDispatcher("/WEB-INF/views/register.jsp")
                   .forward(request, response);
            return;
        }

        // Build user object
        User newUser = new User();
        newUser.setName(name.trim());
        newUser.setEmail(email.trim());
        newUser.setPassword(password.trim()); // ⚠ Hash this with BCrypt in production
        newUser.setAddressLine(addressLine != null ? addressLine.trim() : "");
        newUser.setCity(city != null ? city.trim() : "");
        newUser.setState(state != null ? state.trim() : "");
        newUser.setPincode(pincode != null ? pincode.trim() : "");

        boolean success = userDAO.registerUser(newUser);

        if (success) {
            // Auto-login after register
            User registeredUser = userDAO.loginUser(email.trim(), password.trim());
            if (registeredUser != null) {
                HttpSession session = request.getSession();
                session.setAttribute("user", registeredUser);
                session.setMaxInactiveInterval(30 * 60);
            }
            response.sendRedirect(request.getContextPath() + "/products");

        } else {
            request.setAttribute("error", "Registration failed. Please try again.");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp")
                   .forward(request, response);
        }
    }

    // -------------------------------------------------------
    // Profile update logic
    // -------------------------------------------------------
    private void handleUpdateProfile(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Must be logged in
        User sessionUser = (User) request.getSession().getAttribute("user");
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/user?action=login");
            return;
        }

        String name        = request.getParameter("name");
        String email       = request.getParameter("email");
        String password    = request.getParameter("password");
        String addressLine = request.getParameter("addressLine");
        String city        = request.getParameter("city");
        String state       = request.getParameter("state");
        String pincode     = request.getParameter("pincode");

        // Basic validation
        if (name == null || name.trim().isEmpty() ||
            email == null || email.trim().isEmpty()) {

            request.setAttribute("error", "Name and email are required.");
            request.setAttribute("user", sessionUser);
            request.getRequestDispatcher("/WEB-INF/views/profile.jsp")
                   .forward(request, response);
            return;
        }

        // If email changed, make sure it's not taken by someone else
        if (!email.trim().equalsIgnoreCase(sessionUser.getEmail()) &&
             userDAO.isEmailExists(email.trim())) {

            request.setAttribute("error", "That email is already used by another account.");
            request.setAttribute("user", sessionUser);
            request.getRequestDispatcher("/WEB-INF/views/profile.jsp")
                   .forward(request, response);
            return;
        }

        // If password field is blank, keep the existing password
        String finalPassword = (password != null && !password.trim().isEmpty())
                ? password.trim()
                : sessionUser.getPassword();

        User updatedUser = new User();
        updatedUser.setId(sessionUser.getId());
        updatedUser.setName(name.trim());
        updatedUser.setEmail(email.trim());
        updatedUser.setPassword(finalPassword); // ⚠ Hash with BCrypt in production
        updatedUser.setAddressLine(addressLine != null ? addressLine.trim() : "");
        updatedUser.setCity(city != null ? city.trim() : "");
        updatedUser.setState(state != null ? state.trim() : "");
        updatedUser.setPincode(pincode != null ? pincode.trim() : "");

        boolean success = userDAO.updateUser(updatedUser);

        if (success) {
            // Refresh session with updated data
            request.getSession().setAttribute("user", updatedUser);
            request.setAttribute("success", "Profile updated successfully.");
        } else {
            request.setAttribute("error", "Update failed. Please try again.");
        }

        request.setAttribute("user", updatedUser);
        request.getRequestDispatcher("/WEB-INF/views/profile.jsp")
               .forward(request, response);
    }
}