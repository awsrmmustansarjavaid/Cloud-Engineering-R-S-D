#Charlie Cafe -- hr-attendance-history

### 1️⃣ hr-attendance-history – Features & How It Works

#### ✅ Purpose

Returns attendance history for a specific employee.

#### ✅ Input

- HTTP Method: POST

- Request Body (JSON):

```
{
  "employee_id": "123"
}
```

### ✅ What It Does Internally

#### Step 1 — CORS Handling

If request method is OPTIONS, it returns CORS success.

#### Step 2 — Validate Input

- Checks if body exists

- Checks if employee_id is provided

- Returns 400 if missing

#### Step 3 — Database Connection

- Fetches DB credentials from AWS Secrets Manager (CafeDevDBSM)

- Creates a reusable MySQL connection using pymysql

- Uses global connection to improve performance

#### Step 4 — Query Executed

```
SELECT attendance_date, checkin_time, checkout_time
FROM attendance
WHERE employee_id = ?
ORDER BY attendance_date DESC
```

Step 5 — Returns

```
[
  {
    "attendance_date": "2025-02-01",
    "checkin_time": "09:00:00",
    "checkout_time": "18:00:00"
  }
]
```

### 🔍 Summary of hr-attendance-history

| Feature          | Description             |
| ---------------- | ----------------------- |
| Reads from table | `attendance`            |
| Filters by       | employee_id             |
| Returns          | Attendance records only |
| Response format  | Array                   |

### 2️⃣ hr-leaves-holidays – Features & How It Works

#### ✅ Purpose

Returns:

- Employee leave history

- Company holidays list

#### ✅ Input

Same:

```
{
  "employee_id": "123"
}
```

### ✅ What It Does Internally

#### Step 1 — CORS Handling

Same as first Lambda.

#### Step 2 — Validate Input

Requires employee_id.

#### Step 3 — Database Connection

Same Secrets Manager + MySQL reuse logic.

#### Step 4 — Queries Executed
Query 1 — Employee Leaves

```
SELECT leave_date, leave_type
FROM leaves
WHERE employee_id = ?
ORDER BY leave_date DESC
```

#### Query 2 — Company Holidays

```
SELECT holiday_date, description
FROM holidays
ORDER BY holiday_date DESC
```

#### Step 5 — Returns

```
{
  "leaves": [...],
  "holidays": [...]
}
```

### 🔍 Summary of hr-leaves-holidays

| Feature          | Description               |
| ---------------- | ------------------------- |
| Reads from table | `leaves`, `holidays`      |
| Filters by       | employee_id (leaves only) |
| Returns          | Leaves + holidays         |
| Response format  | Object                    |


### 🔎 Key Differences

| Area              | Attendance Lambda | Leaves/Holidays Lambda |
| ----------------- | ----------------- | ---------------------- |
| Tables            | attendance        | leaves + holidays      |
| Number of queries | 1                 | 2                      |
| Response type     | List              | JSON object            |
| Data returned     | Attendance only   | Leave + Holiday        |

### 🧠 Can They Be Merged?

Yes — because:

✅ Same database

✅ Same secret

✅ Same connection logic

✅ Same input (employee_id)

✅ Same CORS & response format

✅ Same infrastructure

They are structurally 90% identical.

### 🚀 How They Could Be Combined

You have two main architectural options:

### Option 1 — Single Endpoint Returning Everything

Return:

```
{
  "attendance": [...],
  "leaves": [...],
  "holidays": [...]
}
```

#### Good for:

- Dashboard page

- Mobile HR app

- Employee profile page

#### Option 2 — One Lambda, Multiple Routes

Use API Gateway path like:

- /attendance

- /leaves

- /holidays

- /all

Inside one Lambda, check:

```
event["path"]
```

Then run only required query.

Better for:

Clean REST architecture

Scalable HR microservice

### ⚠️ Important Considerations Before Merging

#### 1️⃣ Performance

If merged into one that always fetches everything:

It will always run 3 queries

Slightly slower

#### 2️⃣ Scalability

If traffic grows:

Separate Lambdas scale independently

Merged Lambda scales everything together

#### 3️⃣ Maintainability

Merged = less duplicated code
Separate = clearer responsibility

### 🏆 Best Practice Recommendation

If this is:

Internal HR system

Small to medium traffic

Same frontend using all data together

#### 👉 Merge them into one Lambda.

If this is:

Public API

Microservices architecture

High scalability required

#### 👉 Keep separate or use single Lambda with route-based logic.



