# ☕ AWS CAFE — Research & CaseStudy Project Doc


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
## ☕ Charlie Café PHASE 3️⃣ — API Gateway Setup for HR Secure Attendance System




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

> **🟢 PHASE 5️⃣  R & D COMPLETE**
---


