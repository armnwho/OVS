<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*" %>
<%
  // Results page — requires a session to view
  if (session == null || session.getAttribute("userId") == null) {
    response.sendRedirect("verify-voter");
    return;
  }

  // Fetch live results from DB
  int totalVotes = 0;
  int totalRegistered = 0;
  String projectedLeader = "—";
  int maxVotes = 0;

  List<String> names = new ArrayList<>();
  List<String> parties = new ArrayList<>();
  List<Integer> voteCounts = new ArrayList<>();

  try {
    Connection conn = servlets.DBConnection.getConnection();

    // Get candidates
    PreparedStatement ps = conn.prepareStatement("SELECT name, vote_count FROM candidates ORDER BY id");
    ResultSet rs = ps.executeQuery();
    while (rs.next()) {
      String fullName = rs.getString("name");
      int vc = rs.getInt("vote_count");

      String cName = fullName;
      String cParty = "";
      int parenIdx = fullName.indexOf("(");
      if (parenIdx > 0) {
        cName = fullName.substring(0, parenIdx).trim();
        cParty = fullName.substring(parenIdx + 1, fullName.length() - 1).trim();
      }

      names.add(cName);
      parties.add(cParty);
      voteCounts.add(vc);
      totalVotes += vc;

      if (vc > maxVotes) {
        maxVotes = vc;
        projectedLeader = cName;
      }
    }
    rs.close();
    ps.close();

    // Get total registered voters
    PreparedStatement ps2 = conn.prepareStatement("SELECT COUNT(*) AS cnt FROM voter_registry");
    ResultSet rs2 = ps2.executeQuery();
    if (rs2.next()) {
      totalRegistered = rs2.getInt("cnt");
    }
    rs2.close();
    ps2.close();

    conn.close();
  } catch (Exception e) {
    e.printStackTrace();
  }

  double turnout = (totalRegistered > 0) ? ((double) totalVotes / totalRegistered) * 100 : 0;
  String turnoutStr = String.format("%.1f%%", turnout);
  if (maxVotes == 0) projectedLeader = "—";
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Live Election Results — National Electoral Commission">
  <meta http-equiv="refresh" content="10">
  <title>Live Election Results — National Electoral Commission</title>
  <link rel="stylesheet" href="css/style.css">
</head>
<body>

  <!-- Navbar -->
  <nav class="navbar">
    <a href="verify-voter" class="navbar-brand">
      <div class="brand-icon">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
      </div>
      <span>National Electoral Commission</span>
    </a>
    <div class="navbar-links">
      <a href="results.jsp">Live Results</a>
      <a href="logout" class="portal">Logout</a>
    </div>
  </nav>

  <!-- Results Header -->
  <div class="results-header">
    <h1>Live Election Results</h1>
    <div class="live-badge">
      <span class="live-dot"></span> Live Feed Active
    </div>
  </div>

  <!-- Stat Cards -->
  <div class="stats-grid">
    <div class="stat-card">
      <div class="stat-label">Turnout</div>
      <div class="stat-value"><%= turnoutStr %></div>
      <div class="stat-sub">of registered voters</div>
    </div>
    <div class="stat-card">
      <div class="stat-label">Total Votes Cast</div>
      <div class="stat-value"><%= totalVotes %></div>
      <div class="stat-sub">verified ballots</div>
    </div>
    <div class="stat-card">
      <div class="stat-label">Projected Leader</div>
      <div class="stat-value" style="font-size:1.5rem;"><%= projectedLeader %></div>
      <div class="stat-sub">leading candidate</div>
    </div>
  </div>

  <!-- Detailed Tally -->
  <div class="tally-section">
    <h2>Detailed Tally</h2>

    <% for (int i = 0; i < names.size(); i++) {
      int vc = voteCounts.get(i);
      double pct = (totalVotes > 0) ? ((double) vc / totalVotes) * 100 : 0;
      String pctStr = String.format("%.1f%%", pct);
      boolean isLeading = (vc == maxVotes && vc > 0);
    %>
    <div class="tally-card">
      <div class="tally-header">
        <span class="tally-name"><%= names.get(i) %></span>
        <span class="tally-percent"><%= pctStr %></span>
      </div>
      <div class="tally-party"><%= parties.get(i) %></div>
      <div class="tally-bar-track">
        <div class="tally-bar-fill<%= isLeading ? " leading" : "" %>" style="width: <%= pctStr %>;"></div>
      </div>
      <div class="tally-votes"><%= vc %> vote<%= vc != 1 ? "s" : "" %></div>
    </div>
    <% } %>
  </div>

</body>
</html>
