# Charlie Cafe - ec2-html-s3.sh

### ec2-html-s3.sh

> **Update Version:1.0**

Absolutely! I can write a fully commented Bash script for your use case. Since you don’t want to include AWS credentials in the script, I’ll assume you have them configured via AWS CLI profiles or environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN) already.

This script will:

- List all files and directories inside /var/www/html.

- Upload the html folder to an S3 bucket under a folder charlie-cafe-web-drive/html.

- Verify that the bucket folder exists.

- Verify that all files and subdirectories were uploaded.

- Generate a final report showing which files exist in local vs S3.

#### Here’s the script:

```
#!/bin/bash
# =========================================================
# Upload HTML Folder to S3 with Verification
# =========================================================
# Requirements:
# - AWS CLI installed and configured (profile or env vars)
# - jq installed for JSON parsing (optional but recommended)
# =========================================================

# =========================
# CONFIGURATION
# =========================
LOCAL_HTML_DIR="/var/www/html"        # Local html folder to upload
S3_BUCKET="charlie-cafe-s3-bucket"       # Replace with your S3 bucket name
S3_ROOT_FOLDER="charlie-cafe-web-drive"  # Folder in S3 to contain html folder
S3_TARGET="$S3_BUCKET/$S3_ROOT_FOLDER/html"

# Optional: Use a specific AWS CLI profile
AWS_PROFILE="default"

# =========================
# 1. List all local files and directories
# =========================
echo "Listing all files and directories in $LOCAL_HTML_DIR ..."
LOCAL_FILES=$(find "$LOCAL_HTML_DIR" -type f)
LOCAL_DIRS=$(find "$LOCAL_HTML_DIR" -type d)

echo "Local directories:"
echo "$LOCAL_DIRS"
echo
echo "Local files:"
echo "$LOCAL_FILES"
echo
echo "Total directories: $(echo "$LOCAL_DIRS" | wc -l)"
echo "Total files: $(echo "$LOCAL_FILES" | wc -l)"
echo "---------------------------------------------"

# =========================
# 2. Upload html folder to S3
# =========================
echo "Uploading $LOCAL_HTML_DIR to s3://$S3_TARGET ..."
aws s3 cp "$LOCAL_HTML_DIR" "s3://$S3_TARGET/" --recursive --profile "$AWS_PROFILE"
UPLOAD_STATUS=$?

if [ $UPLOAD_STATUS -ne 0 ]; then
    echo "ERROR: Upload failed!"
    exit 1
fi
echo "Upload completed successfully."
echo "---------------------------------------------"

# =========================
# 3. Verify S3 folder creation
# =========================
echo "Verifying S3 folder: s3://$S3_BUCKET/$S3_ROOT_FOLDER ..."
aws s3 ls "s3://$S3_BUCKET/$S3_ROOT_FOLDER/" --profile "$AWS_PROFILE"
if [ $? -eq 0 ]; then
    echo "S3 folder exists."
else
    echo "ERROR: S3 folder does not exist!"
    exit 1
fi
echo "---------------------------------------------"

# =========================
# 4. Verify all files uploaded
# =========================
echo "Verifying all files uploaded to S3 ..."
S3_FILES=$(aws s3 ls "s3://$S3_TARGET/" --recursive --profile "$AWS_PROFILE" | awk '{print $4}')

echo "Files found in S3:"
echo "$S3_FILES"

# Compare local vs S3
echo
echo "Generating verification report ..."
MISSING_FILES=0
for FILE in $LOCAL_FILES; do
    REL_PATH=$(realpath --relative-to="$LOCAL_HTML_DIR" "$FILE")
    if ! echo "$S3_FILES" | grep -qx "$REL_PATH"; then
        echo "MISSING in S3: $REL_PATH"
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
# 4.a Final report
# =========================
REPORT_FILE="html_upload_report_$(date +%Y%m%d%H%M%S).txt"
{
    echo "Upload Report - $(date)"
    echo "Local directory: $LOCAL_HTML_DIR"
    echo "S3 target: s3://$S3_TARGET/"
    echo "---------------------------------------------"
    echo "Local files:"
    echo "$LOCAL_FILES"
    echo
    echo "Files in S3:"
    echo "$S3_FILES"
    echo
    if [ $MISSING_FILES -eq 0 ]; then
        echo "All files uploaded successfully ✅"
    else
        echo "$MISSING_FILES file(s) missing in S3 ⚠️"
    fi
} > "$REPORT_FILE"

echo "Final report saved to $REPORT_FILE"
```

### ✅ Notes:

- This script uses aws s3 cp --recursive to upload the entire html folder.

- It checks all files in /var/www/html against S3 recursively.

- The report lists both local files and uploaded files, and shows missing files if any.

- It does not contain AWS credentials; make sure your environment is configured (aws configure) or use a profile.

### ✅ handle spaces in filenames and fully preserve folder structure in S3

Perfect! I’ve rewritten your Bash script to handle spaces in filenames, fully preserve the directory structure, verify uploads, and generate a detailed final report. It’s fully commented and production-ready.

```
#!/bin/bash
# =========================================================
# Upload HTML Folder to S3 with Full Verification
# =========================================================
# Requirements:
# - AWS CLI installed and configured (profile or env vars)
# - jq installed (optional, not strictly required)
# - Handles spaces and special characters in filenames
# =========================================================

# =========================
# CONFIGURATION
# =========================
LOCAL_HTML_DIR="/var/www/html"                # Local html folder to upload
S3_BUCKET="charlie-cafe-s3-bucket"              # Replace with your S3 bucket name
S3_ROOT_FOLDER="charlie-cafe-web-drive"      # Folder in S3 to contain html folder
S3_TARGET="s3://$S3_BUCKET/$S3_ROOT_FOLDER/html"

# AWS CLI profile to use (optional)
AWS_PROFILE="default"

# =========================
# 1. List all local files and directories
# =========================
echo "🔍 Listing all files and directories in $LOCAL_HTML_DIR ..."
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
# 2. Upload html folder to S3
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
# 3. Verify S3 folder creation
# =========================
echo "🔍 Verifying S3 folder: s3://$S3_BUCKET/$S3_ROOT_FOLDER ..."
aws s3 ls "s3://$S3_BUCKET/$S3_ROOT_FOLDER/" --profile "$AWS_PROFILE" > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ S3 folder exists."
else
    echo "❌ ERROR: S3 folder does not exist!"
    exit 1
fi
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
```

### ✅ Key Improvements:

- Handles spaces and special characters in filenames.

- Preserves the directory structure in S3 (html folder remains intact under charlie-cafe-web-drive).

- Generates a final report listing all local files, uploaded files, and missing files if any.

- Fully uses arrays to avoid issues with filenames.

- Safe for production; does not include AWS keys in the script.



### ✅ enhance it to automatically create the charlie-cafe-web-drive folder in S3

Perfect! I’ve updated the script so that it automatically creates the S3 root folder (charlie-cafe-web-drive) if it doesn’t exist, preserves the full directory structure, handles spaces in filenames, verifies all uploads, and generates a comprehensive final report. It’s fully commented and ready to run.

```
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
S3_BUCKET="charlie-cafe-s3-bucket"              # Replace with your S3 bucket name
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
```

### ✅ Key Features in this Final Version:

- Automatic S3 folder creation: If charlie-cafe-web-drive doesn’t exist, it creates it safely with a .placeholder.

- Handles spaces and special characters: Using mapfile -d $'\0' and find -print0.

- Preserves directory structure: The html folder remains intact in S3.

- Full verification: Compares local files vs uploaded files in S3.

- Final report: Includes local files, uploaded files, missing files, and timestamped report file.

- Safe production use: No AWS keys in script; uses CLI profile or environment variables.
---

