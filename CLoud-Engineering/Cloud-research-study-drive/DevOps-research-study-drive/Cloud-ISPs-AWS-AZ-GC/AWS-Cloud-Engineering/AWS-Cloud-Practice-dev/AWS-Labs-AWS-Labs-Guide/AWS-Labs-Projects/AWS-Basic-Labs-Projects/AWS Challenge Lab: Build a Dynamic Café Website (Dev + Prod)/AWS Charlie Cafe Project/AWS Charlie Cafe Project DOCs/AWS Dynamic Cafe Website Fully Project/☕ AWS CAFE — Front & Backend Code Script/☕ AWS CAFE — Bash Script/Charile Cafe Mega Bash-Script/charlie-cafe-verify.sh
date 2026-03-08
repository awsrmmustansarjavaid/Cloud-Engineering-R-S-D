#!/bin/bash
# ============================================================
# CHARLIE CAFE ☕ — VERIFICATION SCRIPT
# READ-ONLY | SAFE | NON-DESTRUCTIVE
# ============================================================

set +e   # Do NOT exit on error (we want full report)

AWS_REGION="us-east-1"
SECRET_ID="CafeDevDBSM"
S3_BUCKET="charlie-cafe-s3-bucket"
LAYER_S3_KEY="layers/pymysql-layer.zip"

echo "============================================================"
echo "🔍 CHARLIE CAFE — SYSTEM VERIFICATION STARTED"
echo "============================================================"

# ============================================================
# 1️⃣ SYSTEM & SERVICES
# ============================================================

echo -e "\n🖥️  OS CHECK:"
cat /etc/os-release | grep PRETTY_NAME

echo -e "\n🌐 Apache Status:"
systemctl is-active httpd && echo "✅ Apache running" || echo "❌ Apache NOT running"

echo -e "\n🐘 PHP Check:"
php -v >/dev/null 2>&1 && echo "✅ PHP installed" || echo "❌ PHP missing"

# ============================================================
# 2️⃣ WEB FILES & PERMISSIONS
# ============================================================

echo -e "\n📂 Web Root Check:"
[ -d /var/www/html ] && echo "✅ /var/www/html exists" || echo "❌ Missing web root"

echo -e "\n🔐 Permissions Check:"
stat -c "%U:%G %a" /var/www/html

echo -e "\n📄 info.php Check:"
[ -f /var/www/html/info.php ] && echo "✅ info.php exists" || echo "❌ info.php missing"

# ============================================================
# 3️⃣ AWS CLI & TOOLS
# ============================================================

echo -e "\n☁️ AWS CLI Check:"
aws --version >/dev/null 2>&1 && echo "✅ AWS CLI installed" || echo "❌ AWS CLI missing"

echo -e "\n🔎 jq Check:"
jq --version >/dev/null 2>&1 && echo "✅ jq installed" || echo "❌ jq missing"

echo -e "\n🗄️ MySQL Client Check:"
mysql --version >/dev/null 2>&1 && echo "✅ MySQL client installed" || echo "❌ MySQL client missing"

# ============================================================
# 4️⃣ SECRETS MANAGER ACCESS
# ============================================================

echo -e "\n🔐 Secrets Manager Access:"
SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ID" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text 2>/dev/null)

if [[ -n "$SECRET_JSON" ]]; then
  echo "✅ Able to fetch secret"
else
  echo "❌ Cannot fetch secret"
fi

# ============================================================
# 5️⃣ DATABASE VERIFICATION
# ============================================================

if [[ -n "$SECRET_JSON" ]]; then
  DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
  DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
  DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')

  echo -e "\n🗄️ Database Connectivity:"
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SHOW DATABASES LIKE 'cafe_db';" \
    && echo "✅ cafe_db exists" || echo "❌ cafe_db missing"

  echo -e "\n📋 Orders Table Check:"
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" cafe_db \
    -e "DESCRIBE orders;" >/dev/null 2>&1 \
    && echo "✅ orders table OK" || echo "❌ orders table missing"
fi

# ============================================================
# 6️⃣ LAMBDA LAYER FILE
# ============================================================

echo -e "\n📦 Lambda Layer ZIP Local Check:"
[ -f pymysql-layer.zip ] && echo "✅ pymysql-layer.zip exists" || echo "⚠️ ZIP not found locally"

echo -e "\n☁️ Lambda Layer in S3:"
aws s3 ls "s3://$S3_BUCKET/$LAYER_S3_KEY" >/dev/null 2>&1 \
  && echo "✅ Lambda layer exists in S3" || echo "❌ Lambda layer missing in S3"

# ============================================================
# 7️⃣ FRONTEND JS CHECK
# ============================================================

echo -e "\n🧠 central-auth-api.js Check:"
[ -f /var/www/html/js/central-auth-api.js ] \
  && echo "✅ central-auth-api.js exists" \
  || echo "❌ central-auth-api.js missing"

echo -e "\n🔐 JS File Permissions:"
stat -c "%U:%G %a" /var/www/html/js/central-auth-api.js 2>/dev/null

# ============================================================
# 8️⃣ FINAL SUMMARY
# ============================================================

echo "============================================================"
echo "✅ VERIFICATION COMPLETE"
echo "If everything shows ✅, your setup is PRODUCTION-READY ☕"
echo "============================================================"
