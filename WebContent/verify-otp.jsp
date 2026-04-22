<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  // Session check
  String pendingVoterId = (session != null) ? (String) session.getAttribute("pendingVoterId") : null;
  if (pendingVoterId == null) {
    response.sendRedirect("verify-voter");
    return;
  }

  String pendingName = (String) session.getAttribute("pendingName");
  String pendingPhone = (String) session.getAttribute("pendingPhone");
  String pendingEmail = (String) session.getAttribute("pendingEmail");

  // Mask phone: show first 3 and last 2 chars
  String maskedPhone = pendingPhone;
  if (pendingPhone != null && pendingPhone.length() > 5) {
    maskedPhone = pendingPhone.substring(0, 3) + "****" + pendingPhone.substring(pendingPhone.length() - 2);
  }

  // Mask email: show first 2 chars + *** + @domain
  String maskedEmail = pendingEmail;
  if (pendingEmail != null && pendingEmail.contains("@")) {
    int atIdx = pendingEmail.indexOf("@");
    maskedEmail = pendingEmail.substring(0, Math.min(2, atIdx)) + "***" + pendingEmail.substring(atIdx);
  }

  // Determine which step to show
  String step = request.getParameter("step");
  boolean showOtp = "otp".equals(step);

  // Check for OTP error
  String otpError = (session != null) ? (String) session.getAttribute("otpError") : null;
  if (otpError != null) session.removeAttribute("otpError");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="National Electoral Commission — Verify Your Identity">
  <title>Verify Identity — National Electoral Commission</title>
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
      <a href="#" class="portal">Official Portal</a>
    </div>
  </nav>

  <main class="page-center">

    <% if (!showOtp) { %>
    <!-- ============ STATE 1: Voter Info Confirmation ============ -->
    <div class="auth-card">
      <div class="card-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
          <path d="M9 12l2 2 4-4"/>
        </svg>
      </div>

      <h1>Voter Authentication</h1>
      <p class="card-subtitle">Access the digital ballot by entering your National Voter Registration Number.</p>

      <div class="voter-info-table">
        <div class="info-row">
          <span class="info-label">Voter</span>
          <span class="info-value"><%= pendingName %></span>
        </div>
        <div class="info-row">
          <span class="info-label">Phone</span>
          <span class="info-value"><%= maskedPhone %></span>
        </div>
        <div class="info-row">
          <span class="info-label">Email</span>
          <span class="info-value"><%= maskedEmail %></span>
        </div>
      </div>

      <p class="voter-info-note">To proceed, we will send a one-time passcode to both your registered phone and email.</p>

      <a href="verify-otp.jsp?step=otp" class="btn-primary" style="display:flex;align-items:center;justify-content:center;text-decoration:none;">Send Authentication Codes</a>

      <a href="verify-voter" class="link-secondary">Not you? Enter a different ID</a>
    </div>

    <% } else { %>
    <!-- ============ STATE 2: OTP Entry ============ -->
    <div class="auth-card">
      <div class="card-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round">
          <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
          <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
        </svg>
      </div>

      <h1>Dual Verification</h1>
      <p class="card-subtitle">Please enter the 6-digit codes sent to your registered phone and email address.</p>

      <% if (otpError != null) { %>
        <div class="error-msg"><%= otpError %></div>
      <% } %>

      <form action="verify-otp" method="POST" id="otpForm">
        <input type="hidden" name="phone_otp" id="phoneOtpHidden">
        <input type="hidden" name="email_otp" id="emailOtpHidden">

        <div class="otp-section">
          <div class="otp-label">Phone SMS Code</div>
          <div class="otp-boxes" id="phoneOtpBoxes">
            <input type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" class="otp-input" data-group="phone" data-index="0" autocomplete="off">
            <input type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" class="otp-input" data-group="phone" data-index="1" autocomplete="off">
            <input type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" class="otp-input" data-group="phone" data-index="2" autocomplete="off">
            <input type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" class="otp-input" data-group="phone" data-index="3" autocomplete="off">
            <input type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" class="otp-input" data-group="phone" data-index="4" autocomplete="off">
            <input type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" class="otp-input" data-group="phone" data-index="5" autocomplete="off">
          </div>
        </div>

        <div class="otp-section">
          <div class="otp-label">Email Code</div>
          <div class="otp-boxes" id="emailOtpBoxes">
            <input type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" class="otp-input" data-group="email" data-index="0" autocomplete="off">
            <input type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" class="otp-input" data-group="email" data-index="1" autocomplete="off">
            <input type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" class="otp-input" data-group="email" data-index="2" autocomplete="off">
            <input type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" class="otp-input" data-group="email" data-index="3" autocomplete="off">
            <input type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" class="otp-input" data-group="email" data-index="4" autocomplete="off">
            <input type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" class="otp-input" data-group="email" data-index="5" autocomplete="off">
          </div>
        </div>

        <button type="submit" class="btn-primary">Access Ballot</button>
      </form>
    </div>
    <% } %>

    <!-- Footer -->
    <div class="page-footer">
      <div class="footer-title">Secure Voting System</div>
      <div class="footer-sub">Protected by end-to-end encryption. Your privacy is guaranteed.</div>
    </div>
  </main>

  <script>
    // OTP box auto-focus and assembly logic
    document.querySelectorAll('.otp-input').forEach(function(input) {
      input.addEventListener('input', function() {
        // Only allow digits
        this.value = this.value.replace(/[^0-9]/g, '');
        if (this.value.length === 1) {
          // Move to next input in same group
          var group = this.getAttribute('data-group');
          var idx = parseInt(this.getAttribute('data-index'));
          var next = document.querySelector('.otp-input[data-group="' + group + '"][data-index="' + (idx + 1) + '"]');
          if (next) next.focus();
        }
      });

      input.addEventListener('keydown', function(e) {
        if (e.key === 'Backspace' && this.value === '') {
          var group = this.getAttribute('data-group');
          var idx = parseInt(this.getAttribute('data-index'));
          var prev = document.querySelector('.otp-input[data-group="' + group + '"][data-index="' + (idx - 1) + '"]');
          if (prev) {
            prev.focus();
            prev.value = '';
          }
        }
      });

      // Handle paste for entire OTP
      input.addEventListener('paste', function(e) {
        e.preventDefault();
        var paste = (e.clipboardData || window.clipboardData).getData('text').replace(/[^0-9]/g, '');
        var group = this.getAttribute('data-group');
        var startIdx = parseInt(this.getAttribute('data-index'));
        for (var i = 0; i < paste.length && (startIdx + i) < 6; i++) {
          var target = document.querySelector('.otp-input[data-group="' + group + '"][data-index="' + (startIdx + i) + '"]');
          if (target) target.value = paste[i];
        }
        var lastIdx = Math.min(startIdx + paste.length, 5);
        var lastInput = document.querySelector('.otp-input[data-group="' + group + '"][data-index="' + lastIdx + '"]');
        if (lastInput) lastInput.focus();
      });
    });

    // Auto-focus first phone OTP box
    var firstInput = document.querySelector('.otp-input[data-group="phone"][data-index="0"]');
    if (firstInput) firstInput.focus();

    // Assemble hidden inputs on form submit
    var form = document.getElementById('otpForm');
    if (form) {
      form.addEventListener('submit', function(e) {
        var phoneOtp = '';
        var emailOtp = '';
        for (var i = 0; i < 6; i++) {
          var pInput = document.querySelector('.otp-input[data-group="phone"][data-index="' + i + '"]');
          var eInput = document.querySelector('.otp-input[data-group="email"][data-index="' + i + '"]');
          phoneOtp += (pInput ? pInput.value : '');
          emailOtp += (eInput ? eInput.value : '');
        }
        document.getElementById('phoneOtpHidden').value = phoneOtp;
        document.getElementById('emailOtpHidden').value = emailOtp;
      });
    }
  </script>

</body>
</html>
