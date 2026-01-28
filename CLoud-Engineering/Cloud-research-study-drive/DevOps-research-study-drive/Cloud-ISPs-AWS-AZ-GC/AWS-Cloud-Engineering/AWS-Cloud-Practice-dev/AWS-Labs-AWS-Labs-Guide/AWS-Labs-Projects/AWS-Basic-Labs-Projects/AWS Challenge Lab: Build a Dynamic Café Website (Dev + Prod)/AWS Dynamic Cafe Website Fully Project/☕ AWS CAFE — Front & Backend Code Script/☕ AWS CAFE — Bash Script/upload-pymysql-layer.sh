#!/bin/bash
# =========================================
# Bash Script: Upload PyMySQL Lambda Layer via S3
# =========================================

# -------- CONFIGURATION --------
# AWS credentials (replace with your own)
AWS_ACCESS_KEY_ID="YOUR_AWS_ACCESS_KEY"
AWS_SECRET_ACCESS_KEY="YOUR_AWS_SECRET_KEY"
AWS_DEFAULT_REGION="us-east-1"

# S3 bucket and path
S3_BUCKET="charlie-cafe-s3-bucket"
S3_KEY="layers/pymysql-layer.zip"

# Local layer folder
LAYER_DIR="lambda-layer"
ZIP_FILE="pymysql-layer.zip"

# -------- STEP 0: Configure AWS CLI --------
echo "✅ Configuring AWS CLI..."
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set default.region "$AWS_DEFAULT_REGION"

# Verify CLI configuration
echo "🔹 Verifying AWS CLI identity..."
aws sts get-caller-identity

# -------- STEP 1: Prepare Lambda Layer --------
echo "✅ Installing Python & Pip (if missing)..."
sudo dnf install -y python3 python3-pip

echo "✅ Creating layer folder..."
mkdir -p "$LAYER_DIR/python"

echo "✅ Installing PyMySQL into layer folder..."
pip3 install pymysql -t "$LAYER_DIR/python"

# -------- STEP 2: Zip the layer --------
echo "✅ Zipping layer..."
zip -r "$ZIP_FILE" "$LAYER_DIR"

# Confirm zip exists
echo "🔹 Layer ZIP details:"
ls -lh "$ZIP_FILE"

# -------- STEP 3: Upload to S3 --------
echo "✅ Uploading ZIP to S3..."
aws s3 cp "$ZIP_FILE" "s3://$S3_BUCKET/$S3_KEY"

echo "✅ Upload complete!"
echo "You can now attach this layer to your Lambda function."
