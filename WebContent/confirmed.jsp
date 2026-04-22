<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  // Session check — must be logged in and must have voted
  if (session == null || session.getAttribute("userId") == null) {
    response.sendRedirect("verify-voter");
    return;
  }

  Integer hasVoted = (Integer) session.getAttribute("hasVoted");
  if (hasVoted == null || hasVoted != 1) {
    response.sendRedirect("vote");
    return;
  }

  String username = (String) session.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Vote Confirmed — National Electoral Commission">
  <title>Vote Recorded — National Electoral Commission</title>
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

  <!-- Page Content -->
  <main class="page-center">
    <div class="confirmed-card">
      <!-- Green top stripe -->
      <div class="green-stripe"></div>

      <!-- Checkmark icon -->
      <div class="confirmed-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M5 13l4 4L19 7"/>
        </svg>
      </div>

      <h1 class="confirmed-title">Vote Recorded</h1>
      <p class="confirmed-subtitle">Your ballot has been securely encrypted and deposited into the digital urn.</p>

      <!-- Confirmation Receipt -->
      <div class="receipt-box">
        <div class="receipt-label">Confirmation Receipt</div>
        <div class="receipt-hash" id="receiptHash"></div>
      </div>

      <p class="confirmed-thanks">Thank you for participating in the electoral process, <%= username %>.</p>

      <!-- Action Buttons -->
      <div class="confirmed-actions">
        <a href="logout" class="btn-outline">Exit Session</a>
        <a href="results.jsp" class="btn-solid">View Live Results</a>
      </div>
    </div>

    <!-- Footer -->
    <div class="page-footer">
      <div class="footer-title">Secure Voting System</div>
      <div class="footer-sub">Protected by end-to-end encryption. Your privacy is guaranteed.</div>
    </div>
  </main>

  <script>
    // Generate a random receipt hash similar to the Replit UI
    function generateHash() {
      var chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      var parts = [];
      for (var p = 0; p < 4; p++) {
        var segment = '';
        for (var i = 0; i < 8; i++) {
          segment += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        parts.push(segment);
      }
      return parts.join('-');
    }
    document.getElementById('receiptHash').textContent = generateHash();
  </script>

</body>
</html>
