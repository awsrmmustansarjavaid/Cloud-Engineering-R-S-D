#!/bin/bash
# =========================================================
# CHARLIE CAFE ☕
# S3 TO EC2 EXPORT + PERMISSIONS SCRIPT
# Secure Version (Uses EC2 IAM Role)
# Includes HTTPD Config Export
# =========================================================

# =========================================================
# ⚙️ AWS CONFIGURATION
# =========================================================
AWS_REGION="us-east-1"
S3_BUCKET="charlie-cafe-s3-bucket"

# =========================================================
# 📂 S3 FOLDERS
# =========================================================
S3_HTML_FOLDER="Charlie Cafe Code Drive/html/"
S3_BASH_FOLDER="Charlie Cafe Code Drive/bash script/"
S3_HTTPD_FILE="Charlie Cafe Code Drive/httpd/httpd.conf"

# =========================================================
# 📂 EC2 DESTINATIONS
# =========================================================
EC2_HTML_FOLDER="/var/www/html"
EC2_BASH_FOLDER="/home/ec2-user"
EC2_HTTPD_FILE="/etc/httpd/conf/httpd.conf"

# =========================================================
# 🚀 STEP 1 — EXPORT FILES FROM S3
# =========================================================
echo "======================================================="
echo "🚀 Starting Charlie Cafe S3 Export..."
echo "Bucket: $S3_BUCKET"
echo "Region: $AWS_REGION"
echo "======================================================="

echo "📥 Syncing HTML folder from S3 to EC2..."
aws s3 sync "s3://$S3_BUCKET/$S3_HTML_FOLDER" "$EC2_HTML_FOLDER" \
--region $AWS_REGION --delete

echo "📥 Syncing Bash scripts from S3 to EC2..."
aws s3 sync "s3://$S3_BUCKET/$S3_BASH_FOLDER" "$EC2_BASH_FOLDER" \
--region $AWS_REGION --delete

echo "📥 Downloading httpd.conf from S3..."
sudo aws s3 cp "s3://$S3_BUCKET/$S3_HTTPD_FILE" "$EC2_HTTPD_FILE" --region $AWS_REGION
if [ $? -eq 0 ]; then
    echo "✅ httpd.conf successfully copied to $EC2_HTTPD_FILE"
else
    echo "⚠️ Failed to copy httpd.conf from S3!"
fi

echo "======================================================="
echo "✅ S3 Export Completed!"
echo "HTML folder → $EC2_HTML_FOLDER"
echo "Bash folder → $EC2_BASH_FOLDER"
echo "HTTPD config → $EC2_HTTPD_FILE"
echo "======================================================="

# =========================================================
# 🔐 STEP 2 — SET APACHE PERMISSIONS
# =========================================================

echo ""
echo "🔐 Setting Apache permissions..."

# ---------------------------------------------------------
# List of files
# ---------------------------------------------------------
FILES=(
"/var/www/html/index.php"
"/var/www/html/cafe-admin-dashboard.html"
"/var/www/html/orders.php"
"/var/www/html/order-status.html"
"/var/www/html/order-receipt.php"
"/var/www/html/admin-orders.html"
"/var/www/html/payment-status.php"
"/var/www/html/central-print.html"
"/var/www/html/analytics.html"
"/var/www/html/login.html"
"/var/www/html/logout.php"
"/var/www/html/price-list.html"
"/var/www/html/employee-login.html"
"/var/www/html/employee-portal.html"
"/var/www/html/hr-attendance.html"
"/var/www/html/checkin.html"
"/var/www/html/js/config.js"
"/var/www/html/js/central-auth.js"
"/var/www/html/js/utils.js"
"/var/www/html/js/api.js"
"/var/www/html/js/central-printing.js"
"/var/www/html/js/role-guard.js"
"/var/www/html/css/central_cafe_style.css"
"$EC2_HTTPD_FILE"
)

# ---------------------------------------------------------
# List of directories
# ---------------------------------------------------------
DIRS=(
"/var/www/html/js"
"/var/www/html/css"
)

echo "---------------------------------------------"
echo "Setting ownership to apache:apache..."
sudo chown apache:apache "${FILES[@]}"
sudo chown -R apache:apache "${DIRS[@]}"

echo "---------------------------------------------"
echo "Setting directory permissions to 755..."
for dir in "${DIRS[@]}"; do
    sudo chmod 755 "$dir"
done

echo "---------------------------------------------"
echo "Setting file permissions to 644..."
for file in "${FILES[@]}"; do
    sudo chmod 644 "$file"
done

# =========================================================
# 🔎 STEP 3 — VERIFY PERMISSIONS & HTTPD CONFIG
# =========================================================
echo "---------------------------------------------"
echo "Verifying permissions and httpd.conf existence..."

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        perms=$(ls -l "$file" | awk '{print $1}')
        owner=$(ls -l "$file" | awk '{print $3":"$4}')
        echo "$file : $owner : $perms"
    else
        echo "⚠️ File missing: $file"
    fi
done

for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
        perms=$(ls -ld "$dir" | awk '{print $1}')
        owner=$(ls -ld "$dir" | awk '{print $3":"$4}')
        echo "$dir : $owner : $perms"
    else
        echo "⚠️ Directory missing: $dir"
    fi
done

# Additional verification for HTTPD
if [ -f "$EC2_HTTPD_FILE" ]; then
    echo "✅ httpd.conf exists at $EC2_HTTPD_FILE"
else
    echo "⚠️ httpd.conf missing at $EC2_HTTPD_FILE"
fi

echo "---------------------------------------------"
echo "✅ Charlie Cafe Deployment Completed!"
echo "S3 files synced + permissions applied + httpd.conf verified."
echo "---------------------------------------------"