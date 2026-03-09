#!/bin/bash
# ==============================================================
# Simple RBAC ZIP & S3 Upload Script
# ==============================================================
set -e

# ===============================
# USER CONFIGURATION
# ===============================
RBAC_DIR="cafe-rbac-layer"        # Folder containing python/
ZIP_FILE="cafe-rbac-layer.zip"    # ZIP package name
S3_BUCKET="charlie-cafe-s3-bucket"
S3_KEY="layers/$ZIP_FILE"         # Path in S3
AWS_REGION="us-east-1"

# ===============================
# STEP 1: Create ZIP
# ===============================
echo "📦 Creating ZIP package..."
if [ ! -d "$RBAC_DIR" ]; then
    echo "❌ Folder $RBAC_DIR does not exist!"
    exit 1
fi

rm -f "$ZIP_FILE"
zip -r "$ZIP_FILE" "$RBAC_DIR" >/dev/null
echo "✅ ZIP created: $ZIP_FILE"

# ===============================
# STEP 2: Upload to S3
# ===============================
echo "☁️ Uploading $ZIP_FILE to s3://$S3_BUCKET/$S3_KEY ..."
aws s3 cp "$ZIP_FILE" "s3://$S3_BUCKET/$S3_KEY" --region "$AWS_REGION"

if [ $? -eq 0 ]; then
    echo "✅ Upload successful!"
    echo "🌐 S3 URL: https://$S3_BUCKET.s3.$AWS_REGION.amazonaws.com/$S3_KEY"
else
    echo "❌ Upload failed!"
    exit 1
fi
