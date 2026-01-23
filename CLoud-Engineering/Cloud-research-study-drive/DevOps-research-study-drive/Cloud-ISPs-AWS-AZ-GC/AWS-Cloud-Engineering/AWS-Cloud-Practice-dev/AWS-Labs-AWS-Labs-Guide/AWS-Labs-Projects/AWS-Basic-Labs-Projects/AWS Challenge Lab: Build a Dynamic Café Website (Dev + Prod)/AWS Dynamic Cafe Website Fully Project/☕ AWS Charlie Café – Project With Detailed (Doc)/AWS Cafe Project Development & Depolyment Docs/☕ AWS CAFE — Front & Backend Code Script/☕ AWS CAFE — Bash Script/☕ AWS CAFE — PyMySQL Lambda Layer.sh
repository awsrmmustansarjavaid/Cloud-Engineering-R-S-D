#!/bin/bash

# Script to build pymysql Lambda Layer (Amazon Linux 2023 EC2)

echo "Starting pymysql Lambda Layer creation..."

# Install python + pip
sudo dnf install -y python3 python3-pip

# Create directory and go inside
mkdir -p lambda-layer
cd lambda-layer || { echo "Error: Cannot enter lambda-layer folder"; exit 1; }

# Install pymysql to the correct folder structure
pip3 install pymysql -t python/

# Create zip
zip -r pymysql-layer.zip python

# Show result
echo ""
echo "Finished!"
echo "Layer zip file created: $(pwd)/pymysql-layer.zip"
echo "File size:"
ls -lh pymysql-layer.zip
echo ""
echo "Next: Upload this zip to your S3 bucket,"
echo "then create a Lambda Layer from it in AWS console,"
echo "and attach the layer to your Lambda function."
echo ""