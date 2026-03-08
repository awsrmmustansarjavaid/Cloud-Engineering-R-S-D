#!/bin/bash
# =========================================
# Bash Script: Create PyMySQL Lambda Layer
# Correct Structure for AWS Lambda
# =========================================

set -e  # Exit on error

# -------- CONFIGURATION --------
AWS_DEFAULT_REGION="us-east-1"

S3_BUCKET="charlie-cafe-s3-bucket"
S3_KEY="layers/pymysql-layer.zip"

# Local build folders
BUILD_DIR="lambda-layer"
PYTHON_DIR="$BUILD_DIR/python"
ZIP_FILE="pymysql-layer.zip"

# -------- STEP 1: Prepare Environment --------
echo "✅ Installing Python & Pip (if missing)..."
sudo dnf install -y python3 python3-pip zip

# Clean old builds
echo "🧹 Cleaning old build files..."
rm -rf "$BUILD_DIR" "$ZIP_FILE"

# -------- STEP 2: Create Correct Folder Structure --------
echo "📁 Creating Lambda layer structure..."
mkdir -p "$PYTHON_DIR"

# -------- STEP 3: Install PyMySQL --------
echo "📦 Installing PyMySQL into python/ folder..."
pip3 install pymysql -t "$PYTHON_DIR" --no-cache-dir

# -------- STEP 4: Zip ONLY python/ --------
echo "🗜️ Zipping layer (correct structure)..."
cd "$BUILD_DIR"
zip -r "../$ZIP_FILE" python
cd ..

# -------- STEP 5: Verify ZIP CONTENT --------
echo "🔍 Verifying ZIP structure..."
unzip -l "$ZIP_FILE"

# -------- STEP 6: Upload to S3 --------
echo "☁️ Uploading to S3..."
aws s3 cp "$ZIP_FILE" "s3://$S3_BUCKET/$S3_KEY" --region "$AWS_DEFAULT_REGION"

echo "✅ DONE!"
echo "Attach this layer to Lambda (Python 3.9 / 3.10 / 3.11)"
