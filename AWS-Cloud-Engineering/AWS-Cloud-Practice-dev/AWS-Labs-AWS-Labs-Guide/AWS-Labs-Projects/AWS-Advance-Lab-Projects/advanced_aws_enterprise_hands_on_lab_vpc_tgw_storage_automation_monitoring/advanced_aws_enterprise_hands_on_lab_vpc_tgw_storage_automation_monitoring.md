# Advanced AWS Enterprise Hands-On Lab

> **Author:** Charlie
> 
> **Level:** Advanced (Associate → Professional)
>  
> **Purpose:** End‑to‑end enterprise AWS hands‑on lab covering networking, storage, automation, monitoring, and Linux administration.

---

## 1. Lab Scenario (Real‑World Context)
You are a cloud engineer designing a **secure, scalable, enterprise‑grade AWS architecture** similar to an on‑premises environment.  
The environment must support:
- Multi‑VPC connectivity
- Centralized routing (Transit Gateway)
- Private storage access
- Shared and non‑shared storage
- Linux user and permission management
- Automation using Lambda
- Monitoring using CloudWatch

No Active Directory or domain services are required.

---

## 2. Services Used
- Amazon VPC
- Transit Gateway (TGW)
- NAT Gateway
- VPC Endpoints (S3)
- EC2 (Public & Private)
- Elastic IP (EIP)
- Elastic Network Interface (ENI)
- EBS
- EFS
- S3
- RDS (MySQL)
- IAM Roles
- CloudWatch
- CloudTrail
- AWS Lambda

---

## 3. Network Architecture Overview
- VPC‑1 (Admin / Public access)
- VPC‑2 (Private application resources)
- Transit Gateway connects VPC‑1 and VPC‑2
- Private subnets use NAT Gateway for internet access
- S3 accessed privately via VPC Endpoint


# 🎓 AWS Architecture Diagram

![Advanced AWS Enterprise Hands-On Lab Diagram](https://raw.githubusercontent.com/awsrmmustansarjavaid/aws-research-study/refs/heads/main/AWS-Labs-AWS-Labs-Guide/advanced_aws_enterprise_hands_on_lab_vpc_tgw_storage_automation_monitoring/advanced_aws_enterprise_hands_on_lab_vpc_tgw_storage_automation_monitoring.png)

---

## 4. Create VPC and Subnets
### 4.1 Create VPC
- Name: `AdvancedLabVPC`
- CIDR: `10.10.0.0/16`

### 4.2 Create Subnets
- Public Subnet: `10.10.1.0/24`
- Private Subnet: `10.10.2.0/24`

Enable auto‑assign public IP **only** on the public subnet.

---

## 5. Internet Gateway and NAT Gateway
### 5.1 Internet Gateway
- Create IGW and attach to VPC

### 5.2 NAT Gateway
- Create NAT in public subnet
- Name: advancedlab-secure-NATGW
- Allocate Elastic IP

### 5.3 Route Tables
- Public RT → `0.0.0.0/0` → IGW
- Private RT → `0.0.0.0/0` → NAT

---

## 6. Transit Gateway Configuration
### 6.1 Create Transit Gateway
- Name: `AdvancedLab-TGW`
- ASN: 64512

### 6.2 Attach VPCs
- Attach VPC‑1 and VPC‑2 to TGW
- Enable route propagation

### 6.3 Update Route Tables
- Add routes pointing remote VPC CIDRs to TGW

---

## 7. S3 Bucket with VPC Endpoint
### 7.1 Create S3 Bucket
- Name: `advancedlab-secure-bucket`
- Block all public access

#### click on this link to comnplete this task.... 

[AWS S3 End-to-End Labs Guide](https://github.com/awsrmmustansarjavaid/aws-research-study/blob/main/AWS-Labs-AWS-Labs-Guide/AWS%20Individual%20Service%20Complete%20Lab%20Guide/aws_s_3.md)

### 7.2 Create VPC Endpoint
- Name : advancedlab-secure-GWEP
- Type: Gateway Endpoint
- Service: S3
- Attach to private route table


---

## 8. RDS MySQL (Private)
- DB instance identifier Name: advancedlab-secure-RDS
- User: admin
- Password: admin123
- Engine: MySQL
- Instance: db.t3.micro
- Public access: No
- Subnet group: Private subnet
- SG: Allow 3306 only from private EC2

#### click on this link to comnplete this task.... 

[AWS RDS Lab Guide](https://github.com/awsrmmustansarjavaid/aws-research-study/blob/main/AWS-Labs-AWS-Labs-Guide/AWS%20Individual%20Service%20Complete%20Lab%20Guide/AWS%20RDS.md)

---

## 9. EC2 Instances
### 9.1 Public EC2 (Admin)
- Name: advancedlab-secure-pub-ec
- Subnet: Public
- Elastic IP attached
- Used for administration

### 9.2 Private EC2 (Application)
- Name: advancedlab-secure-pvt-ec
- Subnet: Private
- Access via Bastion or SSM

---

## 10. Elastic IP (EIP) Lab
- Allocate EIP
- Associate with Public EC2
- Verify SSH using static IP

---

## 11. Elastic Network Interface (ENI) Lab
### 11.1 Create ENI
- Subnet: Private
- SG: PrivateEC2-SG

### 11.2 Attach ENI
- Attach as secondary interface

### 11.3 Verify
```bash
ip a
```

### 11.4 Detach and Reattach (Failover Concept)

---

## 12. EBS Lab (Block Storage)

#### click on this link to comnplete this task.... 

[AWS EBS Lab Guide](https://github.com/awsrmmustansarjavaid/aws-research-study/blob/main/AWS-Labs-AWS-Labs-Guide/AWS%20Individual%20Service%20Complete%20Lab%20Guide/AWS%20EBS.md)

---

## 13. Linux User, Group & Permissions

#### click on this link to comnplete this task.... 

[AWS EC2 CLI Lab Guide](https://github.com/awsrmmustansarjavaid/aws-research-study/blob/main/AWS-Labs-AWS-Labs-Guide/AWS%20Individual%20Service%20Complete%20Lab%20Guide/AWS%20EC2.md)

---

## 14. EFS Lab (Shared Storage)

#### click on this link to comnplete this task.... 

[AWS EC2 CLI Lab Guide](https://github.com/awsrmmustansarjavaid/aws-research-study/blob/main/AWS-Labs-AWS-Labs-Guide/AWS%20Individual%20Service%20Complete%20Lab%20Guide/AWS%20EFS.md)

---

## 15. Lambda + EFS Automation (Scenario)

### Scenario
Lambda scans files written to EFS and logs metadata to CloudWatch.

### 15.1 Create IAM Role 
- **Name:** AWSLambdaVPCAccessExecutionRole

- **Service:** Lambda

##### Trust relationship (must be EXACT)

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

#### Attach IAM Policies with IAM role 

##### Mandatory Managed Policies:

```
✔ AWSLambdaVPCAccessExecutionRole
✔ AWSLambdaBasicExecutionRole
✔ Custom Inline Policy
```

##### Custom Inline Policy (EFS Access – REQUIRED)

**Managed policies do NOT cover EFS access. You must add a custom inline policy.**

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowEFSMount",
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite",
        "elasticfilesystem:ClientRootAccess"
      ],
      "Resource": "*"
    }
  ]
}
```

**👉 This allows Lambda to:**

- **✔ Mount EFS**

- **✔ Write to EFS**

- **✔ Use EFS access points**

##### 💡 In production, you should restrict Resource to:

```
arn:aws:elasticfilesystem:region:account-id:file-system/fs-xxxx
```

### 15.2 Create Lambda Function

- **Name:** advancedlab-secure-Lambda

- **Runtime:** Python 3.10 (recommended)

- **Architecture:** x86_64

- **Timeout:** 30–60 seconds

- **Memory:** 512 MB (minimum recommended for EFS)

- **Ephemeral storage:** default (512 MB is fine)

- **Create Lambda inside VPC**

- **Attach EFS access point**

### 15.3 VPC Configuration for Lambda (VERY IMPORTANT)

- **In Lambda → Configuration → VPC →  Edit **

- **VPC:** Choose same VPC as EFS

- **Subnets:** Choose all PRIVATE subnets

###### Must be in same AZs as EFS mount targets

#### Security Group (Lambda SG): 

- **Inbound:** NONE

- **Outbound:** TCP 2049 → EFS Security Group

**Click on Save**

### 15.4 EFS Configuration (Required for Lambda)

##### EFS must have:

- **Mount target in each AZ used by Lambda**

- **Security group allowing NFS**

- **EFS Security Group – Inbound :**

```
Type: NFS
Port: 2049
Source: Lambda Security Group
```

### 15.5 EFS Access Point (BEST PRACTICE)

- **Create Access Point**

- **Path:** /lambda

- **POSIX user:**

```
UID: 1000

GID: 1000

```

- **Root directory permissions:**

```
Owner UID: 1000
Owner GID: 1000
Permissions: 750
```

**This avoids permission issues.**



### 15.6 Attach EFS to Lambda (THIS STEP IS OFTEN MISSED)

- **In Lambda → Configuration → File system**

- **File system:** AdvancedLabEFS

- **Access point:** fsap-xxxx

- **Local mount path:**

```
/mnt/efs
```

**✔ Lambda automatically mounts EFS here.**

### 15.7 Lambda Code Example (Validation Test)

**✔ Use this to prove everything works.**

#### Python code

```
import os

def lambda_handler(event, context):
    path = "/mnt/efs/lambda-test.txt"

    with open(path, "a") as f:
        f.write("Lambda wrote to EFS successfully\n")

    files = os.listdir("/mnt/efs")

    return {
        "statusCode": 200,
        "message": "EFS write successful",
        "files": files
    }
```

### 15.8 Test & Validate (DO NOT SKIP)

#### Invoke Lambda

- **Test event → empty JSON {}**


- **Check CloudWatch Logs**

##### You should see:

**✔ No permission errors**

**✔ No mount errors**

#### Verify from EC2

##### On EC2 (mounted EFS):

```
cat /efs/lambda-test.txt
```

**✔ If file exists → Lambda ↔ EFS integration is SUCCESSFUL**


### 15.9 Lambda & EventBridge Automation 

#### Create Lambda Trigger

- **Go to Lambda trigger → EventBridge**

- **Rule → Create a new rule → advancedlab-secure-Lambda**

- **Rule type →  Schedule expression  → cron(0 17 ? * MON-FRI *)**

- **Add**

- **In Lambda → Configuration → Trigger → advancedlab-secure-Lambda → Edit**

- **Cron expression: set time**

- **Additional settings → Configure target input → JSON → {} → update**


### 15.10 Lambda Automation Lab Validation

#### click on this link to comnplete this task.... 

[Lambda Automation Lab Validation](https://github.com/awsrmmustansarjavaid/aws-research-study/blob/main/AWS-Labs-AWS-Labs-Guide/advanced_aws_enterprise_hands_on_lab_vpc_tgw_storage_automation_monitoring/Lab%20Validation%20Testing/LambdaAutomationValidation.md)




---

## 16. CloudWatch Monitoring
### Resources Monitored
- EC2 (CPU, Disk)
- RDS
- NAT Gateway
- Lambda
- S3

#### click on this link to comnplete this task.... 

[CloudWatch Monitoring](https://github.com/awsrmmustansarjavaid/aws-research-study/blob/main/AWS-Labs-AWS-Labs-Guide/AWS%20Individual%20Service%20Complete%20Lab%20Guide/CloudWatch.md)

---

## 17. Transit Gateway Metrics Lab
### 17.1 Enable TGW Flow Logs
- Destination: CloudWatch Logs

### 17.2 View Metrics
- BytesIn
- BytesOut
- PacketsDropCount

### 17.3 Create Alarm
- BytesIn > 10 MB

---

## 18. Cross‑VPC SMB File Sharing (Important Concept)
### Key Rule
❌ EBS cannot be shared directly

### Working Method
```
EBS → EC2 → SMB → TGW → Another VPC EC2
```

### SMB Setup (Linux)
```bash
yum install -y samba
systemctl enable smb --now
```

`smb.conf`:
```
[ebsshare]
path = /data
read only = no
```

---

## 19. Security Best Practices
- Least‑privilege IAM roles
- SG‑to‑SG rules
- NACL hardening
- CloudTrail enabled
- S3 access only via VPC Endpoint

---

## 20. Final Outcome
You now understand and implemented:
- Enterprise AWS networking
- TGW routing & monitoring
- EBS vs EFS
- Linux permissions
- ENI & EIP
- Lambda automation
- Cross‑VPC file access (without AD)

---

## 21. Recommended Next Steps
- Convert to Terraform
- Add Auto Scaling
- Replace SMB with EFS or FSx
- Add AWS Backup

---

# 📙 Lab Name: AWS Managerial Tools & Disaster Management Policies

## Section 1 - AWS CloudWatch (Monitoring)

### 1.1  Access CloudWatch
- **Login to AWS Console**

- **Navigate to CloudWatch service**

### 1.2: Create Dashboard

- **Click "Dashboards" → "Create dashboard"**

- **Name:**

```
Production-Monitoring
```

- **Add widgets:**

```
Line graph for EC2 CPU utilization
Number widget for billing
Log widget for application logs
```


### 1.3: Set Up Alarms

- **Click "Alarms" → "Create alarm"**

- **Select metric (e.g., EC2 > Per-Instance Metrics > CPUUtilization)**

- **Conditions:** Greater than 80%

- **Period:** 5 minutes

- **Actions:** Send notification to SNS topic


- **Create SNS topic:** High-CPU-Alert

- **Add email subscription**

- **Name alarm:** High-CPU-Usage

### 1.4: Create Billing Alarm


- **Region:** Switch to US East (N. Virginia)

- **CloudWatch → Billing → Total Estimated Charge**

- **Threshold:** > $50

- **Action:** Email notification

## Section 2 — AWS Backup (Disaster Recovery)

In this section, you will configure **AWS Backup** to implement a disaster recovery strategy for production resources. This includes creating a backup vault, defining a backup plan, assigning resources, and testing a restore operation.

---

### Step 1: Create a Backup Vault

1. Open the **AWS Management Console**
2. Navigate to **AWS Backup**
3. Select **Backup vaults**
4. Click **Create backup vault**

**Configuration:**
- **Vault name:** `Production-Backup-Vault`
- **Encryption:**
  - Use **AWS managed KMS key**, or  
  - Select a **customer-managed KMS key** (recommended for production)
- **Tags:**
  - `Environment = Production`
  - `Purpose = Disaster-Recovery`

5. Click **Create backup vault**

---

### Step 2: Create a Backup Plan

1. Go to **AWS Backup → Backup plans**
2. Click **Create backup plan**
3. Choose **Start with a template**
4. Select template: `Daily-Monthly-1yr-Retention`

**Plan Details:**
- **Backup plan name:** `Production-Backup-Plan`

---

#### Backup Rule Configuration

- **Rule name:** `Daily-Backups`
- **Backup frequency:** Daily
- **Backup window:** `01:00 AM – 03:00 AM`
- **Backup vault:** `Production-Backup-Vault`
- **Retention period:** 35 days

**Lifecycle Settings:**
- Move to **Cold Storage:** After 7 days
- Delete after: 35 days

**Cross-Region Backup (DR):**
- **Copy to another AWS Region:** Enabled
- **Destination region:** Select a different region for disaster recovery

5. Review the configuration  
6. Click **Create backup plan**

---

### Step 3: Assign Resources to the Backup Plan

1. After creating the plan, select **Assign resources**
2. Click **Assign resources**

**Assignment Configuration:**
- **Assignment name:** `Production-Resources`
- **IAM role:**
  - Use **Default AWS Backup role**, or
  - Create a new IAM role with required permissions

**Resource Selection Method:**
- **By tags (Recommended):**
  - `Environment = Production`

**OR**

- **By resource type:**
  - EC2 instances
  - RDS databases
  - EFS file systems

3. Click **Assign resources**

---

### Step 4: Test Backup Restore (Validation)

1. Navigate to **AWS Backup → Backup vaults**
2. Select **Production-Backup-Vault**
3. Open **Recovery points**
4. Choose a backup recovery point
5. Click **Restore**

**Restore Configuration:**
- Select **Instance type**
- Choose **VPC and subnet**
- Assign appropriate **Security Groups**
- Review restore settings

6. Click **Start restore job**
7. Monitor restore progress from **Restore jobs**
8. Verify the restored resource is operational

---

### Outcome

By completing this section, you have:
- Implemented automated backups
- Enabled cross-region disaster recovery
- Protected production workloads
- Validated recovery through restore testing



## Section 3 — Disaster Recovery Plan (Multi-Region)

This section implements a **multi-region disaster recovery (DR) strategy** using AWS managed services. The design ensures high availability and business continuity by replicating data and enabling automated traffic failover.

---

### DR Regions Overview

- **Primary Region:** `us-east-1`
- **Disaster Recovery (DR) Region:** `us-west-2`

---

## 1. Cross-Region Replication

### 1.1 S3 Cross-Region Replication (CRR)

S3 Cross-Region Replication ensures that objects stored in the primary region are automatically replicated to the DR region.

#### Step 1: Create Source S3 Bucket (Primary Region)

1. Open **Amazon S3**
2. Click **Create bucket**

**Configuration:**
- **Region:** `us-east-1`
- **Bucket name:** `prod-app-source-bucket`
- **Versioning:** Enabled (required for replication)

3. Click **Create bucket**

---

#### Step 2: Create Destination S3 Bucket (DR Region)

1. Create a new S3 bucket

**Configuration:**
- **Region:** `us-west-2`
- **Bucket name:** `prod-app-dr-bucket`
- **Versioning:** Enabled

2. Click **Create bucket**

---

#### Step 3: Configure Replication Rule

1. Open the **source bucket**
2. Go to **Management → Replication rules**
3. Click **Create replication rule**

**Replication Rule Settings:**
- **Rule name:** `S3-CRR-Rule`
- **Status:** Enabled
- **Objects to replicate:** All objects
- **Destination bucket:** `prod-app-dr-bucket` (us-west-2)
- **IAM role:** Auto-create new role
- **Storage class:** Same as source

4. Review and **Create rule**

---

### 1.2 RDS Cross-Region Read Replica

RDS cross-region read replicas provide database redundancy and fast recovery during regional failures.

#### Step 1: Create Read Replica

1. Open **Amazon RDS**
2. Select the **production database**
3. Choose **Actions → Create read replica**

**Configuration:**
- **Destination region:** `us-west-2`
- **DB instance class:** Match production
- **Storage type:** Match production
- **Multi-AZ:** Optional (recommended for DR)

4. Click **Create read replica**

---

## 2. Route 53 DNS Failover Configuration

Route 53 failover routing automatically redirects traffic to the DR region when the primary region becomes unhealthy.

---

### Step 1: Create Route 53 Failover Record

1. Open **Amazon Route 53**
2. Go to **Hosted zones**
3. Select your hosted zone (e.g., `example.com`)
4. Click **Create record**

---

### Step 2: Configure Primary Record (Primary Region)

**Record Settings:**
- **Record name:** `www.example.com`
- **Record type:** A
- **Routing policy:** Failover
- **Failover record type:** Primary
- **Value / Alias:** Primary Load Balancer (us-east-1)
- **Health check:** Create new health check

---

### Step 3: Configure Health Check

**Health Check Configuration:**
- **Protocol:** HTTPS
- **Port:** 443
- **Path:** `/health`
- **Request interval:** 30 seconds
- **Failure threshold:** 3

---

### Step 4: Configure Secondary Record (DR Region)

**Record Settings:**
- **Failover record type:** Secondary
- **Value / Alias:** DR Load Balancer (us-west-2)
- **Health check:** Not required for secondary

5. Click **Create records**

---

## Outcome

After completing this section, you have:
- Enabled S3 cross-region data replication
- Created RDS cross-region read replicas
- Implemented DNS-based automated failover
- Established a resilient multi-region disaster recovery architecture


---

# 📙 Lab Name: AWS Managerial Tools & Disaster Management Policies

## Lab Objective
This hands-on lab focuses on **AWS storage management, security controls, VPC networking, and database deployment** using best practices suitable for production environments.

---

## A. Amazon S3 Storage Management

### Step 1: Create and Configure an S3 Bucket

1. Open the **AWS Management Console**
2. Navigate to **Amazon S3**
3. Click **Create bucket**

**Bucket Configuration:**
- **Bucket name:** `my-company-data-2024` (must be globally unique)
- **Region:** `us-east-1`
- **Block all public access:** Enabled
- **Versioning:** Enabled
- **Encryption:** SSE-S3 (Amazon S3 managed key)
- **Tags:**
  - `Project = DataStorage`

4. Click **Create bucket**

---

### Step 2: Configure S3 Lifecycle Rules

1. Open the created bucket
2. Go to **Management → Lifecycle rules**
3. Click **Create lifecycle rule**

**Lifecycle Rule Configuration:**
- **Rule name:** `Archival-Policy`
- **Scope:** All objects

**Actions:**
- Transition to **S3 Standard-IA** after **30 days**
- Transition to **S3 Glacier** after **90 days**
- Permanently delete objects after **365 days**

4. Save the rule

---

### Step 3: S3 Security Configuration (Bucket Policy)

Apply the following bucket policy to allow controlled access from an IAM role.

**Bucket Policy JSON:**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAppAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:role/AppRole"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::my-company-data-2024/*"
    }
  ]
}
```

#### Apply Policy:

- **S3 → Bucket → Permissions → Bucket policy**

- **Paste JSON → Save**

## B. Amazon EBS Management

### Step 1: Create an EBS Volume

Navigate to EC2 → Elastic Block Store → Volumes

Click Create volume

Volume Configuration:

Volume type: gp3

Size: 100 GiB

IOPS: 3000

Throughput: 125 MB/s

Availability Zone: Same as EC2 instance

Encryption: Enabled

Click Create volume

Step 2: Attach Volume to EC2 Instance

Select the volume

Choose Actions → Attach volume

Attachment Details:

Instance: Select target EC2

Device name: /dev/sdf

Step 3: Mount EBS Volume on Linux EC2

```
sudo lsblk
sudo mkfs -t ext4 /dev/xvdf
sudo mkdir /data
sudo mount /dev/xvdf /data
```

Make Mount Persistent:

```
sudo blkid /dev/xvdf
sudo nano /etc/fstab
```

Add:

```
UUID=<your-uuid> /data ext4 defaults 0 2
```

C. VPC and Network Infrastructure
Step 1: Create VPC

VPC Configuration:

Name: Production-VPC

IPv4 CIDR: 10.0.0.0/16

Tenancy: Default

Tags: Environment = Production

Step 2: Create Subnets

Public Subnets:

Public-Subnet-1A | AZ: us-east-1a | CIDR: 10.0.1.0/24

Public-Subnet-1B | AZ: us-east-1b | CIDR: 10.0.2.0/24

Private Subnets:

Private-Subnet-1A | AZ: us-east-1a | CIDR: 10.0.11.0/24

Private-Subnet-1B | AZ: us-east-1b | CIDR: 10.0.12.0/24

Step 3: Internet Gateway

Create Internet Gateway

Name: Production-IGW

Attach to Production-VPC

Step 4: NAT Gateway

Create NAT Gateway

Name: Production-NAT

Subnet: Public-Subnet-1A

Elastic IP: Allocate new

Step 5: Route Tables

Public Route Table (Public-RT):

Route: 0.0.0.0/0 → Production-IGW

Associate: Public subnets

Private Route Table (Private-RT):

Route: 0.0.0.0/0 → Production-NAT

Associate: Private subnets

D. Security Groups
Web Server Security Group

Name: WebServer-SG

Inbound:

HTTP (80) → 0.0.0.0/0

HTTPS (443) → 0.0.0.0/0

SSH (22) → Your-IP/32

Outbound: All traffic

Database Security Group

Name: Database-SG

Inbound:

MySQL (3306) from WebServer-SG

PostgreSQL (5432) from WebServer-SG

Outbound: Default

E. Deploy Amazon RDS Database

Navigate to Amazon RDS → Create database

Configuration:

Engine: MySQL or PostgreSQL

Template: Production

DB identifier: production-db

Instance class: db.t3.medium

Storage: 100 GB gp3

VPC: Production-VPC

Subnet group: Private subnets

Public access: No

Security group: Database-SG

Backup retention: 7 days

Encryption: Enabled

Monitoring: Enhanced monitoring

F. Launch EC2 Web Server

Launch EC2 instance

Instance Configuration:

AMI: Amazon Linux 2

Instance type: t2.micro

Subnet: Public-Subnet-1A

Auto-assign public IP: Enabled

Security group: WebServer-SG

User Data Script:

```
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Web Server in Production VPC</h1>" > /var/www/html/index.html
```


G. Connectivity Testing
SSH to EC2

```
ssh -i keypair.pem ec2-user@<public-ip>
```

Test RDS Connectivity

```
mysql -h <rds-endpoint> -u admin -p
```

Validation

Internet access from public subnet ✔

Private subnet outbound access via NAT ✔

Web server reachable via browser ✔

Database accessible from EC2 ✔

Lab Outcome

✔ Secure storage lifecycle management
✔ Encrypted EBS volumes
✔ Production-ready VPC design
✔ Secure RDS deployment
✔ End-to-end application connectivity

---


#### END OF LAB

---

# 🛠️ Lab Troubleshooting 


#### Click on this link to see the bugs and their solutions.....

[Lab Troubleshooting ](https://github.com/awsrmmustansarjavaid/aws-research-study/blob/main/AWS-Labs-AWS-Labs-Guide/advanced_aws_enterprise_hands_on_lab_vpc_tgw_storage_automation_monitoring/Troubleshooting/Troubleshooting.md)

----

# 🎉 All New Tasks Successfully Integrated Into the Main Lab

## You now have:



### EC2 + EBS + User/Group Permission Management

- **✔ Public EC2 with attached EBS**

- **✔ Mounted and persistent file system**

- **✔ New Linux user & group**

- **✔ Group-level permission control**

- **✔ User added to the group**

- **✔ Full integration with the main AWS architecture**



