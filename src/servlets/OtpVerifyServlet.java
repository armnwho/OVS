package servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public class OtpVerifyServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pendingVoterId") == null) {
            response.sendRedirect("verify-voter");
            return;
        }

        String phoneOtp = request.getParameter("phone_otp");
        String emailOtp = request.getParameter("email_otp");
        String expectedPhone = (String) session.getAttribute("expectedPhoneOtp");
        String expectedEmail = (String) session.getAttribute("expectedEmailOtp");

        if (phoneOtp == null || emailOtp == null ||
            !phoneOtp.equals(expectedPhone) || !emailOtp.equals(expectedEmail)) {
            session.setAttribute("otpError", "Invalid verification codes. Please check and try again.");
            response.sendRedirect("verify-otp.jsp?step=otp");
            return;
        }

        // OTPs match — create or retrieve user account
        String voterId = (String) session.getAttribute("pendingVoterId");
        String fullName = (String) session.getAttribute("pendingName");

        try (Connection conn = DBConnection.getConnection()) {
            // Check if user already exists
            String checkSql = "SELECT id, username, has_voted FROM users WHERE voter_id = ?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setString(1, voterId);
            ResultSet rs = checkPs.executeQuery();

            int userId;
            String username;
            int hasVoted;

            if (rs.next()) {
                userId = rs.getInt("id");
                username = rs.getString("username");
                hasVoted = rs.getInt("has_voted");
            } else {
                // Create new user account
                username = fullName;
                String insertSql = "INSERT INTO users (username, password, voter_id, has_voted) VALUES (?, ?, ?, 0)";
                PreparedStatement insertPs = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
                insertPs.setString(1, username);
                insertPs.setString(2, "auto_generated");
                insertPs.setString(3, voterId);
                insertPs.executeUpdate();

                ResultSet keys = insertPs.getGeneratedKeys();
                keys.next();
                userId = keys.getInt(1);
                hasVoted = 0;
            }

            // Set authenticated session attributes
            session.setAttribute("userId", userId);
            session.setAttribute("username", username);
            session.setAttribute("voterId", voterId);
            session.setAttribute("hasVoted", hasVoted);

            // Clean up pending attributes
            session.removeAttribute("pendingVoterId");
            session.removeAttribute("pendingPhone");
            session.removeAttribute("pendingEmail");
            session.removeAttribute("pendingName");
            session.removeAttribute("expectedPhoneOtp");
            session.removeAttribute("expectedEmailOtp");
            session.removeAttribute("otpError");

            response.sendRedirect("vote");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("otpError", "A system error occurred. Please try again.");
            response.sendRedirect("verify-otp.jsp?step=otp");
        }
    }
}
