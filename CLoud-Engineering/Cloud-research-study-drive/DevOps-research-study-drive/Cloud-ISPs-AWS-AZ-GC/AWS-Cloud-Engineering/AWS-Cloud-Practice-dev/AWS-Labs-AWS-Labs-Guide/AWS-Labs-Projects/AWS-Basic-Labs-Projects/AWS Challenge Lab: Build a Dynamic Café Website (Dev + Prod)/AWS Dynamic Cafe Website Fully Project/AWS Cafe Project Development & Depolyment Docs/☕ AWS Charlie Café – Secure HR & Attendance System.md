# ☕ AWS Charlie Café – Secure HR & Attendance & Employee Management System


## PHASE R&D ☕ Charlie Café Attendance System

### 1️⃣ System Scope

#### 1️⃣ Attendance Management

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

#### 2️⃣ Employee Portal

- Secure employee login using Amazon Cognito

- Employee can:

    - View personal attendance history

    - View approved leaves

    - View official café holidays

    - View HR profile information:

        - Job title

        - Salary

        - Start date

#### 3️⃣ Access Control & Security

- Application access restricted using Security Groups

- 1️⃣ Frontend EC2:

    - HTTP/HTTPS allowed only from allowed IP ranges (practice lab)

- 2️⃣ Backend services protected using:

    - API Gateway authorization

    - Cognito JWT validation

- 3️⃣ Database access:

    - RDS accessible only from Lambda security group

### 2️⃣ Architecture Overview

#### 1️⃣ Frontend Layer

- Hosted on **EC2 Apache Web Server**

- Pages:

    - Attendance Check-In / Check-Out page (tablet/kiosk style)

    - Employee Portal page

    - Admin / HR Dashboard page

- Frontend communicates with backend using API Gateway endpoints

#### 2️⃣ Backend Layer

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

#### 3️⃣ Database Layer (RDS)

#### 1️⃣ Database Type

    - MySQL or PostgreSQL

#### 2️⃣ Tables

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

### 3️⃣ Frontend Pages

#### 1️⃣ A) Attendance Check-In / Check-Out Page

    - Tablet-friendly layout

    - Employee authentication via Cognito

    - Buttons:

        - Check-In

        - Check-Out

    - Auto timestamp capture

    - Success / error notification

#### 2️⃣ B) Employee Portal Page

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

#### 2️⃣ C) Admin / HR Dashboard

    - Secure Cognito-admin access

    - View:

        - Daily attendance

        - Weekly summary

        - Monthly summary

    - Employee-wise filtering

    - Export-ready table structure (future use)

### 4️⃣ API Endpoints (API Gateway + Lambda)

    - POST /api/checkin

    - POST /api/checkout

    - GET /api/employee/profile

    - GET /api/attendance

    - GET /api/leaves-holidays

#### Security

    - Cognito Authorizer enabled

    - JWT required for all endpoints

### 5️⃣ Security Configuration

#### 1️⃣ Security Groups

#### 1️⃣ Frontend EC2

    - Allow HTTP/HTTPS from allowed IP ranges

#### 2️⃣ Lambda

    - Allow outbound access to RDS

#### 3️⃣ RDS

    - Allow inbound only from Lambda security group

#### 2️⃣ Authentication & Authorization

    - Amazon Cognito User Pool

    - Role-based access:

        - Employee

        - Admin / HR

    - JWT validation enforced at API Gateway

### 6️⃣ Deployment Alignment

    - Frontend deployed on existing EC2 Apache server

    - Backend integrated into existing API Gateway + Lambda

    - Authentication integrated with existing Cognito

    - Database hosted in existing RDS

    - Logging via CloudWatch

### 7️⃣ Completion Outcome

    - Fully integrated internal café attendance system

    - Professional AWS architecture aligned with real job requirements

    - Secure, scalable, and production-style setup

    - Completes the final 20% of the Charlie Café lab

**✅ PHASE R & D STATUS**

> **🟢 PHASE R & D COMPLETE & VERIFIED**

---

