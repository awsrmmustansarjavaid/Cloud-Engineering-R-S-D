#!/bin/bash
# =========================================================
# S3 TO EC2 EXPORT SCRIPT
# =========================================================

# =========================
# ⚙️ CONFIGURATION
# =========================
AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_HERE"
AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY_HERE"
AWS_REGION="us-east-1"           # Replace with your bucket region
S3_BUCKET="charlie-cafe-s3-bucket"     # Replace with your S3 bucket name

# =========================
# FOLDERS TO SYNC
# =========================
S3_HTML_FOLDER="html/"
EC2_HTML_FOLDER="/var/www/html"

S3_BASH_FOLDER="bash-scripts/"
EC2_BASH_FOLDER="/home/download"

# =========================
# EXPORT LOGIC
# =========================
echo "======================================================="
echo "Starting S3 to EC2 export..."
echo "Bucket: $S3_BUCKET"
echo "Region: $AWS_REGION"
echo "======================================================="

# Export HTML folder to /var/www/html
echo "Syncing HTML folder..."
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
aws s3 sync "s3://$S3_BUCKET/$S3_HTML_FOLDER" "$EC2_HTML_FOLDER" --region $AWS_REGION --delete

# Export bash script folder to /home/download
echo "Syncing bash scripts folder..."
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
aws s3 sync "s3://$S3_BUCKET/$S3_BASH_FOLDER" "$EC2_BASH_FOLDER" --region $AWS_REGION --delete

echo "======================================================="
echo "S3 export completed successfully!"
echo "HTML folder -> $EC2_HTML_FOLDER"
echo "Bash scripts folder -> $EC2_BASH_FOLDER"
echo "======================================================="