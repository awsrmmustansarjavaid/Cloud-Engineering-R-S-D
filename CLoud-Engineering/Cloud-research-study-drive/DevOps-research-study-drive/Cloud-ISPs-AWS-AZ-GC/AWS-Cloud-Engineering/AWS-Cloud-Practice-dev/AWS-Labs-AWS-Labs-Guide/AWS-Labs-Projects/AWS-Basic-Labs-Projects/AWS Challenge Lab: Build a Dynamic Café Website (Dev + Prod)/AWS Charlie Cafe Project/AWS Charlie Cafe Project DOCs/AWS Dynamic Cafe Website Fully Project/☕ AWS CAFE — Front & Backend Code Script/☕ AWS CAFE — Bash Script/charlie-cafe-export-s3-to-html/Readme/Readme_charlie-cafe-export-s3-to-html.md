# Charlie Cafe - charlie-cafe-export-s3-to-html

### ✅ S3 TO EC2 EXPORT SCRIPT

```
sudo nano s3_export.sh
```

[s3_export.sh](./%20S3%20TO%20EC2%20EXPORT%20SCRIPT/ec2-html-s3.sh)

```
sudo chmod +x s3_export.sh
```

```
sudo ./s3_export.sh
```

### ✅ Apache SECURITY & PERMISSIONS

```
sudo nano apache_permissions.sh
```

[apache_permissions.sh](./Apache%20SECURITY%20&%20PERMISSIONS/apache_permissions.sh)

```
sudo chmod +x apache_permissions.sh
```

```
sudo ./apache_permissions.sh
```

## Charlie Cafe Export S3 to HTML Script

### one merged Bash script that will:

- Sync files from S3 → EC2

- Then automatically set Apache permissions

- Script name: charlie-cafe-export-s3-to-html.sh

- Fully working and clean.

- Below is the final merged script.

### Charlie Cafe Export S3 to HTML Script

```
#!/bin/bash
# =========================================================
# CHARLIE CAFE ☕
# S3 TO EC2 EXPORT + PERMISSIONS SCRIPT
# File Name: charlie-cafe-export-s3-to-html.sh
# =========================================================

# =========================================================
# ⚙️ AWS CONFIGURATION
# =========================================================
AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_HERE"
AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY_HERE"
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
EC2_BASH_FOLDER="/home/download"

# =========================================================
# 🚀 STEP 1 — EXPORT FILES FROM S3
# =========================================================
echo "======================================================="
echo "🚀 Starting Charlie Cafe S3 Export..."
echo "Bucket: $S3_BUCKET"
echo "Region: $AWS_REGION"
echo "======================================================="

echo "📥 Syncing HTML folder from S3 to EC2..."
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
aws s3 sync "s3://$S3_BUCKET/$S3_HTML_FOLDER" "$EC2_HTML_FOLDER" \
--region $AWS_REGION --delete

echo "📥 Syncing Bash scripts from S3 to EC2..."
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
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
```

### How to Use the Script

#### 1️⃣ Save Script

```
sudo nano charlie-cafe-export-s3-to-html.sh
```

Paste script → Save.

#### 2️⃣ Make Executable

```
sudo chmod +x charlie-cafe-export-s3-to-html.sh
```

#### 3️⃣ Run Script

```
sudo ./charlie-cafe-export-s3-to-html.sh
```

### What This Script Does (Complete Flow)

1️⃣ Connects to AWS S3

2️⃣ Downloads:

```
S3/html → /var/www/html
S3/bash → /home/download
```

3️⃣ Deletes removed files (--delete)

4️⃣ Sets ownership:

```
apache:apache
```

5️⃣ Sets permissions:

```
Directories → 755
Files → 644
```

6️⃣ Verifies everything.

### Optional (Highly Recommended for Security)

Instead of hardcoding:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

Use IAM Role on EC2 (much safer).

Then remove:

```
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
```

from the script.



### ✅ PRO DevOps production-grade deployment script

a PRO DevOps production-grade deployment script for your Charlie Café system.

This version includes:

✅ S3 → EC2 deployment

✅ Permission fixing

✅ Apache restart

✅ Error detection

✅ Deployment log file

✅ Safe execution (script stops if error occurs)

✅ Timestamp logging

✅ Production-style structure

Script Name:

```
charlie-cafe-auto-deploy.sh
```

#### ✅ Charlie Café PRO Auto Deployment Script

```
#!/bin/bash
# =========================================================
# CHARLIE CAFE ☕ PRO DEPLOYMENT SCRIPT
# S3 → EC2 AUTO DEPLOY + PERMISSIONS + APACHE RESTART
# =========================================================

set -e   # Stop script if any command fails

# =========================================================
# CONFIGURATION
# =========================================================

AWS_REGION="us-east-1"
S3_BUCKET="charlie-cafe-s3-bucket"

S3_HTML_FOLDER="Charlie Cafe Code Drive/html/"
S3_BASH_FOLDER="Charlie Cafe Code Drive/bash script/"

EC2_HTML_FOLDER="/var/www/html"
EC2_BASH_FOLDER="/home/download"

LOG_FILE="/var/log/charlie-cafe-deploy.log"

# =========================================================
# LOGGING FUNCTION
# =========================================================

log() {
echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

log "======================================================="
log "🚀 Charlie Cafe Deployment Started"
log "======================================================="

# =========================================================
# CHECK AWS CLI
# =========================================================

if ! command -v aws &> /dev/null
then
    log "❌ AWS CLI not installed!"
    exit 1
fi

log "✅ AWS CLI detected"

# =========================================================
# SYNC HTML FILES
# =========================================================

log "📥 Syncing HTML files from S3..."

aws s3 sync "s3://$S3_BUCKET/$S3_HTML_FOLDER" "$EC2_HTML_FOLDER" \
--region $AWS_REGION --delete

log "✅ HTML sync completed"

# =========================================================
# SYNC BASH SCRIPTS
# =========================================================

log "📥 Syncing Bash scripts from S3..."

aws s3 sync "s3://$S3_BUCKET/$S3_BASH_FOLDER" "$EC2_BASH_FOLDER" \
--region $AWS_REGION --delete

log "✅ Bash scripts sync completed"

# =========================================================
# FILE LIST
# =========================================================

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

DIRS=(
"/var/www/html/js"
"/var/www/html/css"
)

# =========================================================
# SET PERMISSIONS
# =========================================================

log "🔐 Setting Apache ownership..."

sudo chown apache:apache "${FILES[@]}"
sudo chown -R apache:apache "${DIRS[@]}"

log "📁 Setting directory permissions..."

for dir in "${DIRS[@]}"; do
sudo chmod 755 "$dir"
done

log "📄 Setting file permissions..."

for file in "${FILES[@]}"; do
sudo chmod 644 "$file"
done

log "✅ Permissions applied"

# =========================================================
# VERIFY PERMISSIONS
# =========================================================

log "🔍 Verifying permissions..."

for file in "${FILES[@]}"; do
perms=$(ls -l "$file" | awk '{print $1}')
owner=$(ls -l "$file" | awk '{print $3":"$4}')
log "$file : $owner : $perms"
done

# =========================================================
# RESTART APACHE
# =========================================================

log "🔄 Restarting Apache..."

sudo systemctl restart httpd

log "✅ Apache restarted"

# =========================================================
# DEPLOYMENT COMPLETE
# =========================================================

log "======================================================="
log "🎉 Charlie Cafe Deployment Completed Successfully"
log "======================================================="
```

### Deployment Log File

Every deployment will be saved in:

```
/var/log/charlie-cafe-deploy.log
```

Example log:

```
2026-03-07 20:55:10 - Charlie Cafe Deployment Started
2026-03-07 20:55:11 - HTML sync completed
2026-03-07 20:55:12 - Bash scripts sync completed
2026-03-07 20:55:13 - Permissions applied
2026-03-07 20:55:14 - Apache restarted
2026-03-07 20:55:14 - Deployment Completed
```

### Make Script Executable

```
sudo chmod +x charlie-cafe-auto-deploy.sh
```

Run it:

```
sudo ./charlie-cafe-auto-deploy.sh
```

### Production Automation (Very Powerful)

You can run this automatically every 5 minutes using cron.

Open cron:

```
crontab -e
```

Add:

```
*/5 * * * * /home/ec2-user/charlie-cafe-auto-deploy.sh
```

Now your EC2 auto-syncs with S3 every 5 minutes.

This becomes a mini CI/CD pipeline.

### Ultra-Professional Upgrade (Optional)

If you want, I can also show you how to build FULL AWS DevOps Pipeline for Charlie Café:

Architecture:

```
Developer Push Code
       ↓
GitHub
       ↓
AWS CodePipeline
       ↓
AWS CodeBuild
       ↓
S3
       ↓
EC2 Auto Deploy Script
       ↓
Live Website Updated
```

This is how Netflix / Amazon style deployments work.

#### ✅ charlie-cafe-export-s3-to-html.sh

> **Update Version:1.1**

```
#!/bin/bash
# =========================================================
# CHARLIE CAFE ☕
# S3 TO EC2 EXPORT + PERMISSIONS SCRIPT
# File Name: charlie-cafe-export-s3-to-html.sh
# =========================================================

# =========================================================
# ⚙️ AWS CONFIGURATION
# =========================================================
AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_HERE"
AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY_HERE"
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
EC2_BASH_FOLDER="/home/download"

# =========================================================
# 🚀 STEP 1 — EXPORT FILES FROM S3
# =========================================================
echo "======================================================="
echo "🚀 Starting Charlie Cafe S3 Export..."
echo "Bucket: $S3_BUCKET"
echo "Region: $AWS_REGION"
echo "======================================================="

echo "📥 Syncing HTML folder from S3 to EC2..."
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
aws s3 sync "s3://$S3_BUCKET/$S3_HTML_FOLDER" "$EC2_HTML_FOLDER" \
--region $AWS_REGION --delete

echo "📥 Syncing Bash scripts from S3 to EC2..."
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
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
```

---
#### ✅ charlie-cafe-export-s3-to-html.sh

> **Update Version:1.2**

You should remove the AWS access keys completely from the script and let the EC2 Instance IAM Role authenticate automatically. Since your EC2 already has an IAM role with S3FullAccess, the AWS CLI will automatically use temporary credentials from the Instance Metadata Service (IMDS).

So the fix is simple:

- ❌ Remove AWS_ACCESS_KEY_ID

- ❌ Remove AWS_SECRET_ACCESS_KEY

- ❌ Remove the inline credential usage in aws s3 sync

✅ Keep only --region

This is AWS best practice and much more secure.

### ✅ Final Secure Script (No Access Keys)

```
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
AWS_REGION="ap-southeast-2"
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
EC2_BASH_FOLDER="/home/download"

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
```

### ✅ Why This Works

Your EC2 IAM Role already has:

```
"S3FullAccess"
```

So AWS CLI automatically retrieves credentials from:

```
http://169.254.169.254/latest/meta-data/iam/security-credentials/
```

No keys required.

### 🔐 Security Improvement (Important)

Your IAM role currently allows:

```
"S3FullAccess"
```

A more secure production policy would allow only your bucket:

```
arn:aws:s3:::charlie-cafe-s3-bucket
arn:aws:s3:::charlie-cafe-s3-bucket/*
```

### ✅ charlie-cafe-export-s3-to-html.sh

```
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
```

---
### ✅ charlie-cafe-export-s3-to-html.sh

> **Update Version:1.3**

Perfect! I see exactly what you want: your S3 → EC2 sync script should also handle the httpd.conf file from S3 and place it in /etc/httpd/conf/httpd.conf while maintaining verification and testing.

#### Here’s the fully final working version of your export script:

```
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
```




