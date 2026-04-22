<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*" %>
<%
  // Session check
  if (session == null || session.getAttribute("userId") == null) {
    response.sendRedirect("verify-voter");
    return;
  }

  Integer hasVoted = (Integer) session.getAttribute("hasVoted");
  if (hasVoted != null && hasVoted == 1) {
    response.sendRedirect("results.jsp");
    return;
  }

  String username = (String) session.getAttribute("username");

  // Load candidates from DB
  List<int[]> candidateIds = new ArrayList<>();
  List<String> candidateNames = new ArrayList<>();

  try {
    Connection conn = servlets.DBConnection.getConnection();
    PreparedStatement ps = conn.prepareStatement("SELECT id, name FROM candidates ORDER BY id");
    ResultSet rs = ps.executeQuery();
    while (rs.next()) {
      candidateIds.add(new int[]{rs.getInt("id")});
      candidateNames.add(rs.getString("name"));
    }
    rs.close();
    ps.close();
    conn.close();
  } catch (Exception e) {
    e.printStackTrace();
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Cast your official vote — National Electoral Commission">
  <title>Cast Your Vote — National Electoral Commission</title>
  <link rel="stylesheet" href="css/style.css">
</head>
<body>

  <!-- Ballot Banner -->
  <div class="ballot-banner">
    <div class="banner-left">
      <h2>Official Digital Ballot</h2>
      <p>Elector: <%= username %></p>
    </div>
    <div class="banner-right">
      <div class="status-label">Status</div>
      <div class="status-badge">
        <span class="status-dot"></span> Authenticated
      </div>
    </div>
  </div>

  <!-- Vote Content -->
  <div class="vote-content">
    <h1>Select Candidate</h1>
    <p class="vote-subtitle">Review the candidates carefully. You may only cast one vote, and this action cannot be undone.</p>

    <form id="voteForm" action="vote" method="POST">
      <input type="hidden" name="candidate_id" id="selectedCandidateId">

      <div class="candidate-list">
        <% for (int i = 0; i < candidateNames.size(); i++) {
          int cId = candidateIds.get(i)[0];
          String fullName = candidateNames.get(i);
          // Parse party from format "Name (Party)"
          String cName = fullName;
          String cParty = "";
          int parenIdx = fullName.lastIndexOf("(");
          if (parenIdx > 0) {
            cName = fullName.substring(0, parenIdx).trim();
            cParty = fullName.substring(parenIdx + 1, fullName.length() - 1).trim();
          }
        %>
        <div class="candidate-row" data-id="<%= cId %>" data-name="<%= cName %>" data-party="<%= cParty %>" onclick="selectCandidate(this)">
          <div class="radio-circle"></div>
          <input type="radio" name="candidate" value="<%= cId %>">
          <div class="candidate-info">
            <div class="candidate-name"><%= cName %></div>
            <div class="candidate-party"><%= cParty %></div>
            <div class="candidate-role">Prime Minister Candidate</div>
          </div>
        </div>
        <% } %>
      </div>

      <button type="button" class="btn-submit-ballot" id="reviewBtn" onclick="openModal()">Review &amp; Submit Ballot</button>
    </form>
  </div>

  <!-- Confirmation Modal -->
  <div class="modal-overlay" id="confirmModal">
    <div class="modal-content">
      <button class="modal-close" onclick="closeModal()">&times;</button>
      <h2>Confirm Selection</h2>
      <p class="modal-desc">You are about to cast your official vote for:</p>

      <div class="modal-candidate-card">
        <div class="mc-name" id="modalCandidateName"></div>
        <div class="mc-party" id="modalCandidateParty"></div>
      </div>

      <div class="modal-warning">This action is final and cannot be altered.</div>

      <div class="modal-actions">
        <button type="button" class="btn-cancel" onclick="closeModal()">Return to Ballot</button>
        <button type="button" class="btn-confirm" onclick="castVote()">Cast Official Vote</button>
      </div>
    </div>
  </div>

  <script>
    var selectedId = null;
    var selectedName = '';
    var selectedParty = '';

    function selectCandidate(row) {
      // Deselect all
      document.querySelectorAll('.candidate-row').forEach(function(r) {
        r.classList.remove('selected');
        r.querySelector('input[type="radio"]').checked = false;
      });

      // Select this one
      row.classList.add('selected');
      row.querySelector('input[type="radio"]').checked = true;

      selectedId = row.getAttribute('data-id');
      selectedName = row.getAttribute('data-name');
      selectedParty = row.getAttribute('data-party');
    }

    function openModal() {
      if (!selectedId) {
        alert('Please select a candidate before submitting.');
        return;
      }
      document.getElementById('modalCandidateName').textContent = selectedName;
      document.getElementById('modalCandidateParty').textContent = selectedParty;
      document.getElementById('confirmModal').classList.add('active');
    }

    function closeModal() {
      document.getElementById('confirmModal').classList.remove('active');
    }

    function castVote() {
      document.getElementById('selectedCandidateId').value = selectedId;
      document.getElementById('voteForm').submit();
    }

    // Close modal on overlay click
    document.getElementById('confirmModal').addEventListener('click', function(e) {
      if (e.target === this) closeModal();
    });

    // Close modal on Escape key
    document.addEventListener('keydown', function(e) {
      if (e.key === 'Escape') closeModal();
    });
  </script>

</body>
</html>
