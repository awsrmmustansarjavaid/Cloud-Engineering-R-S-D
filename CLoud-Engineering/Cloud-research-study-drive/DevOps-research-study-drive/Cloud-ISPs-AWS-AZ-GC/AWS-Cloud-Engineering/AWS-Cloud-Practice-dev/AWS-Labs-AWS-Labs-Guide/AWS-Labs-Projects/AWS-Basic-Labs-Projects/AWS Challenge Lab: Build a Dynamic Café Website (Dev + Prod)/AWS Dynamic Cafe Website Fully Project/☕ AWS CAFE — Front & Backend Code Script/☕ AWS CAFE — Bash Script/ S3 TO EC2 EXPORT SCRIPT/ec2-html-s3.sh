#!/bin/bash
# =========================================================
# Upload HTML Folder to S3 with Auto Folder Creation & Full Verification
# =========================================================
# Requirements:
# - AWS CLI installed and configured (profile or env vars)
# - Handles spaces and special characters in filenames
# - Automatically creates the S3 root folder if missing
# =========================================================

# =========================
# CONFIGURATION
# =========================
LOCAL_HTML_DIR="/var/www/html"                # Local html folder to upload
S3_BUCKET="your-s3-bucket-name"              # Replace with your S3 bucket name
S3_ROOT_FOLDER="charlie-cafe-web-drive"      # Folder in S3 to contain html folder
S3_TARGET="s3://$S3_BUCKET/$S3_ROOT_FOLDER/html"  # Final upload path

# AWS CLI profile to use (optional)
AWS_PROFILE="default"

# =========================
# 1. List all local files and directories
# =========================
echo "🔍 Listing all files and directories in $LOCAL_HTML_DIR ..."

# Using mapfile with null delimiter to handle spaces
mapfile -d $'\0' LOCAL_FILES < <(find "$LOCAL_HTML_DIR" -type f -print0)
mapfile -d $'\0' LOCAL_DIRS < <(find "$LOCAL_HTML_DIR" -type d -print0)

echo "📁 Local directories:"
for DIR in "${LOCAL_DIRS[@]}"; do
    echo "$DIR"
done

echo
echo "📄 Local files:"
for FILE in "${LOCAL_FILES[@]}"; do
    echo "$FILE"
done

echo
echo "Total directories: ${#LOCAL_DIRS[@]}"
echo "Total files: ${#LOCAL_FILES[@]}"
echo "---------------------------------------------"

# =========================
# 2. Ensure S3 root folder exists
# =========================
echo "☁️ Ensuring S3 root folder exists: s3://$S3_BUCKET/$S3_ROOT_FOLDER ..."
aws s3 ls "s3://$S3_BUCKET/$S3_ROOT_FOLDER/" --profile "$AWS_PROFILE" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Folder not found. Creating S3 root folder..."
    # Create an empty placeholder file to ensure folder exists
    aws s3 cp /dev/null "s3://$S3_BUCKET/$S3_ROOT_FOLDER/.placeholder" --profile "$AWS_PROFILE"
    if [ $? -eq 0 ]; then
        echo "✅ S3 root folder created successfully."
    else
        echo "❌ ERROR: Failed to create S3 root folder!"
        exit 1
    fi
else
    echo "✅ S3 root folder already exists."
fi
echo "---------------------------------------------"

# =========================
# 3. Upload html folder to S3
# =========================
echo "☁️ Uploading $LOCAL_HTML_DIR to $S3_TARGET ..."
aws s3 cp "$LOCAL_HTML_DIR" "$S3_TARGET/" --recursive --profile "$AWS_PROFILE"
UPLOAD_STATUS=$?

if [ $UPLOAD_STATUS -ne 0 ]; then
    echo "❌ ERROR: Upload failed!"
    exit 1
fi
echo "✅ Upload completed successfully."
echo "---------------------------------------------"

# =========================
# 4. Verify all files uploaded
# =========================
echo "🔍 Verifying all files uploaded to S3 ..."

# Get list of S3 files with relative paths
mapfile -t S3_FILES < <(aws s3 ls "$S3_TARGET/" --recursive --profile "$AWS_PROFILE" | awk '{$1=$2=$3=""; print substr($0,4)}')

# Generate relative paths of local files
RELATIVE_LOCAL_FILES=()
for FILE in "${LOCAL_FILES[@]}"; do
    RELATIVE_LOCAL_FILES+=("$(realpath --relative-to="$LOCAL_HTML_DIR" "$FILE")")
done

# Compare local vs S3
MISSING_FILES=0
for REL_FILE in "${RELATIVE_LOCAL_FILES[@]}"; do
    if ! printf '%s\n' "${S3_FILES[@]}" | grep -Fxq "$REL_FILE"; then
        echo "⚠️ MISSING in S3: $REL_FILE"
        MISSING_FILES=$((MISSING_FILES+1))
    fi
done

echo
if [ $MISSING_FILES -eq 0 ]; then
    echo "✅ Verification complete: All files uploaded successfully!"
else
    echo "⚠️ Verification complete: $MISSING_FILES file(s) missing in S3!"
fi
echo "---------------------------------------------"

# =========================
# 5. Final Report
# =========================
REPORT_FILE="html_upload_report_$(date +%Y%m%d%H%M%S).txt"
{
    echo "📋 Upload Report - $(date)"
    echo "Local directory: $LOCAL_HTML_DIR"
    echo "S3 target: $S3_TARGET"
    echo "---------------------------------------------"
    echo "📁 Local files:"
    for FILE in "${RELATIVE_LOCAL_FILES[@]}"; do
        echo "$FILE"
    done
    echo
    echo "📄 Files in S3:"
    for FILE in "${S3_FILES[@]}"; do
        echo "$FILE"
    done
    echo
    if [ $MISSING_FILES -eq 0 ]; then
        echo "✅ All files uploaded successfully!"
    else
        echo "⚠️ $MISSING_FILES file(s) missing in S3!"
    fi
} > "$REPORT_FILE"

echo "📄 Final report saved to $REPORT_FILE"