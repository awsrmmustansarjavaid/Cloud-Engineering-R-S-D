# AWS Serverless Inventory Processing Lab
**S3 → Lambda → DynamoDB → Lambda → SNS → Cognito**

> **Author & Architecture Designer:** Charlie
---

## 📌 Lab Objective

Build a **fully serverless inventory management system** on AWS where:

1. Users authenticate using **Amazon Cognito**
2. Inventory file is uploaded to **Amazon S3**
3. **Lambda function** processes uploaded inventory
4. Inventory is stored in **DynamoDB**
5. Another **Lambda function** detects changes
6. **SNS** sends email/mobile notifications

---

## 🧱 Architecture Overview

**Flow:**

User → Dashboard App → Cognito  
Upload Inventory → S3 → Lambda → DynamoDB → Lambda → SNS → Email/SMS

**AWS Services Used:**
- Amazon S3
- AWS Lambda
- Amazon DynamoDB
- Amazon SNS
- Amazon Cognito
- IAM
- CloudWatch

---

## AWS Architecture Diagram

![AWS Architecture Lab](./Serverless%20Inventory%20Management%20System%20on%20AWS.jpeg)

## 🔐 STEP 1: IAM Role for Lambda

### Create IAM Role
- Service: **Lambda**
- Role name:
