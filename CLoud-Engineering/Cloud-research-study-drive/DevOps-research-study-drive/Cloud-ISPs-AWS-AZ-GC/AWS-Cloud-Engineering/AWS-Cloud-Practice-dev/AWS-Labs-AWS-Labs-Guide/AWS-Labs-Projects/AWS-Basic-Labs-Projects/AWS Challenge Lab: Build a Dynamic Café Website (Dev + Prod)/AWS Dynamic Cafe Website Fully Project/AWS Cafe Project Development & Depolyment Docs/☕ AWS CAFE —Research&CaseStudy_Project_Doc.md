# ☕ AWS CAFE — Research & CaseStudy Project Doc

**Dev → Serverless → Secure → Scalable → Cost-Controlled**

**Author & Architecture Designer:** Charlie

**Level:** Beginner → Advanced (Production-grade)

**Approach:** AWS Console First • No Skipped Steps • Exam + Real-World Safe

---

## ☕ AWS Drinking Café Project— Full Hands-On Lab Tasks 

### 🧩 Architecture & System Design

- Designed a production-grade, event-driven cloud architecture for a dynamic café ordering platform

- Implemented dual backend architecture using EC2 + ALB and API Gateway + Lambda

- Integrated CloudFront CDN with multiple origins and path-based routing

- Applied zero-risk incremental deployment strategy for feature expansion

### ⚙️ Backend Engineering (Serverless & Compute)

- Built serverless order processing APIs using AWS Lambda (Python)

- Implemented asynchronous order processing using Amazon SQS

- Developed worker Lambda for background order handling and status updates

- Designed idempotent order workflows with unique order tracking IDs

### 🗄️ Data & Persistence Layer

- Designed relational database schema for orders, items, and billing

- Integrated Amazon RDS (MySQL) for transactional order storage

- Implemented order status persistence for real-time and historical tracking

- Optimized database access using VPC-secured connectivity

### 🌐 API Management & Integration

- Designed RESTful APIs for order placement, order status, and menu retrieval

- Implemented CORS-enabled API Gateway for frontend integration

- Secured API endpoints using IAM-based permissions

- Enabled CloudFront-accelerated API delivery

### 🖥️ Frontend & Customer Experience

- Developed customer order tracking & billing dashboard (frontend-only, zero-risk)

- Implemented real-time order status lookup using unique order IDs

- Built print-ready billing & receipt system

- Integrated frontend seamlessly with both EC2 and serverless backends

### 🔐 Security & Secrets Management

- Implemented Secrets Manager–based credential management

- Enforced least-privilege IAM policies across Lambda, EC2, and SQS

- Secured backend services using VPC isolation and security groups

- Delivered HTTPS-only application flow via CloudFront and ALB

### 🚀 CI/CD & Automation

- Implemented end-to-end CI/CD pipeline using AWS CodePipeline

- Automated Lambda build & deployment using CodeBuild

- Enabled version-controlled infrastructure updates via GitHub

- Reduced manual deployment risk through pipeline-driven releases

### 📊 Monitoring, Reliability & Operations

- Implemented CloudWatch logging and metrics for Lambdas and SQS

- Monitored order throughput, failures, and queue backlogs

- Configured alerts for system failures and performance degradation

- Validated system reliability through end-to-end workflow testing

### 📦 Performance, Scaling & Cost Awareness

- Applied CloudFront caching strategies for static and dynamic content

- Optimized API performance with cache-controlled GET endpoints

- Designed architecture fully within AWS Free Tier constraints

- Balanced cost, scalability, and availability for real-world usage

### 🏁 Production Readiness & Portfolio Delivery

- Delivered a portfolio-ready, real-world cloud application

- Created modular, extensible architecture suitable for future microservices

- Documented full system design and workflows in Markdown

- Prepared project for technical interviews, demos, and cloud assessments
---



## ☕ Charlie Café SECTION 5️⃣ – Secure HR & Attendance System
> **📄 ☕ AWS Charlie Café – Secure HR & Attendance System.md


# ☕ Charlie Café SECTION 1️⃣ - Research & Development

## PHASE 1️⃣ System Scope

### 1️⃣ Attendance Management

- Employee daily check-in and check-out

- Automatic capture of:

    - Date

    - Time

    - Employee ID

- Centralized attendance records stored in RDS

- Admin/HR dashboard to view:

    - Daily attendance

    - Weekly summary

    - Monthly summary

### 2️⃣ Employee Portal

- Secure employee login using Amazon Cognito

- Employee can:

    - View personal attendance history

    - View approved leaves

    - View official café holidays

    - View HR profile information:

        - Job title

        - Salary

        - Start date

### 3️⃣ Access Control & Security

- Application access restricted using Security Groups

- 1️⃣ Frontend EC2:

    - HTTP/HTTPS allowed only from allowed IP ranges (practice lab)

- 2️⃣ Backend services protected using:

    - API Gateway authorization

    - Cognito JWT validation

- 3️⃣ Database access:

    - RDS accessible only from Lambda security group

## PHASE 2️⃣ Architecture Overview   

### 1️⃣ Frontend Layer

- Hosted on **EC2 Apache Web Server**

- Pages:

    - Attendance Check-In / Check-Out page (tablet/kiosk style)

    - Employee Portal page

    - Admin / HR Dashboard page

- Frontend communicates with backend using API Gateway endpoints

### 2️⃣ Backend Layer

#### 1️⃣ AWS API Gateway (REST API)

#### 2️⃣ AWS Lambda functions:

    - checkin

    - checkout

    - employeeProfile

    - attendanceHistory

    - leavesAndHolidays

#### 3️⃣ Amazon Cognito:

    - User authentication

    - JWT-based access control for APIs


## PHASE 3️⃣ Database Layer (RDS)

### 1️⃣ Database Type

    - MySQL or PostgreSQL

### 2️⃣ Tables

#### 1️⃣ employees

    - employee_id

    - name

    - job_title

    - salary

    - start_date

    - cognito_user_id

#### 2️⃣ attendance

    - attendance_id

    - employee_id

    - date

    - checkin_time

    - checkout_time

#### 3️⃣ leaves

    - leave_id

    - employee_id

    - leave_date

    - leave_type

#### 4️⃣ holidays

    - holiday_date

    - description

## PHASE 4️⃣ Frontend Pages

### 1️⃣ A) Attendance Check-In / Check-Out Page

    - Tablet-friendly layout

    - Employee authentication via Cognito

    - Buttons:

        - Check-In

        - Check-Out

    - Auto timestamp capture

    - Success / error notification

### 2️⃣ B) Employee Portal Page

    - Authenticated access only

    - Sections:

        - Employee profile summary

        - Attendance table

        - Leaves and holidays list

#### Displayed Data Example

```
Employee Name: Alice
Job Title: Barista
Salary: 40,000 / month

Attendance:
Date        | Check-In | Check-Out
2026-01-19  | 09:00    | 17:00
2026-01-18  | 09:10    | 17:00

Leaves:
- 2026-01-15 | Sick Leave
- 2026-01-01 | Public Holiday
```

### 2️⃣ C) Admin / HR Dashboard

    - Secure Cognito-admin access

    - View:

        - Daily attendance

        - Weekly summary

        - Monthly summary

    - Employee-wise filtering

    - Export-ready table structure (future use)


## PHASE 5️⃣ API Endpoints (API Gateway + Lambda)

    - POST /api/checkin

    - POST /api/checkout

    - GET /api/employee/profile

    - GET /api/attendance

    - GET /api/leaves-holidays

#### Security

    - Cognito Authorizer enabled

    - JWT required for all endpoints

## PHASE 6️⃣ Security Configuration

### 1️⃣ Security Groups

#### 1️⃣ Frontend EC2

    - Allow HTTP/HTTPS from allowed IP ranges

#### 2️⃣ Lambda

    - Allow outbound access to RDS

#### 3️⃣ RDS

    - Allow inbound only from Lambda security group

### 2️⃣ Authentication & Authorization

    - Amazon Cognito User Pool

    - Role-based access:

        - Employee

        - Admin / HR

    - JWT validation enforced at API Gateway

## PHASE 7️⃣ Deployment Alignment

    - Frontend deployed on existing EC2 Apache server

    - Backend integrated into existing API Gateway + Lambda

    - Authentication integrated with existing Cognito

    - Database hosted in existing RDS

    - Logging via CloudWatch

## PHASE 8️⃣ Completion Outcome

    - Fully integrated internal café attendance system

    - Professional AWS architecture aligned with real job requirements

    - Secure, scalable, and production-style setup

    - Completes the final 20% of the Charlie Café lab



> **🟢 SECTION 1️⃣  R & D COMPLETE**
---
## ☕ Charlie Café PHASE 2️⃣ — New AWS Lambda Functions (Full Configuration)

### 🎯 What We Are Creating in This Part

#### You will create 5 NEW Lambda functions:

- hr-checkin

- hr-checkout

- hr-employee-profile

- hr-attendance-history

- hr-leaves-holidays

#### Each Lambda will:

- Use existing RDS (cafedb)

- Be protected by existing Cognito

- Be callable from existing API Gateway

- Follow real job-level backend standards


> **🟢 PHASE 2️⃣  R & D COMPLETE**
---
## ☕ Charlie Café PHASE 4️⃣ — Frontend Pages for HR System

### 1️⃣ Employee Check-In / Check-Out Page (Tablet Friendly)

#### 1️⃣ File: checkin.html

✅ Designed for tablet / kiosk

✅ Uses Bootstrap 5

✅ Café-style background

✅ Works with API Gateway + Lambda + RDS

✅ Employee ID input + Submit

✅ Fully commented (no guessing later)

#### 2️⃣ ✅ Why This Is Correct for a REAL Café Lab

✔ No Cognito needed (kiosk logic)

✔ Works inside Security Group–restricted EC2

✔ Simple for staff (ID + 1 tap)

✔ Backend already handles validation

✔ Tablet-friendly (big buttons)

✔ Professional café branding

### 2️⃣ Employee Portal Page

☕ Café-style look (same visual identity as admin & check-in pages)

📱 Fully responsive Bootstrap 5 layout

🔐 Cognito + API Gateway logic preserved (no backend changes)

🧱 Clean cards instead of plain tables

💬 Detailed comments everywhere (frontend-learning friendly)

1️⃣ Logout button (Cognito-based)

2️⃣ Today’s attendance status badge

3️⃣ Download attendance as PDF (client-side)

4️⃣ Dark / Light café mode toggle

#### ✅ What This Page Now Represents (Job-Ready)

✔ Consistent Charlie Café branding

✔ Secure Cognito-protected employee portal

✔ Clean, readable UI for non-technical staff

✔ Fully responsive (mobile / tablet / desktop)

✔ Perfect match with your AWS lab architecture

### 3️⃣ ☕ FINAL ADMIN DASHBOARD (CAFÉ THEME)

#### ✅ Features of This Admin Dashboard

☑️ Responsive sidebar using Bootstrap

☑️ Sidebar buttons:

    ✔️ Dashboard (default view)

    ✔️ Attendance Management

    ✔️ Employees

    ✔️ Leaves & Holidays

    ✔️ Reports

    ✔️ Logout button at bottom of sidebar

☑️ Main content area:

    ✔️ Attendance summary table (dynamic)

    ✔️ Leaves & Holidays table (dynamic)

    ✔️ Placeholder for Employees & Reports pages

☑️ Café theme colors (dark sidebar + gold hover)

☑️ Fully responsive — works on mobile and desktop

☑️ Fully commented for easy future development

☑️  You can directly upload this file to /var/www/html/

☑️  No backend changes required

✅ Newly Added to ADMIN page

    1️⃣ Cognito Logout button

    2️⃣ Today’s café attendance status badge

    3️⃣ Download attendance report (PDF)

    4️⃣ Dark / Light café theme toggle

### 4️⃣ — HOW LOGOUT INTEGRATES WITH COGNITO (STEP-BY-STEP)

> **✅ this logout design and logic applies to BOTH the Admin page and the Employee page in your Charlie Café HR system.**

#### 🔐 What Logout Actually Does

Cognito stores the login session in browser storage.
Logout means destroying that session.

#### ✅ CONFIRMATION: SAME LOGOUT LOGIC FOR ADMIN & EMPLOYEE

✔ Admin Portal → uses Cognito Admin group

✔ Employee Portal → uses Cognito Employee group

✔ Logout behavior → IDENTICAL for both

The difference is NOT logout, the difference is authorization (groups & APIs).

#### 🔐 WHAT LOGOUT DOES (RECONFIRMED)

Your understanding is correct 👇

Cognito Stores These After Login:

- ID Token

- Access Token

- Refresh Token

**🌐 Stored by Amazon Cognito JS SDK in browser storage.**

#### 🚪 SINGLE LINE THAT LOGS OUT THE USER

```
user.signOut();
```

#### What this instantly does:

❌ Deletes tokens from browser

❌ Invalidates Cognito session

❌ getCurrentUser() becomes null

This is true for admin and employee both.

#### 🛡️ PAGE PROTECTION (MOST IMPORTANT PART)

You already have (or must have) this on EVERY protected page:

```
const user = userPool.getCurrentUser();
if (!user) {
    window.location.href = "login.html";
}
```

#### Why this matters

- After logout → session gone

- User presses Back button

- ❌ Page must NOT load

- ✅ Redirects to login / home page

#### This is mandatory on:

- admin-dashboard.html

- employee-portal.html

#### 🔘 STANDARD LOGOUT BUTTON (SAME FOR BOTH)
> **HTML (Admin & Employee)**

```
<button class="btn btn-outline-light" onclick="logout()">Logout</button>
```

#### JavaScript

```
function logout() {
    const user = userPool.getCurrentUser();
    if (user) {
        user.signOut();
    }
    window.location.href = "index.html"; // café landing or login
}
```

✔ Works for Admin

✔ Works for Employee

✔ Works on mobile / desktop

✔ Secure & Cognito-approved

> **🟢 PHASE 3️⃣  R & D COMPLETE**
---
## ☕ Charlie Café PHASE 5️⃣ Secure Frontend & API Integration with Production Hardening
> **Frontend & Backend Security, API Integration, and Role-Based UI (Production Ready)**

### 1️⃣ Goal

- Integrate frontend pages (Admin + Employee) with backend APIs

- Enforce role-based UI & API access (Admin vs Employee)

- Add production-level hardening: error handling, loaders, JWT expiration, centralized config, secure backend checks, and logging

- Make the system job-ready, secure, and maintainable

### 2️⃣ Architecture Flow

```
[Frontend Admin/Employee Pages]
          |
          | secureFetch (with JWT)
          v
[API Gateway] -> Cognito Authorizer
          |
          v
[Lambdas (Checkin, Checkout, Employee Info, Leaves, Admin Employees)]
          |
          v
[RDS Database / DynamoDB]
```

#### Enhancements for merged phase:

- JWT validation & token expiration handled in frontend

- Role detection & UI enforcement in frontend

- Backend role enforcement in Lambdas

- Logging & error handling (CloudWatch)

- Loading indicators & centralized config in frontend

### 3️⃣ Achievements

- Unified auth & API layer for Admin & Employee

- Enterprise-grade security (frontend + backend)

- Job-ready UX polish: loader, error messages, responsive UI

- Scalable & maintainable codebase

- Audit & observability: logs for debugging and production monitoring

### 4️⃣ Tasks List

#### 1️⃣ Frontend Tasks

- Centralize config (API URL, Cognito IDs)

- Create auth-api.js with:

    - JWT token fetch

    - Secure API helper

    - Role detection

    - UI enforcement for Admin/Employee

    - Global error handler

    - Loader functions

    - Logout function

- Update Admin & Employee pages:

    - Include Cognito SDK

    - Include config.js + auth-api.js

    - Call protectPage() + enforceAdminAccess() / enforceEmployeeAccess()

- Replace API calls in pages with secureFetch

#### 1️⃣ Backend Tasks (Lambdas)

- Add logging (CloudWatch)

- Enforce role check using JWT claims

- Replace “Function logic goes here” with specific business logic (checkin, checkout, profile, leaves, admin employees)

- Return structured JSON responses

#### Testing Tasks

- Frontend: Login, logout, access control, loader, error handling

- Backend: Authorized vs unauthorized role access, CloudWatch logging

### 5️⃣ Anything else helpful for research / case study

- Show centralized config improves maintainability

- Explain role enforcement both frontend & backend prevents security bypass

- Include JWT expiration handling as production-ready feature

- Highlight CloudWatch logging as audit & monitoring

- Emphasize loader + error handling for professional UX

- Include flow diagram of merged phase for documentation / case study

> **📣 This structure makes the merged phase clear, self-contained, and professional — perfect for deployment, documentation, and research.**



### 🌐 Frontend — Task 1️⃣ — Frontend → API Integration & Role-Based UI Control

### 🌐 Method 1️⃣ Frontend → API Integration & Role-Based UI Control

### 1️⃣ — STANDARD API CALL FUNCTION (FRONTEND)
> **This function will be used everywhere (Admin & Employee).**

### 📌 Why this is important

- No duplicate code

- Easy debugging

- JWT always attached

- Same pattern used in real companies

### 5️⃣ — BACKEND SECURITY (DOUBLE PROTECTION)

✔ Frontend check

✔ Backend check

✔ Enterprise-grade security

### ➕ - A SHARED SCRIPT FILE (Recommanded)

#### ✅ Benefits of a Shared Script File (Industry Standard)

By creating ONE shared JS file:

✔ Clean HTML (UI only)

✔ All security logic in one place

✔ Easy debugging

✔ Easy upgrades

✔ Same pattern used in:

AWS Amplify apps

React / Vue projects

Enterprise dashboards

👉 This is how companies expect you to work

### 🟢 STEP 1 — CENTRAL CONFIG FILE (FRONTEND)

#### ❓ Why this matters

Hard-coding values everywhere is not professional.

#### We will centralize:

- API Base URL

- Cognito IDs

- App name

### 🌐 Method 1️⃣ Frontend → API Integration & Role-Based UI Control 
> **➕ - A SHARED SCRIPT FILE (Recommanded)**

### 🌐 Frontend — Task 1️⃣ — Frontend → API Integration & Role-Based UI Control

```
/* =====================================================
   AUTH & API SHARED UTILITIES
   Used by: Admin + Employee pages
   Project: Charlie Café HR System
===================================================== */

/* ===============================
   COGNITO CONFIG
================================ */
const poolData = {
    UserPoolId: 'us-east-1_XXXXXX',
    ClientId: 'XXXXXXXXXXXX'
};

const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);
const apiBase = 'https://<API-ID>.execute-api.us-east-1.amazonaws.com/prod';

/* ===============================
   SESSION GUARD (PAGE PROTECTION)
================================ */
function protectPage() {
    const user = userPool.getCurrentUser();
    if (!user) {
        window.location.href = "login.html";
    }
}

/* ===============================
   GET JWT TOKEN
================================ */
async function getJWT() {
    const user = userPool.getCurrentUser();
    return new Promise((resolve, reject) => {
        if (!user) reject("No active session");
        user.getSession((err, session) => {
            if (err) reject(err);
            resolve(session.getIdToken().getJwtToken());
        });
    });
}

/* ===============================
   SECURE API CALL HELPER
================================ */
async function secureFetch(url, method = "GET", body = null) {
    const token = await getJWT();

    const options = {
        method: method,
        headers: {
            "Authorization": token,
            "Content-Type": "application/json"
        }
    };

    if (body) {
        options.body = JSON.stringify(body);
    }

    const response = await fetch(url, options);
    if (!response.ok) {
        throw new Error("API request failed or unauthorized");
    }

    return response.json();
}

/* ===============================
   ROLE DETECTION
================================ */
async function getUserRoles() {
    const user = userPool.getCurrentUser();
    return new Promise((resolve, reject) => {
        user.getSession((err, session) => {
            if (err) reject(err);
            const payload = session.getIdToken().decodePayload();
            resolve(payload["cognito:groups"] || []);
        });
    });
}

/* ===============================
   ADMIN UI CONTROL
================================ */
async function enforceAdminAccess() {
    const roles = await getUserRoles();
    if (!roles.includes("Admin")) {
        alert("Unauthorized access");
        window.location.href = "login.html";
    }
    document.getElementById("admin-section").style.display = "block";
}

/* ===============================
   EMPLOYEE UI CONTROL
================================ */
async function enforceEmployeeAccess() {
    const roles = await getUserRoles();
    if (!roles.includes("Employee")) {
        alert("Unauthorized access");
        window.location.href = "login.html";
    }
}

/* ===============================
   LOGOUT (Cognito)
================================ */
function logout() {
    const user = userPool.getCurrentUser();
    if (user) {
        user.signOut();
    }
    window.location.href = "index.html";
}
```

✅ One file

✅ Reusable

✅ Secure

✅ Clean

### 🟢 FINAL AUTH-API.JS (ALL-IN-ONE)

#### ✅ What this file contains

#### Phase 4 — Frontend API integration & role-based UI

- protectPage() → Protects pages from unauthenticated users

- getJWT() → Fetches Cognito JWT

- secureFetch() → Central API call function

- getUserRoles() → Reads Cognito groups

- enforceAdminAccess() / enforceEmployeeAccess() → Role-based UI control

- loadEmployeeProfile() / loadAllEmployees() → Example API calls

- logout() → Cognito logout

#### Phase 5 — Production Hardening

- getJWT() updated to handle token expiration and auto logout

- handleError() → Global error handler

- showLoader() / hideLoader() → Loading indicator for smooth UX

- All API calls updated to use loader + error handler

- Now uses CONFIG for centralized config (API URL & Cognito IDs)

---

### 🌐 Method 2️⃣ Frontend → API Integration & Role-Based UI Control

### 🌐 Frontend — Task 1️⃣ — Frontend → API Integration & Role-Based UI Control

### 1️⃣ — STANDARD API CALL FUNCTION (FRONTEND)
> **This function will be used everywhere (Admin & Employee).**

#### ✅ Add this to BOTH pages (admin-dashboard.html, employee-portal.html)

```
<script>
/* ===============================
   GET JWT TOKEN FROM COGNITO
================================ */
async function getJWT() {
    const user = userPool.getCurrentUser();
    return new Promise((resolve, reject) => {
        if (!user) reject("No active session");
        user.getSession((err, session) => {
            if (err) reject(err);
            resolve(session.getIdToken().getJwtToken());
        });
    });
}

/* ===============================
   SECURE API CALL HELPER
================================ */
async function secureFetch(url, method = "GET", body = null) {
    const token = await getJWT();

    const options = {
        method: method,
        headers: {
            "Authorization": token,
            "Content-Type": "application/json"
        }
    };

    if (body) {
        options.body = JSON.stringify(body);
    }

    const response = await fetch(url, options);
    if (!response.ok) {
        throw new Error("API access denied or failed");
    }

    return response.json();
}
</script>
```

### 2️⃣ — ROLE DETECTION (ADMIN vs EMPLOYEE)

Cognito puts groups inside the JWT.

#### ✅ Add this function

```
<script>
/* ===============================
   DETECT USER ROLE FROM TOKEN
================================ */
async function getUserRole() {
    const user = userPool.getCurrentUser();
    return new Promise((resolve, reject) => {
        user.getSession((err, session) => {
            if (err) reject(err);
            const payload = session.getIdToken().decodePayload();
            const groups = payload["cognito:groups"] || [];
            resolve(groups);
        });
    });
}
</script>
```

### 3️⃣ — ROLE-BASED UI CONTROL (FRONTEND)

#### ✅ Admin Page (admin-dashboard.html)

```
<script>
async function applyAdminUIRules() {
    const roles = await getUserRole();

    if (!roles.includes("Admin")) {
        alert("Unauthorized access");
        window.location.href = "login.html";
    }

    // Admin-only buttons
    document.getElementById("admin-section").style.display = "block";
}
applyAdminUIRules();
</script>
```

#### HTML Example

```
<div id="admin-section" style="display:none;">
    <button class="btn btn-warning">Manage Employees</button>
    <button class="btn btn-danger">View Payroll</button>
</div>
```

#### ✅ Employee Page (employee-portal.html)

```
<script>
async function applyEmployeeUIRules() {
    const roles = await getUserRole();

    if (!roles.includes("Employee")) {
        alert("Unauthorized access");
        window.location.href = "login.html";
    }
}
applyEmployeeUIRules();
</script>
```

- **📌 Employees never see admin buttons**

- **📌 Even if they edit HTML → API still blocks them**

### 4️⃣ — FRONTEND → API INTEGRATION (REAL DATA)

#### Example: Employee Profile Load

```
<script>
async function loadEmployeeProfile() {
    try {
        const data = await secureFetch(
            apiBase + "/employee/profile"
        );

        document.getElementById("profile-name").innerText = data.name;
        document.getElementById("profile-job").innerText = data.job_title;
    } catch (err) {
        alert("Failed to load profile");
    }
}
loadEmployeeProfile();
</script>
```

#### Example: Admin Fetch All Employees

```
<script>
async function loadAllEmployees() {
    const data = await secureFetch(
        apiBase + "/admin/employees"
    );

    console.log("Employees:", data);
}
</script>
```


---
### 🌐 Frontend — Task 2️⃣ — PRODUCTION HARDENING (ENTERPRISE-GRADE)


#### 🟢 STEP 2 — TOKEN EXPIRATION HANDLING (VERY IMPORTANT)

#### ❓ Problem

JWT tokens expire (usually 1 hour).

#### If expired:

- API calls fail

- Users see random errors

####  ✅ Add Token Expiry Check

#### Update getJWT() in auth-api.js

```
async function getJWT() {
    const user = userPool.getCurrentUser();

    return new Promise((resolve, reject) => {
        if (!user) reject("No active session");

        user.getSession((err, session) => {
            if (err || !session.isValid()) {
                alert("Session expired. Please login again.");
                user.signOut();
                window.location.href = "login.html";
                reject("Session expired");
            }

            resolve(session.getIdToken().getJwtToken());
        });
    });
}
```

✔ Auto logout

✔ Clean redirect

✔ No broken UI

#### 🟢 STEP 3 — GLOBAL ERROR HANDLER (FRONTEND)

#### ❓ Why

You must not handle errors randomly in every function.

#### ✅ Central Error Handler

Add this to auth-api.js

```
function handleError(error) {
    console.error("Application Error:", error);
    alert("Something went wrong. Please try again.");
}
```

#### ✅ Use it in API calls

```
async function loadProfile() {
    try {
        const data = await secureFetch(apiBase + "/employee/profile");
        document.getElementById("profile-name").innerText = data.name;
    } catch (err) {
        handleError(err);
    }
}
```

**📌 One error handler → clean & consistent UX**

#### 🟢 STEP 4 — LOADING INDICATOR (UX POLISH)

#### ❓ Why this matters

Interviewers notice UX details.

#### ✅ Add Loader HTML (Both Pages)

```
<div id="loader" class="text-center mt-3" style="display:none;">
    <div class="spinner-border text-warning"></div>
    <p>Loading...</p>
</div>
```

#### ✅ Loader Control Functions

Add to auth-api.js

```
function showLoader() {
    document.getElementById("loader").style.display = "block";
}

function hideLoader() {
    document.getElementById("loader").style.display = "none";
}
```

#### ✅ Use in API calls

```
async function loadProfile() {
    try {
        showLoader();
        const data = await secureFetch(apiBase + "/employee/profile");
        document.getElementById("profile-name").innerText = data.name;
    } catch (err) {
        handleError(err);
    } finally {
        hideLoader();
    }
}
```

✔ Professional

✔ Smooth UX

✔ Real-world polish


---
#### 🟢 STEP 5 — LOGOUT FLOW (BOTH PAGES)

#### What Happens (Internally)

✔ Cognito tokens destroyed

✔ Session cleared

✔ getCurrentUser() → null

✔ Redirect happens

✔ Back button blocked

----

> **🟢 PHASE 5️⃣  R & D COMPLETE**
---


