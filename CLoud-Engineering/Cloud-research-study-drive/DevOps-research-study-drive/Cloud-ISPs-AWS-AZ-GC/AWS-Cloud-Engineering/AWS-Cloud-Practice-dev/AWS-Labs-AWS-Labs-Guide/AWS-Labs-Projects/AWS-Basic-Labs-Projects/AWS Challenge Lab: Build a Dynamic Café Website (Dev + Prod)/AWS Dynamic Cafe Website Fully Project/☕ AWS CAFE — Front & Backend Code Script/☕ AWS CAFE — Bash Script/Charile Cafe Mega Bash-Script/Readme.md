# charlie Cafe Mega Bash Script


### End-to-End Bash script that:

- Sets up EC2 (Amazon Linux 2023)

- Installs LAMP + AWS CLI + jq

- Fetches RDS credentials from Secrets Manager

- Creates Cafe database & tables automatically

- Builds & uploads PyMySQL Lambda Layer

- Creates frontend JS directory

- Writes central-auth-api.js correctly

- Fixes permissions

- Is copy-paste runnable

Has clear comments so future-you won’t get lost

**Below is a PRODUCTION-QUALITY MEGA SCRIPT 🧠🔥**

You can save this as:

```
charlie-cafe-mega-setup.sh
```

```
#!/bin/bash
# ============================================================
# CHARLIE CAFE ☕ — MEGA SETUP SCRIPT
# Amazon Linux 2023
# - LAMP Stack
# - AWS CLI + jq
# - RDS DB + Tables
# - PyMySQL Lambda Layer
# - Frontend Central Auth JS
# ============================================================

set -e  # Exit immediately on error

# ============================================================
# 🔧 GLOBAL CONFIGURATION (EDIT ONCE)
# ============================================================

AWS_REGION="us-east-1"
SECRET_ID="CafeDevDBSM"

S3_BUCKET="charlie-cafe-s3-bucket"
LAYER_S3_KEY="layers/pymysql-layer.zip"

COGNITO_USER_POOL_ID="us-east-1_1wxssmoiqi"
COGNITO_CLIENT_ID="3a4uchovr497k8v3gl52e2j5d8"
COGNITO_DOMAIN="us-east-1wxssmoiqi.auth.us-east-1.amazoncognito.com"

API_BASE="https://a1053skr51.execute-api.us-east-1.amazonaws.com"
CLOUDFRONT_BASE="https://d3lnkgtsj0uwlu.cloudfront.net"

# ============================================================
# 1️⃣ SYSTEM UPDATE (MANDATORY FIRST)
# ============================================================

echo "🔄 Updating system..."
dnf update -y

# ============================================================
# 2️⃣ INSTALL LAMP STACK
# ============================================================

echo "🌐 Installing Apache..."
dnf install -y httpd
systemctl enable httpd
systemctl start httpd

echo "🐘 Installing PHP..."
dnf install -y \
php \
php-mysqlnd \
php-cli \
php-common \
php-mbstring \
php-xml

echo "🔐 Fixing web directory permissions..."
chown -R apache:apache /var/www
chmod -R 755 /var/www

echo "<?php phpinfo(); ?>" > /var/www/html/info.php
systemctl restart httpd

# ============================================================
# 3️⃣ INSTALL TOOLS (AWS CLI, jq, MySQL Client)
# ============================================================

echo "🧰 Installing AWS CLI, jq, MySQL client..."
dnf install -y awscli jq mariadb105 zip python3 python3-pip

# ============================================================
# 4️⃣ FETCH RDS CREDENTIALS FROM SECRETS MANAGER
# ============================================================

echo "🔐 Fetching DB credentials from Secrets Manager..."

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ID" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')

if [[ -z "$DB_USER" || -z "$DB_PASS" || -z "$DB_HOST" ]]; then
  echo "❌ Failed to retrieve database credentials"
  exit 1
fi

# ============================================================
# 5️⃣ CREATE DATABASE & TABLES (AUTOMATED)
# ============================================================

echo "🗄️ Creating cafe_db and tables..."

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" <<EOF
CREATE DATABASE IF NOT EXISTS cafe_db;
USE cafe_db;

CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    table_number INT NOT NULL,
    customer_name VARCHAR(100),
    item VARCHAR(50),
    quantity INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    order_id VARCHAR(50),
    status VARCHAR(20) DEFAULT 'RECEIVED',
    total_amount DECIMAL(10,2),
    payment_method VARCHAR(10),
    payment_status VARCHAR(10),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_table_number (table_number),
    INDEX idx_created_at (created_at)
);

SHOW TABLES;
DESCRIBE orders;
EOF

# ============================================================
# 6️⃣ BUILD & UPLOAD PYMYSQL LAMBDA LAYER
# ============================================================

echo "📦 Building PyMySQL Lambda Layer..."

BUILD_DIR="lambda-layer"
PYTHON_DIR="$BUILD_DIR/python"
ZIP_FILE="pymysql-layer.zip"

rm -rf "$BUILD_DIR" "$ZIP_FILE"
mkdir -p "$PYTHON_DIR"

pip3 install pymysql -t "$PYTHON_DIR" --no-cache-dir

cd "$BUILD_DIR"
zip -r "../$ZIP_FILE" python
cd ..

aws s3 cp "$ZIP_FILE" "s3://$S3_BUCKET/$LAYER_S3_KEY" --region "$AWS_REGION"

# ============================================================
# 7️⃣ CREATE CENTRAL AUTH JS FILE
# ============================================================

echo "🧠 Creating central-auth-api.js..."

mkdir -p /var/www/html/js

cat <<EOF > /var/www/html/js/central-auth-api.js
/* =========================================================
   CHARLIE CAFE — CENTRAL AUTH + API CONFIG
========================================================= */

const CHARLIE = (() => {

    const CONFIG = {
        REGION: "${AWS_REGION}",
        USER_POOL_ID: "${COGNITO_USER_POOL_ID}",
        CLIENT_ID: "${COGNITO_CLIENT_ID}",
        COGNITO_DOMAIN: "${COGNITO_DOMAIN}",
        API_BASE: "${API_BASE}",
        CLOUDFRONT_BASE: "${CLOUDFRONT_BASE}"
    };

    function parseJwt(token) {
        return JSON.parse(atob(token.split(".")[1]));
    }

    function isTokenExpired(token) {
        return parseJwt(token).exp * 1000 < Date.now();
    }

    function getToken() {
        return localStorage.getItem("access_token");
    }

    const auth = {
        login(redirectUrl = window.location.href) {
            window.location.href =
                \`https://\${CONFIG.COGNITO_DOMAIN}/login?response_type=token&client_id=\${CONFIG.CLIENT_ID}&scope=openid+email+profile&redirect_uri=\${encodeURIComponent(redirectUrl)}\`;
        },

        logout(redirectUrl = window.location.origin) {
            localStorage.removeItem("access_token");
            window.location.href =
                \`https://\${CONFIG.COGNITO_DOMAIN}/logout?client_id=\${CONFIG.CLIENT_ID}&logout_uri=\${encodeURIComponent(redirectUrl)}\`;
        },

        protectPage() {
            const token = getToken();
            if (!token || isTokenExpired(token)) this.login();
        }
    };

    async function authFetch(url, options = {}) {
        const token = getToken();
        return fetch(url, {
            ...options,
            headers: {
                Authorization: "Bearer " + token,
                "Content-Type": "application/json"
            }
        });
    }

    return { CONFIG, auth, authFetch };
})();
EOF

chown apache:apache /var/www/html/js/*
chmod 644 /var/www/html/js/*

# ============================================================
# 🎉 DONE
# ============================================================

echo "✅ CHARLIE CAFE SETUP COMPLETE!"
echo "☕ EC2 | RDS | Lambda Layer | Frontend Ready"
```

