<%@ page contentType="text/html;charset=UTF-8" language="java" %>
  <% 
    // Clear any existing authenticated session if user navigates back here 
    String verifyError=null; 
    if (session !=null) { 
      verifyError=(String) session.getAttribute("verifyError"); 
      if (verifyError !=null)
        session.removeAttribute("verifyError"); 
    } 
  %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta name="description" content="National Electoral Commission — Secure Online Voting System">
      <title>Voter Authentication — National Electoral Commission</title>
      <link rel="stylesheet" href="css/style.css">
    </head>

    <body>

      <!-- Navbar -->
      <nav class="navbar">
        <a href="verify-voter" class="navbar-brand">
          <div class="brand-icon">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
              stroke-linecap="round" stroke-linejoin="round">
              <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
            </svg>
          </div>
          <span>National Electoral Commission</span>
        </a>
        <div class="navbar-links">
          <a href="results.jsp">Live Results</a>
          <a href="#" class="portal">Official Portal</a>
        </div>
      </nav>

      <!-- Page Content -->
      <main class="page-center">
        <div class="auth-card">

          <!-- Shield checkmark icon -->
          <div class="card-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.2" stroke-linecap="round"
              stroke-linejoin="round">
              <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
              <path d="M9 12l2 2 4-4" />
            </svg>
          </div>

          <h1>Voter Authentication</h1>
          <p class="card-subtitle">Access the digital ballot by entering your National Voter Registration Number.</p>

          <% if (verifyError !=null) { %>
            <div class="error-msg">
              <%= verifyError %>
            </div>
            <% } %>

              <form action="verify-voter" method="POST">
                <div class="form-group">
                  <label for="voter_id">Voter Registration ID</label>
                  <input type="text" id="voter_id" name="voter_id" placeholder="e.g. VUP47392" autocomplete="off"
                    required>
                </div>
                <button type="submit" class="btn-primary">Verify Identity</button>
              </form>
        </div>

        <!-- Footer -->
        <div class="page-footer">
          <div class="footer-title">Secure Voting System</div>
          <div class="footer-sub">Protected by end-to-end encryption. Your privacy is guaranteed.</div>
        </div>
      </main>

    </body>

    </html>