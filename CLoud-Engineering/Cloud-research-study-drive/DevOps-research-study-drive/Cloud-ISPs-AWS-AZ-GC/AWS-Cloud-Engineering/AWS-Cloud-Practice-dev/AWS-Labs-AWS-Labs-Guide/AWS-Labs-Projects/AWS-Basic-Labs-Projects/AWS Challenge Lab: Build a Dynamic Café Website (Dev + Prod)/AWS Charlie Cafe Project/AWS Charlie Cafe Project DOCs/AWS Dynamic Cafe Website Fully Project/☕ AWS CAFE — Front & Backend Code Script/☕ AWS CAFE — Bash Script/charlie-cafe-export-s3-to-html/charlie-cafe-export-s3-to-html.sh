#!/bin/bash
# =========================================================
# CHARLIE CAFE ☕
# S3 TO EC2 EXPORT + PERMISSIONS SCRIPT
# File Name: charlie-cafe-export-s3-to-html.sh
# Secure Version (Uses EC2 IAM Role)
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

# =========================================================
# 📂 EC2 DESTINATIONS
# =========================================================
EC2_HTML_FOLDER="/var/www/html"
EC2_BASH_FOLDER="/home/ec2-user"

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

echo "======================================================="
echo "✅ S3 Export Completed!"
echo "HTML folder → $EC2_HTML_FOLDER"
echo "Bash folder → $EC2_BASH_FOLDER"
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
# 🔎 VERIFY PERMISSIONS
# =========================================================
echo "---------------------------------------------"
echo "Verifying permissions..."

for file in "${FILES[@]}"; do
    perms=$(ls -l "$file" | awk '{print $1}')
    owner=$(ls -l "$file" | awk '{print $3":"$4}')
    echo "$file : $owner : $perms"
done

for dir in "${DIRS[@]}"; do
    perms=$(ls -ld "$dir" | awk '{print $1}')
    owner=$(ls -ld "$dir" | awk '{print $3":"$4}')
    echo "$dir : $owner : $perms"
done

echo "---------------------------------------------"
echo "✅ Charlie Cafe Deployment Completed!"
echo "S3 files synced + permissions applied."
echo "---------------------------------------------"
