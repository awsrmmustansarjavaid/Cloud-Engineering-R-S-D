# 🔥 AWS HANDS-ON LAB – AWS Core Services Hands-On Lab EC2, S3, DynamoDB, SQS, and SNS

> **Author & Architecture Desinger:** Charlie

---

## 🧠 WHAT YOU WILL BUILD (High-Level)

#### You will build:

- A VPC

- A Public Subnet

- An EC2 instance

  - Web Server

  - Application Server

  - Lab IDE (developer access)

- DynamoDB (metadata storage)

- S3 bucket (object storage)

- SQS Queue

- SNS Topic

- Email Notifications

- HTTPS access

- End-to-End request flow

##### This lab simulates a real production-like AWS architecture.

## 🗺️ ARCHITECTURE FLOW (MATCHING THE NUMBERS IN IMAGE)

#### Let’s first understand the numbered flow in your diagram:

```
| Step | Description                                      |
| ---- | ------------------------------------------------ |
| 1    | Users send HTTPS requests                        |
| 2    | Requests reach Web Server                        |
| 3    | Web/App server reads/writes metadata to DynamoDB |
| 4    | Data stored in S3                                |
| 5    | SNS sends notification                           |
| 6    | SQS Queue buffers messages                       |
| 7    | Application Server processes logic               |
| 8    | S3 object access                                 |
```


## AWS Architecture Visual Diagram

! [AWS Architecture Visual Diagram](./AWS%20Core%20Services%20Hands-On%20Lab%20EC2%2C%20S3%2C%20DynamoDB%2C%20SQS%2C%20and%20SNS.jpeg)

Now let’s build it step by step.

---

## 🧪 LAB PREREQUISITES

#### You need:

- AWS Free Tier Account

- Verified Email Address

- Basic Linux commands (I’ll explain)



### 🟩 STEP 1: CREATE VPC
#### WHY?: A VPC is your private network in AWS.

- Open AWS Console

- Go to VPC

- Click Create VPC

- Choose:

    - VPC only

    - Name: Lab-VPC

    - IPv4 CIDR: 10.0.0.0/16

- Click Create VPC

##### ✅ Done

### 🟩 STEP 2: CREATE PUBLIC SUBNET

#### WHY?: EC2 needs internet access → public subnet.


- Go to Subnets

- Click Create subnet

- Select VPC: Lab-VPC

- Name: Public-Subnet

- Availability Zone: any (e.g. us-east-1a)

- CIDR: 10.0.1.0/24

- Create subnet

### 🟩 STEP 3: CREATE INTERNET GATEWAY

#### WHY?: Without IGW, no internet.

- Go to Internet Gateways

- Create IGW → Name: Lab-IGW

- Attach to Lab-VPC

### 🟩 STEP 4: ROUTE TABLE CONFIGURATION

#### WHY? : Traffic must know where to go.

- Go to Route Tables

- Select main route table

- Add route:

    - Destination: 0.0.0.0/0

    - Target: Internet Gateway

- Associate with Public-Subnet

### 🟩 STEP 5: CREATE SECURITY GROUP

#### WHY? : Acts like a virtual firewall.

- Create SG:

- Name: Web-SG

- Inbound rules:

    - HTTP – 80 – Anywhere

    - HTTPS – 443 – Anywhere

    - SSH – 22 – Your IP only

- Outbound: Allow all

### 🟩 STEP 6: LAUNCH EC2 INSTANCE

#### WHY? : 

- This EC2 will host:

    - Web Server

    - Application Server

    - Lab IDE


- Go to EC2 → Launch Instance

- Name: Lab-EC2

- AMI: Amazon Linux 2

- Instance Type: t2.micro (Free tier)

- Key Pair: create/download

- Network:

    - VPC: Lab-VPC

    - Subnet: Public-Subnet

    - Auto-assign public IP: ENABLE

- Security Group: Web-SG

- Launch instance

### 🟩 STEP 7: CONNECT TO EC2 (LAB IDE)

Use EC2 Instance Connect or SSH.

#### Once inside EC2:

```
sudo yum update -y
sudo yum install -y httpd python3 git
sudo systemctl start httpd
sudo systemctl enable httpd
```


### 🟩 STEP 8: SETUP WEB SERVER

```
echo "<h1>Web Server Running</h1>" | sudo tee /var/www/html/index.html
```

##### Open EC2 public IP in browser → ✅ Web server works

### 🟩 STEP 9: CREATE DYNAMODB TABLE

#### WHY? : Stores metadata (as shown in diagram).

- Go to DynamoDB

- Create table:

    - Table name: MetadataTable

    - Partition key: id (String)

- Create table

### 🟩 STEP 10: CREATE S3 BUCKET

#### WHY? : Stores files/objects.

- Go to S3

- Create bucket:

    - Name: lab-storage-unique-name

    - Block public access: ON

- Create bucket

### 🟩 STEP 11: CREATE SQS QUEUE

#### WHY? :Message buffering (decoupling).

- Go to SQS

- Create queue

- Type: Standard

- Name: Lab-Queue

### 🟩 STEP 12: CREATE SNS TOPIC

#### WHY? : Send notifications (email).


- Go to SNS

- Create topic:

    - Name: Lab-Topic

- Create subscription:

    - Protocol: Email

    - Endpoint: your email

- Confirm email

### 🟩 STEP 13: IAM ROLE FOR EC2

#### WHY? : 

- EC2 needs permission to:

    - Access S3

    - DynamoDB

    - SQS

    - SNS

#### Create IAM Role:

- Service: EC2

- Policies:

    - AmazonS3FullAccess

    - AmazonDynamoDBFullAccess

    - AmazonSQSFullAccess

    - AmazonSNSFullAccess
- Attach role to EC2

### 🟩 STEP 14: APPLICATION LOGIC (SIMPLIFIED)

#### Your application will:

- Receive request

- Store metadata in DynamoDB

- Upload file to S3

- Send message to SQS

- Publish SNS notification

### 🟩 STEP 15: TEST COMPLETE FLOW

#### TEST CASE:

- Open browser

- Send request

- Upload data

- Check:

    - DynamoDB entry

    - S3 object

    - SQS message

    - Email received ✅

---

## 🎯 WHAT YOU LEARNED (VERY IMPORTANT)

#### You just practiced:

- VPC networking

- EC2 hosting

- Web & App server architecture

- DynamoDB

- S3

- SNS

- SQS

- IAM roles

- Real cloud design

##### This is real cloud engineer work, not theory.

---
# AWS Hands-On Lab – Test, Verification & Troubleshooting Guide

## Architecture Overview

This document validates the following AWS services integration:

- VPC with Public Subnet
- EC2 (Web Server + Application Server + Lab IDE)
- DynamoDB (Metadata storage)
- S3 (Object storage)
- SQS (Message queue)
- SNS (Email notifications)
- IAM Roles
- Internet Gateway & Route Tables

Purpose: Ensure **100% functional verification** of the lab and provide **real-world troubleshooting**.

---

## 1. End-to-End Test Plan

| Step | Component | Test Objective | Expected Result |
|---|---|---|---|
| 1 | EC2 | Instance running | 2/2 status checks passed |
| 2 | Web Server | HTTP access | Web page loads |
| 3 | IAM | Permissions | No AccessDenied |
| 4 | DynamoDB | Metadata storage | Item visible |
| 5 | S3 | Object upload | File exists |
| 6 | SQS | Message queue | Messages available |
| 7 | SNS | Email notification | Email received |
| 8 | Network | Internet access | Ping success |

---

## 2. EC2 & Web Server Verification

### Test 1: EC2 Health Check
- EC2 Console → Instance → Status checks

**Expected**
- Instance status: OK
- System status: OK

**Fix if failed**
- Restart instance
- Check subnet & route table

---

### Test 2: Web Server Access

```
http://<EC2-PUBLIC-IP>
```

#### Expected Output

```
Web Server Running
```

### Common Issue
- Page not loading

#### Solution
- Security Group missing port 80
- Apache not running:

```bash
sudo systemctl start httpd
sudo systemctl enable httpd
```

## 3. IAM Role Verification

### Test 3: IAM Role Attached to EC2

#### Required policies:

- AmazonS3FullAccess

- AmazonDynamoDBFullAccess

- AmazonSQSFullAccess

- AmazonSNSFullAccess

#### Expected

```
EC2 can access AWS services without credentials
```

#### Common Issue

```
AccessDeniedException
```

#### Solution

- Attach correct IAM role

- Do NOT use access keys on EC2

## 4. DynamoDB Verification

### Test 4: Manual Table Test

#### Create item:

```
{
  "id": "test123",
  "filename": "sample.txt",
  "timestamp": "2025-12-25"
}
```

#### Expected

```
Item saved successfully
```

#### Common Issues

- Partition key mismatch

- Wrong data type

#### Solution

Ensure partition key = id (String)

### Test 5: Application → DynamoDB

#### Expected

```

New items auto-created when app runs
```


#### Common Issue

```
ResourceNotFoundException
```

#### Solution

- Correct table name

- Correct AWS region

## 5. S3 Bucket Verification

### Test 6: Manual Upload

- S3 Console → Upload a file

#### Expected

```
Upload successful
```

### Test 7: EC2 → S3 Upload

```
echo "lab test" > test.txt
aws s3 cp test.txt s3://<your-bucket-name>/
```

#### Expected

```
upload: ./test.txt
```

#### Common Issue

```
Unable to locate credentials
```

#### Solution

- IAM role not attached

- Restart EC2 instance

## 6. SQS Queue Verification

### Test 8: Manual Message

- SQS → Send message

```
Hello from AWS Lab
```

#### Expected

```
Messages available: 1
```

### Test 9: Application → SQS

#### Expected

```
Queue message count increases
```


#### Common Issue

```
NonExistentQueue
```

#### Solution

- Use correct Queue URL

- Check region

## 7. SNS Email Verification

### Test 10: Subscription Confirmation

#### Expected

```
Subscription status: Confirmed
```


#### Common Issue

- Pending confirmation

#### Solution

- Check email inbox / spam

- Click confirmation link

### Test 11: Publish SNS Message

- SNS → Publish message

#### Expected

```
Email received
```

#### Common Issue

- No email received

#### Solution

- Confirm subscription

- Correct topic ARN

## 8. Network & Internet Verification

### Test 12: Internet Access from EC2

```
ping google.com
```

#### Expected

```
Successful replies
```

#### Common Issues

- No Internet Gateway

- Route table missing 0.0.0.0/0

#### Solution

- Attach IGW

- Update route table

## 9. CloudWatch Log Verification

### Test 13: Logs & Errors

- CloudWatch → Logs

#### Expected

```
No AccessDenied or Timeout errors
```

#### Common Issues

- Permission errors

- Network timeout

#### Solution

- Update IAM policies

- Fix security groups

## 10. Common Bugs & Fixes Summary

```
| Issue                  | Root Cause                 | Solution              |
| ---------------------- | -------------------------- | --------------------- |
| Website not loading    | Port 80 blocked            | Update Security Group |
| S3 upload fails        | Missing IAM role           | Attach S3 policy      |
| DynamoDB error         | Wrong table name           | Fix config            |
| SNS email not received | Subscription not confirmed | Confirm email         |
| SQS empty              | Wrong queue URL            | Use correct URL       |
| EC2 no internet        | IGW missing                | Attach IGW            |
| Access denied          | Using access keys          | Use IAM role          |
```

## 11. Final Lab Validation Checklist

- EC2 reachable via browser

- Apache running

- IAM role attached

- DynamoDB item created

- S3 object uploaded

- SQS message visible

- SNS email received

- No CloudWatch errors

##### ✅ If all checks pass, the lab is fully functional and production-ready.

---
