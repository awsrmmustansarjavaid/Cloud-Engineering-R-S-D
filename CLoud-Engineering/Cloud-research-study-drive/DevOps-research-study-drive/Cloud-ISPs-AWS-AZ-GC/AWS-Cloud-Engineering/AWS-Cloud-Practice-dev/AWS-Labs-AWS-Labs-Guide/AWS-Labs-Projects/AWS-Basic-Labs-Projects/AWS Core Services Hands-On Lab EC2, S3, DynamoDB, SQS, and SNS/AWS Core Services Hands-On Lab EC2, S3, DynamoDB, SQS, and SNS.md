#🔥 AWS HANDS-ON LAB – AWS Core Services Hands-On Lab EC2, S3, DynamoDB, SQS, and SNS

> **Author & Architecture Desinger:** Charlie


🧠 WHAT YOU WILL BUILD (High-Level)

You will build:

A VPC

A Public Subnet

An EC2 instance

Web Server

Application Server

Lab IDE (developer access)

DynamoDB (metadata storage)

S3 bucket (object storage)

SQS Queue

SNS Topic

Email Notifications

HTTPS access

End-to-End request flow

This lab simulates a real production-like AWS architecture.

🗺️ ARCHITECTURE FLOW (MATCHING THE NUMBERS IN IMAGE)

Let’s first understand the numbered flow in your diagram:

Step	Description
1	Users send HTTPS requests
2	Requests reach Web Server
3	Web/App server reads/writes metadata to DynamoDB
4	Data stored in S3
5	SNS sends notification
6	SQS Queue buffers messages
7	Application Server processes logic
8	S3 object access

Now let’s build it step by step.

🧪 LAB PREREQUISITES
You need:

AWS Free Tier Account

Verified Email Address

Basic Linux commands (I’ll explain)

🟩 STEP 1: CREATE VPC
WHY?

A VPC is your private network in AWS.

HOW:

Open AWS Console

Go to VPC

Click Create VPC

Choose:

VPC only

Name: Lab-VPC

IPv4 CIDR: 10.0.0.0/16

Click Create VPC

✅ Done

🟩 STEP 2: CREATE PUBLIC SUBNET
WHY?

EC2 needs internet access → public subnet.

HOW:

Go to Subnets

Click Create subnet

Select VPC: Lab-VPC

Name: Public-Subnet

Availability Zone: any (e.g. us-east-1a)

CIDR: 10.0.1.0/24

Create subnet

🟩 STEP 3: CREATE INTERNET GATEWAY
WHY?

Without IGW, no internet.

HOW:

Go to Internet Gateways

Create IGW → Name: Lab-IGW

Attach to Lab-VPC

🟩 STEP 4: ROUTE TABLE CONFIGURATION
WHY?

Traffic must know where to go.

HOW:

Go to Route Tables

Select main route table

Add route:

Destination: 0.0.0.0/0

Target: Internet Gateway

Associate with Public-Subnet

🟩 STEP 5: CREATE SECURITY GROUP
WHY?

Acts like a virtual firewall.

HOW:

Create SG:

Name: Web-SG

Inbound rules:

HTTP – 80 – Anywhere

HTTPS – 443 – Anywhere

SSH – 22 – Your IP only

Outbound: Allow all

🟩 STEP 6: LAUNCH EC2 INSTANCE
WHY?

This EC2 will host:

Web Server

Application Server

Lab IDE

HOW:

Go to EC2 → Launch Instance

Name: Lab-EC2

AMI: Amazon Linux 2

Instance Type: t2.micro (Free tier)

Key Pair: create/download

Network:

VPC: Lab-VPC

Subnet: Public-Subnet

Auto-assign public IP: ENABLE

Security Group: Web-SG

Launch instance

🟩 STEP 7: CONNECT TO EC2 (LAB IDE)
HOW:

Use EC2 Instance Connect or SSH.

Once inside EC2:

sudo yum update -y
sudo yum install -y httpd python3 git
sudo systemctl start httpd
sudo systemctl enable httpd

🟩 STEP 8: SETUP WEB SERVER
HOW:
echo "<h1>Web Server Running</h1>" | sudo tee /var/www/html/index.html


Open EC2 public IP in browser → ✅ Web server works

🟩 STEP 9: CREATE DYNAMODB TABLE
WHY?

Stores metadata (as shown in diagram).

HOW:

Go to DynamoDB

Create table:

Table name: MetadataTable

Partition key: id (String)

Create table

🟩 STEP 10: CREATE S3 BUCKET
WHY?

Stores files/objects.

HOW:

Go to S3

Create bucket:

Name: lab-storage-unique-name

Block public access: ON

Create bucket

🟩 STEP 11: CREATE SQS QUEUE
WHY?

Message buffering (decoupling).

HOW:

Go to SQS

Create queue

Type: Standard

Name: Lab-Queue

🟩 STEP 12: CREATE SNS TOPIC
WHY?

Send notifications (email).

HOW:

Go to SNS

Create topic:

Name: Lab-Topic

Create subscription:

Protocol: Email

Endpoint: your email

Confirm email

🟩 STEP 13: IAM ROLE FOR EC2
WHY?

EC2 needs permission to:

Access S3

DynamoDB

SQS

SNS

HOW:

Create IAM Role:

Service: EC2

Policies:

AmazonS3FullAccess

AmazonDynamoDBFullAccess

AmazonSQSFullAccess

AmazonSNSFullAccess
Attach role to EC2

🟩 STEP 14: APPLICATION LOGIC (SIMPLIFIED)

Your application will:

Receive request

Store metadata in DynamoDB

Upload file to S3

Send message to SQS

Publish SNS notification

🟩 STEP 15: TEST COMPLETE FLOW
TEST CASE:

Open browser

Send request

Upload data

Check:

DynamoDB entry

S3 object

SQS message

Email received ✅

🎯 WHAT YOU LEARNED (VERY IMPORTANT)

You just practiced:

VPC networking

EC2 hosting

Web & App server architecture

DynamoDB

S3

SNS

SQS

IAM roles

Real cloud design

This is real cloud engineer work, not theory.