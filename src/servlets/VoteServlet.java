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
import java.util.ArrayList;
import java.util.List;

public class VoteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("verify-voter");
            return;
        }

        // Load candidates from DB
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT id, name, vote_count FROM candidates ORDER BY id";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            List<int[]> candidateIds = new ArrayList<>();
            List<String> candidateNames = new ArrayList<>();

            while (rs.next()) {
                candidateIds.add(new int[]{rs.getInt("id")});
                candidateNames.add(rs.getString("name"));
            }

            request.setAttribute("candidateIds", candidateIds);
            request.setAttribute("candidateNames", candidateNames);

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.getRequestDispatcher("/vote.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("verify-voter");
            return;
        }

        // Check if already voted (session level)
        Integer hasVoted = (Integer) session.getAttribute("hasVoted");
        if (hasVoted != null && hasVoted == 1) {
            response.sendRedirect("results.jsp");
            return;
        }

        String candidateIdStr = request.getParameter("candidate_id");
        if (candidateIdStr == null || candidateIdStr.trim().isEmpty()) {
            response.sendRedirect("vote");
            return;
        }

        int candidateId = Integer.parseInt(candidateIdStr);
        int userId = (Integer) session.getAttribute("userId");
        String voterId = (String) session.getAttribute("voterId");

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            try {
                // Check database-level vote enforcement
                String checkSql = "SELECT has_voted FROM users WHERE id = ?";
                PreparedStatement checkPs = conn.prepareStatement(checkSql);
                checkPs.setInt(1, userId);
                ResultSet rs = checkPs.executeQuery();
                if (rs.next() && rs.getInt("has_voted") == 1) {
                    conn.rollback();
                    session.setAttribute("hasVoted", 1);
                    response.sendRedirect("confirmed.jsp");
                    return;
                }

                // 1. INSERT into votes table
                String insertVote = "INSERT INTO votes (user_id, candidate_id) VALUES (?, ?)";
                PreparedStatement ps1 = conn.prepareStatement(insertVote);
                ps1.setInt(1, userId);
                ps1.setInt(2, candidateId);
                ps1.executeUpdate();

                // 2. UPDATE candidate vote_count
                String updateCandidate = "UPDATE candidates SET vote_count = vote_count + 1 WHERE id = ?";
                PreparedStatement ps2 = conn.prepareStatement(updateCandidate);
                ps2.setInt(1, candidateId);
                ps2.executeUpdate();

                // 3. UPDATE user has_voted
                String updateUser = "UPDATE users SET has_voted = 1 WHERE id = ?";
                PreparedStatement ps3 = conn.prepareStatement(updateUser);
                ps3.setInt(1, userId);
                ps3.executeUpdate();

                // 4. UPDATE voter_registry is_used
                String updateRegistry = "UPDATE voter_registry SET is_used = 1 WHERE voter_id = ?";
                PreparedStatement ps4 = conn.prepareStatement(updateRegistry);
                ps4.setString(1, voterId);
                ps4.executeUpdate();

                conn.commit();

                // Update session
                session.setAttribute("hasVoted", 1);
                response.sendRedirect("confirmed.jsp");

            } catch (Exception e) {
                conn.rollback();
                throw e;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("vote");
        }
    }
}
