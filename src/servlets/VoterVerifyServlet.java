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
import java.util.HashMap;
import java.util.Map;

public class VoterVerifyServlet extends HttpServlet {

    // Hardcoded OTP map — no real SMS/email API
    private static final Map<String, String[]> OTP_MAP = new HashMap<>();
    static {
        // { phoneOtp, emailOtp }
        OTP_MAP.put("VUP47392", new String[]{"482910", "736251"});
        OTP_MAP.put("VDL81620", new String[]{"193047", "528374"});
        OTP_MAP.put("VKA30517", new String[]{"847362", "019283"});
        OTP_MAP.put("VTN92746", new String[]{"571038", "294716"});
        OTP_MAP.put("VRJ54803", new String[]{"638492", "815037"});
        OTP_MAP.put("VWB61938", new String[]{"420185", "963574"});
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/verify-voter.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String voterId = request.getParameter("voter_id");
        if (voterId == null || voterId.trim().isEmpty()) {
            HttpSession session = request.getSession();
            session.setAttribute("verifyError", "Please enter a valid Voter ID.");
            response.sendRedirect("verify-voter");
            return;
        }

        voterId = voterId.trim().toUpperCase();

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT voter_id, full_name, phone, email, is_used FROM voter_registry WHERE voter_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, voterId);
            ResultSet rs = ps.executeQuery();

            if (!rs.next()) {
                HttpSession session = request.getSession();
                session.setAttribute("verifyError", "Voter ID not found in the national registry.");
                response.sendRedirect("verify-voter");
                return;
            }

            int isUsed = rs.getInt("is_used");
            if (isUsed == 1) {
                HttpSession session = request.getSession();
                session.setAttribute("verifyError", "This Voter ID has already been used to cast a vote.");
                response.sendRedirect("verify-voter");
                return;
            }

            String fullName = rs.getString("full_name");
            String phone = rs.getString("phone");
            String email = rs.getString("email");

            // Get the hardcoded OTPs
            String[] otps = OTP_MAP.get(voterId);
            String phoneOtp = (otps != null) ? otps[0] : "000000";
            String emailOtp = (otps != null) ? otps[1] : "000000";

            // Store in session
            HttpSession session = request.getSession();
            session.setAttribute("pendingVoterId", voterId);
            session.setAttribute("pendingName", fullName);
            session.setAttribute("pendingPhone", phone);
            session.setAttribute("pendingEmail", email);
            session.setAttribute("expectedPhoneOtp", phoneOtp);
            session.setAttribute("expectedEmailOtp", emailOtp);

            response.sendRedirect("verify-otp.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("verifyError", "A system error occurred. Please try again.");
            response.sendRedirect("verify-voter");
        }
    }
}
