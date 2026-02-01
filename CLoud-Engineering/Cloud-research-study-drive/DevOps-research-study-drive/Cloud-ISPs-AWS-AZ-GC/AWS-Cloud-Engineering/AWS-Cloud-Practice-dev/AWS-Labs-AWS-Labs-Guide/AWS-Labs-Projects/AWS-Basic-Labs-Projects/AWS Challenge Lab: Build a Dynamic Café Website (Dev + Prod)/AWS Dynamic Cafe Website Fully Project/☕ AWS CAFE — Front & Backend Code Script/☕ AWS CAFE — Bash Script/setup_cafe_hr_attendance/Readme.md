# ☕ AWS Charlie Café – Secure HR & Attendance & Employee Management System


### 8️⃣ HR & Attendance System Bash Script 

#### 1️⃣ Create File

```
sudo nano setup_cafe_hr_attendance.sh
```

#### 2️⃣ Bash Script 

#### ✅ Updated setup_cafe_hr_attendance.sh
> **Update Version 1.0**

```
#!/bin/bash
set -euo pipefail

echo "☕ Starting Cafe RDS Schema Setup (Employees + Attendance)..."

# ================= CONFIG =================
AWS_REGION="us-east-1"
SECRET_ID="CafeDevDBSM"
DB_NAME="cafe_db"   # ← change to "cafedb" if that's your actual database name

# ================= FETCH SECRET FROM SECRETS MANAGER =================
echo "🔐 Fetching RDS credentials..."
SECRET_JSON=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_ARN" \
    --region "$AWS_REGION" \
    --query SecretString \
    --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host // .endpoint // empty')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username // empty')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password // empty')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // "3306"')

if [[ -z "$DB_HOST" || -z "$DB_USER" || -z "$DB_PASS" ]]; then
    echo "❌ Missing required fields in secret (host/username/password)"
    exit 1
fi

echo "✅ Secret loaded"
echo "🔗 RDS Endpoint: $DB_HOST"
echo " Port: $DB_PORT"
echo "👤 DB User: $DB_USER"
echo "🗄 Database: $DB_NAME"
echo ""

# ================= CREATE TEMP CREDENTIALS FILE =================
CREDENTIALS_FILE=$(mktemp /tmp/rds-cafe-cred.XXXXXX)
chmod 600 "$CREDENTIALS_FILE"

cat > "$CREDENTIALS_FILE" << EOF
[client]
host=$DB_HOST
port=$DB_PORT
user=$DB_USER
password=$DB_PASS
connect-timeout=10
EOF

trap 'rm -f "$CREDENTIALS_FILE"' EXIT

# ================= TEST CONNECTION =================
echo "🔌 Testing RDS connection..."
if ! mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SELECT 1" >/dev/null 2>&1; then
    echo "❌ Connection failed. Check:"
    echo " • Security Group allows inbound 3306 from this EC2"
    echo " • Credentials & endpoint correct"
    exit 1
fi
echo "✅ Connection OK"
echo ""

# ================= CREATE/USE DATABASE =================
echo "🗄 Ensuring database '$DB_NAME' exists..."
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "
    CREATE DATABASE IF NOT EXISTS $DB_NAME 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;
"

# ================= CREATE TABLES =================
echo "📋 Creating employee management tables..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
-- Employees table (links to Cognito)
CREATE TABLE IF NOT EXISTS employees (
    employee_id     INT AUTO_INCREMENT PRIMARY KEY,
    cognito_user_id VARCHAR(100) NOT NULL,
    name            VARCHAR(100) NOT NULL,
    job_title       VARCHAR(50),
    salary          DECIMAL(10,2),
    start_date      DATE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_cognito (cognito_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Attendance
CREATE TABLE IF NOT EXISTS attendance (
    attendance_id   INT AUTO_INCREMENT PRIMARY KEY,
    employee_id     INT NOT NULL,
    attendance_date DATE NOT NULL,
    checkin_time    TIME,
    checkout_time   TIME,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_day (employee_id, attendance_date),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Leaves
CREATE TABLE IF NOT EXISTS leaves (
    leave_id        INT AUTO_INCREMENT PRIMARY KEY,
    employee_id     INT NOT NULL,
    leave_date      DATE NOT NULL,
    leave_type      VARCHAR(50),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    UNIQUE KEY uk_leave_day (employee_id, leave_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Holidays (global)
CREATE TABLE IF NOT EXISTS holidays (
    holiday_id      INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date    DATE NOT NULL UNIQUE,
    description     VARCHAR(100),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
EOF

# ================= INSERT TEST / SEED DATA =================
echo "🌱 Inserting test data & holidays..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
-- Holidays (2026 examples)
INSERT IGNORE INTO holidays (holiday_date, description) VALUES
    ('2026-01-01', 'New Year'),
    ('2026-03-23', 'Pakistan Day');

-- Temporary test employee (later replaced by Cognito trigger)
INSERT IGNORE INTO employees 
    (cognito_user_id, name, job_title, salary, start_date)
VALUES 
    ('TEMP-COGNITO-ID-123456', 'Alice', 'Barista', 40000.00, '2025-12-01');
EOF

# ================= VERIFY =================
echo ""
echo "🔍 Verifying tables and test data..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" -e "
    SHOW TABLES;
    SELECT * FROM holidays ORDER BY holiday_date;
    SELECT employee_id, name, job_title, cognito_user_id FROM employees LIMIT 3;
    SELECT 'Schema & test data look good' AS status;
"

echo ""
echo "✅ Cafe employee/attendance schema setup completed successfully ☕"
echo "Next steps:"
echo "  • Connect:  mysql -h $DB_HOST -u $DB_USER -p $DB_NAME"
echo "  • Use Cognito Post-Confirmation trigger to auto-create real employee rows"
echo "  • Remove the TEMP employee later when going to production"
```

#### ✅ UPDATED & FIXED MEGA BASH SCRIPT (FINAL)
> **Update Version 1.1**

You can copy-paste this entire script as-is.
I added clear comments and fixed the verification query.

✅ Uses strict bash safely

✅ Fetches RDS credentials securely

✅ Creates employees, attendance, leaves, holidays

✅ Inserts test data (idempotent)

✅ Verifies tables + sample rows

✅ Has clear comments

✅ Safe to re-run (no duplicates)



```
#!/bin/bash
set -euo pipefail

echo "☕ Starting Cafe RDS HR & Attendance Schema Setup..."

# =========================================================
# CONFIGURATION
# =========================================================
AWS_REGION="us-east-1"
SECRET_ID="CafeDevDBSM"     # AWS Secrets Manager secret name
DB_NAME="cafe_db"           # Change if your DB name is different

# =========================================================
# FETCH RDS CREDENTIALS FROM SECRETS MANAGER
# =========================================================
echo "🔐 Fetching RDS credentials from Secrets Manager..."

SECRET_JSON=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_ID" \
    --region "$AWS_REGION" \
    --query SecretString \
    --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host // .endpoint')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // "3306"')

if [[ -z "$DB_HOST" || -z "$DB_USER" || -z "$DB_PASS" ]]; then
    echo "❌ Missing database credentials in Secrets Manager"
    exit 1
fi

echo "✅ Secret loaded"
echo "   • Host: $DB_HOST"
echo "   • Port: $DB_PORT"
echo "   • User: $DB_USER"
echo "   • DB  : $DB_NAME"
echo ""

# =========================================================
# CREATE TEMP MYSQL CREDENTIALS FILE (SECURE)
# =========================================================
CREDENTIALS_FILE=$(mktemp /tmp/rds-cafe-cred.XXXXXX)
chmod 600 "$CREDENTIALS_FILE"

cat > "$CREDENTIALS_FILE" <<EOF
[client]
host=$DB_HOST
port=$DB_PORT
user=$DB_USER
password=$DB_PASS
connect-timeout=10
EOF

# Auto-clean credentials file on exit
trap 'rm -f "$CREDENTIALS_FILE"' EXIT

# =========================================================
# TEST DATABASE CONNECTION
# =========================================================
echo "🔌 Testing RDS connection..."
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SELECT 1" >/dev/null
echo "✅ RDS connection successful"
echo ""

# =========================================================
# CREATE DATABASE (IF NOT EXISTS)
# =========================================================
echo "🗄 Ensuring database '$DB_NAME' exists..."
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
"

# =========================================================
# CREATE HR & ATTENDANCE TABLES
# =========================================================
echo "📋 Creating HR & Attendance tables..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
-- =====================================================
-- Employees table (Cognito linked)
-- =====================================================
CREATE TABLE IF NOT EXISTS employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    cognito_user_id VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    start_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_cognito_user (cognito_user_id)
) ENGINE=InnoDB;

-- =====================================================
-- Attendance table
-- =====================================================
CREATE TABLE IF NOT EXISTS attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    checkin_time TIME,
    checkout_time TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_attendance_day (employee_id, attendance_date),
    FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- Leaves table
-- =====================================================
CREATE TABLE IF NOT EXISTS leaves (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    leave_date DATE NOT NULL,
    leave_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_leave_day (employee_id, leave_date),
    FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- Holidays table (global)
-- =====================================================
CREATE TABLE IF NOT EXISTS holidays (
    holiday_id INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date DATE NOT NULL UNIQUE,
    description VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
EOF

# =========================================================
# INSERT TEST / SEED DATA (IDEMPOTENT)
# =========================================================
echo "🌱 Inserting test data (idempotent)..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
-- Holidays
INSERT IGNORE INTO holidays (holiday_date, description) VALUES
    ('2026-01-01', 'New Year'),
    ('2026-03-23', 'Pakistan Day');

-- Temporary test employee
INSERT IGNORE INTO employees
    (cognito_user_id, name, job_title, salary, start_date)
VALUES
    ('TEMP-COGNITO-ID', 'Alice', 'Barista', 40000, '2025-12-01');
EOF

# =========================================================
# VERIFICATION TESTS (FINAL)
# =========================================================
echo ""
echo "🔍 VERIFICATION RESULTS"
echo "------------------------------------------"

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
-- Show all tables
SHOW TABLES;

-- Row counts (SAFE alias name)
SELECT 'employees'  AS table_name, COUNT(*) AS row_count FROM employees
UNION ALL
SELECT 'attendance', COUNT(*) FROM attendance
UNION ALL
SELECT 'leaves',     COUNT(*) FROM leaves
UNION ALL
SELECT 'holidays',   COUNT(*) FROM holidays;

-- Sample employee record
SELECT employee_id, name, job_title, cognito_user_id
FROM employees
LIMIT 3;

SELECT 'HR & Attendance schema verified successfully ✅' AS status;
EOF

echo ""
echo "✅ Cafe HR & Attendance schema setup completed successfully ☕"
echo ""
echo "Next steps:"
echo " • Connect manually:"
echo "   mysql -h $DB_HOST -u $DB_USER -p $DB_NAME"
echo " • Add Cognito Post-Confirmation Lambda to auto-create employees"
echo " • Remove TEMP employee before production"
```

#### 3️⃣ Make the Script Executable

```
sudo chmod +x setup_cafe_hr_attendance.sh
```

#### 4️⃣ Run the Script

```
sudo ./setup_cafe_hr_attendance.sh
```

#### ✅ UPDATED & FIXED MEGA BASH SCRIPT (FINAL)
> **Update Version 1.2**

```
#!/bin/bash
set -euo pipefail

echo "☕ Starting Cafe RDS HR & Attendance Schema Setup..."

# =========================================================
# CONFIGURATION
# =========================================================
AWS_REGION="us-east-1"
SECRET_ID="CafeDevDBSM"     # AWS Secrets Manager secret name
DB_NAME="cafe_db"           # Change if your DB name is different

# =========================================================
# FETCH RDS CREDENTIALS FROM SECRETS MANAGER
# =========================================================
echo "🔐 Fetching RDS credentials from Secrets Manager..."

SECRET_JSON=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_ID" \
    --region "$AWS_REGION" \
    --query SecretString \
    --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host // .endpoint')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // "3306"')

if [[ -z "$DB_HOST" || -z "$DB_USER" || -z "$DB_PASS" ]]; then
    echo "❌ Missing database credentials in Secrets Manager"
    exit 1
fi

echo "✅ Secret loaded"
echo "   • Host: $DB_HOST"
echo "   • Port: $DB_PORT"
echo "   • User: $DB_USER"
echo "   • DB  : $DB_NAME"
echo ""

# =========================================================
# CREATE TEMP MYSQL CREDENTIALS FILE (SECURE)
# =========================================================
CREDENTIALS_FILE=$(mktemp /tmp/rds-cafe-cred.XXXXXX)
chmod 600 "$CREDENTIALS_FILE"

cat > "$CREDENTIALS_FILE" <<EOF
[client]
host=$DB_HOST
port=$DB_PORT
user=$DB_USER
password=$DB_PASS
connect-timeout=10
EOF

# Auto-clean credentials file on exit
trap 'rm -f "$CREDENTIALS_FILE"' EXIT

# =========================================================
# TEST DATABASE CONNECTION
# =========================================================
echo "🔌 Testing RDS connection..."
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SELECT 1" >/dev/null
echo "✅ RDS connection successful"
echo ""

# =========================================================
# CREATE DATABASE (IF NOT EXISTS)
# =========================================================
echo "🗄 Ensuring database '$DB_NAME' exists..."
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
"

# =========================================================
# CREATE HR & ATTENDANCE TABLES
# =========================================================
echo "📋 Creating HR & Attendance tables..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
-- =====================================================
-- Employees table (Cognito linked)
-- =====================================================
CREATE TABLE IF NOT EXISTS employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    cognito_user_id VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    start_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_cognito_user (cognito_user_id)
) ENGINE=InnoDB;

-- =====================================================
-- Attendance table
-- =====================================================
CREATE TABLE IF NOT EXISTS attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    checkin_time TIME,
    checkout_time TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_attendance_day (employee_id, attendance_date),
    FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- Leaves table
-- =====================================================
CREATE TABLE IF NOT EXISTS leaves (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    leave_date DATE NOT NULL,
    leave_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_leave_day (employee_id, leave_date),
    FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- Holidays table (global)
-- =====================================================
CREATE TABLE IF NOT EXISTS holidays (
    holiday_id INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date DATE NOT NULL UNIQUE,
    description VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
EOF

# =========================================================
# INSERT TEST / SEED DATA (IDEMPOTENT)
# =========================================================
echo "🌱 Inserting test data (idempotent)..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
-- Holidays
INSERT IGNORE INTO holidays (holiday_date, description) VALUES
    ('2026-01-01', 'New Year'),
    ('2026-03-23', 'Pakistan Day');

-- Temporary test employee
INSERT IGNORE INTO employees
    (cognito_user_id, name, job_title, salary, start_date)
VALUES
    ('TEMP-COGNITO-ID', 'Alice', 'Barista', 40000, '2025-12-01');
EOF

# =========================================================
# VERIFICATION TESTS (FINAL)
# =========================================================
echo ""
echo "🔍 VERIFICATION RESULTS"
echo "------------------------------------------"

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
-- Show all tables
SHOW TABLES;

-- Row counts (SAFE alias name)
SELECT 'employees'  AS table_name, COUNT(*) AS row_count FROM employees
UNION ALL
SELECT 'attendance', COUNT(*) FROM attendance
UNION ALL
SELECT 'leaves',     COUNT(*) FROM leaves
UNION ALL
SELECT 'holidays',   COUNT(*) FROM holidays;

-- Sample employee record
SELECT employee_id, name, job_title, cognito_user_id
FROM employees
LIMIT 3;

SELECT 'HR & Attendance schema verified successfully ✅' AS status;
EOF

echo ""
echo "✅ Cafe HR & Attendance schema setup completed successfully ☕"
echo ""
echo "Next steps:"
echo " • Connect manually:"
echo "   mysql -h $DB_HOST -u $DB_USER -p $DB_NAME"
echo " • Add Cognito Post-Confirmation Lambda to auto-create employees"
echo " • Remove TEMP employee before production"
```

---
