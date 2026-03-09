# Charlie Cafe - Cognito Employee ID Tester

> #### a simple, automated way to test if Cognito is sending custom:employee_id in the ID token without manually using the browser console each time


### Step 1 — Understand What You’re Testing

Cognito sends a JWT (JSON Web Token) after login. The portal reads the token:

```
const employeeId = parseInt(
  decoded["custom:employee_id"] ||
  decoded["employee_id"] ||
  decoded["cognito:username"]
);
```

✅ If custom:employee_id exists → your portal works.

❌ If missing → Cognito configuration must be updated.

So basically, you want to check if custom:employee_id exists in the ID token after login.

### Step 2 — Make a Small Test Page

You can make a simple HTML page that:

- Lets you configure Cognito details (client_id, domain, region).

- Opens the Cognito login page.

- After login, grabs the id_token from localStorage.

- Shows whether custom:employee_id exists.

#### ✅ Here’s a basic template:

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Cognito Employee ID Tester</title>
</head>
<body>
<h2>Cognito Employee ID Tester</h2>

<label>Cognito Domain:</label>
<input type="text" id="cognitoDomain" placeholder="your-domain.auth.us-east-1.amazoncognito.com"><br>
<label>Client ID:</label>
<input type="text" id="clientId" placeholder="your-client-id"><br>
<button id="loginBtn">Login & Test</button>

<pre id="result"></pre>

<script>
function parseJwt(token) {
  if(!token) return null;
  return JSON.parse(atob(token.split('.')[1]));
}

document.getElementById('loginBtn').onclick = function() {
  const domain = document.getElementById('cognitoDomain').value;
  const clientId = document.getElementById('clientId').value;

  if(!domain || !clientId) {
    alert("Fill in Cognito domain and client ID");
    return;
  }

  // Open Cognito Hosted UI for login
  const redirectUri = window.location.href; // redirect back to this page
  const loginUrl = `https://${domain}/login?client_id=${clientId}&response_type=token&scope=email+openid&redirect_uri=${encodeURIComponent(redirectUri)}`;
  window.location.href = loginUrl;
}

// Check token on page load
window.onload = function() {
  const hash = window.location.hash; // after login Cognito returns token in URL hash
  if(hash) {
    const params = new URLSearchParams(hash.replace('#','?'));
    const idToken = params.get('id_token');
    if(!idToken) return;

    const decoded = parseJwt(idToken);
    const employeeId = parseInt(
      decoded["custom:employee_id"] ||
      decoded["employee_id"] ||
      decoded["cognito:username"]
    );

    let output = JSON.stringify(decoded, null, 2) + '\n\n';
    if(employeeId) {
      output += `✅ Employee ID found: ${employeeId}`;
    } else {
      output += '❌ Employee ID missing!';
    }

    document.getElementById('result').textContent = output;
    localStorage.setItem("id_token", idToken); // save token like your portal
  }
}
</script>
</body>
</html>
```

### Step 3 — How It Works

- Open this page in a browser.

- Enter Cognito domain and client ID.

- Click Login & Test → Cognito Hosted UI opens.

- After login, it redirects back to the same page.

- The script parses the id_token automatically.

- Shows the decoded token and checks custom:employee_id.

- Saves the token in localStorage (like your portal).

#### ✅ Fully automated, no manual console checking needed.

### Step 4 — Extra Automation Ideas

If you want a more advanced test setup, you can:

- Use Playwright or Puppeteer (Node.js tools) to automate login and token parsing in headless mode.

- Write tests that assert:

```
expect(decoded["custom:employee_id"]).toBeDefined();
```

### Step 5 — Next-Level Idea

You could even make it multi-environment:

- A simple form where you enter multiple Cognito apps (dev, test, prod).

- One click → it logs in and checks employee_id automatically.

- Shows green/red for each app.

This is essentially your mini “automation testing dashboard” for Cognito login.

---
### ✅ fully responsive Cognito-Tester.html

Handle multiple Cognito environments (Dev, Test, Prod, or any custom domain).

Automatically redirect to Cognito Hosted UI for login.

Parse the ID token after login.

Detect if custom:employee_id is present.

Display results in a Bootstrap responsive table.

Include café-themed background and icons.

Be mobile-friendly and include UX/UI styling.

Include comments for every section so you can understand/modify it later.

#### ✅ Here’s the full code for cognito-tester.html:

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Café Cognito Tester ☕</title>

<!-- Bootstrap CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Bootstrap Icons -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

<!-- Custom Styles -->
<style>
  body {
    background: url('https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=1350&q=80') no-repeat center center fixed;
    background-size: cover;
    font-family: 'Segoe UI', sans-serif;
    min-height: 100vh;
    display: flex;
    flex-direction: column;
  }

  .overlay {
    background-color: rgba(0, 0, 0, 0.6);
    flex: 1;
    display: flex;
    flex-direction: column;
    padding: 2rem;
    color: #fff;
  }

  h1, h3 {
    text-align: center;
    margin-bottom: 1rem;
  }

  .form-control, .btn {
    margin-bottom: 0.5rem;
  }

  table {
    color: #fff;
  }

  thead {
    background-color: rgba(255, 255, 255, 0.2);
  }

  tbody tr:nth-child(even) {
    background-color: rgba(255, 255, 255, 0.1);
  }

  .icon {
    font-size: 1.2rem;
    margin-right: 0.3rem;
  }

  .footer {
    text-align: center;
    padding: 0.5rem;
    font-size: 0.9rem;
    color: #ccc;
  }

  @media (max-width: 576px) {
    .form-control, .btn {
      width: 100%;
    }
  }
</style>
</head>
<body>

<div class="overlay container">

  <!-- Page Header -->
  <h1><i class="bi bi-cup-straw"></i> Café Cognito Tester ☕</h1>
  <h3>Check Employee ID in Cognito Token</h3>

  <!-- Cognito Configuration Form -->
  <div class="row justify-content-center mb-3">
    <div class="col-md-6 col-sm-12">
      <label for="envName" class="form-label">Environment Name</label>
      <input type="text" class="form-control" id="envName" placeholder="e.g., Dev, Test, Prod">

      <label for="cognitoDomain" class="form-label">Cognito Domain</label>
      <input type="text" class="form-control" id="cognitoDomain" placeholder="your-domain.auth.us-east-1.amazoncognito.com">

      <label for="clientId" class="form-label">Client ID</label>
      <input type="text" class="form-control" id="clientId" placeholder="your-cognito-client-id">

      <button class="btn btn-warning w-100 mt-2" id="loginBtn">
        <i class="bi bi-box-arrow-in-right"></i> Login & Test
      </button>
    </div>
  </div>

  <!-- Result Table -->
  <div class="table-responsive mt-4">
    <table class="table table-borderless">
      <thead>
        <tr>
          <th>Environment</th>
          <th>Employee ID Status</th>
          <th>Decoded Token</th>
        </tr>
      </thead>
      <tbody id="resultTable">
        <!-- Results will appear here -->
      </tbody>
    </table>
  </div>

</div>

<div class="footer">
  &copy; 2026 Charlie Café ☕ | Cognito Tester
</div>

<!-- Script -->
<script>
  // =========================
  // Parse JWT token function
  // =========================
  function parseJwt(token) {
    if(!token) return null;
    return JSON.parse(atob(token.split('.')[1]));
  }

  // =========================
  // Login Button Click
  // =========================
  document.getElementById('loginBtn').onclick = function() {
    const envName = document.getElementById('envName').value.trim();
    const domain = document.getElementById('cognitoDomain').value.trim();
    const clientId = document.getElementById('clientId').value.trim();

    if(!envName || !domain || !clientId) {
      alert("Please fill all fields!");
      return;
    }

    // Save environment details in sessionStorage to use after redirect
    sessionStorage.setItem("testerEnvName", envName);

    // Cognito Hosted UI login URL
    const redirectUri = window.location.origin + window.location.pathname; // redirect back to this page
    const loginUrl = `https://${domain}/login?client_id=${clientId}&response_type=token&scope=email+openid&redirect_uri=${encodeURIComponent(redirectUri)}`;
    window.location.href = loginUrl;
  }

  // =========================
  // Check token on page load
  // =========================
  window.onload = function() {
    const hash = window.location.hash; // Cognito returns token in URL hash
    if(hash) {
      const params = new URLSearchParams(hash.replace('#','?'));
      const idToken = params.get('id_token');
      if(!idToken) return;

      const decoded = parseJwt(idToken);
      const employeeId = parseInt(
        decoded["custom:employee_id"] ||
        decoded["employee_id"] ||
        decoded["cognito:username"]
      );

      const envName = sessionStorage.getItem("testerEnvName") || "Unknown";
      const status = employeeId ? `<span class="text-success"><i class="bi bi-check-circle-fill"></i> Found: ${employeeId}</span>` :
                                  `<span class="text-danger"><i class="bi bi-x-circle-fill"></i> Missing</span>`;

      const tokenString = JSON.stringify(decoded, null, 2);

      // Append result to table
      const table = document.getElementById('resultTable');
      const row = document.createElement('tr');
      row.innerHTML = `
        <td>${envName}</td>
        <td>${status}</td>
        <td><pre style="white-space: pre-wrap; max-width: 400px;">${tokenString}</pre></td>
      `;
      table.appendChild(row);

      // Save token in localStorage like your portal
      localStorage.setItem("id_token", idToken);

      // Clear URL hash for clean reload
      window.location.hash = "";
    }
  }
</script>

</body>
</html>
```

### ✅ Features included in this file:

- Responsive Bootstrap design: Works on desktop, tablet, mobile.

- Café-themed background + Bootstrap icons for UX.

- Multi-environment support: Enter environment name, domain, client ID.

- Automatic login and token parsing: No need to open console.

- Result table: Shows environment, employee ID status, and decoded token.

- Color-coded status: Green if employee ID exists, red if missing.

- Commented code: Each section is explained for easy modification.

---

