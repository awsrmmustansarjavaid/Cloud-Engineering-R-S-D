# AWS CloudWatch Lab Complete Guide 

> **Author:** Charlie
> 
> **Level:** Advanced (Associate → Professional)

---

# 📙 Lab Name: Advanced AWS Enterprise Hands-On Lab

###### Purpose: End‑to‑end enterprise AWS hands‑on lab covering networking, storage, automation, monitoring, and Linux administration.

###### click on this link for this AWS Hand-on Lab....  

[Advanced AWS Enterprise Hands-On Lab URL](https://github.com/awsrmmustansarjavaid/aws-research-study/blob/main/AWS-Labs-AWS-Labs-Guide/advanced_aws_enterprise_hands_on_lab_vpc_tgw_storage_automation_monitoring/advanced_aws_enterprise_hands_on_lab_vpc_tgw_storage_automation_monitoring.md)

## Section 1 - AWS Cloudwatch & EC2 

### 1.1 Open IAM Console

- **Go to AWS Console → IAM Role**

- **Service → EC2**

- **IAM Policies**

Attach these AWS-managed policies:

1️⃣ CloudWatch Monitoring

```
CloudWatchAgentServerPolicy
```

2️⃣ Systems Manager (Windows control, logs, patching)

```
AmazonSSMManagedInstanceCore
```

3️⃣ S3 Access (for logs, backups, app data)

```
AmazonS3ReadOnlyAccess
```

```
AmazonS3FullAccess
```

4️⃣ EBS Snapshots & Volumes

```
AmazonEC2ReadOnlyAccess
```

```
AmazonEC2FullAccess
```

5️⃣ EventBridge (Read EC2 Events)

```
AmazonEventBridgeReadOnlyAccess
```

6️⃣ EFS (If EC2/Lambda accesses EFS)

```
AmazonElasticFileSystemClientReadWriteAccess
```

7️⃣ RDS (IAM auth or monitoring)

```
AmazonRDSReadOnlyAccess
```

- **Name:**

```
AdvancedLab-EC2-Role
```

- **Description:**

```
Unified IAM role for EC2 instance to access CloudWatch, SSM, S3, EBS, RDS, EFS, and monitoring services
```

- **Click Create role**

### 1.2 Attach Role to EC2

- **Go to EC2 → Instances**

- **Select your EC2 → Actions → Security → Modify IAM role**

- **Select:**

```
AdvancedLab-EC2-Role
```

- **Save**

**⏱ Takes 10–30 seconds to apply**


### 1.3 Verify IAM Role on EC2 (From Inside the Instance)

###### This confirms the role is attached and usable.

#### Method A — Instance Metadata (On Linux EC2):

##### 🔑 Retrieving AWS EC2 Instance Metadata

```
curl http://169.254.169.254/latest/meta-data/iam/info
```

**🎙️ Explanation:**

>This command uses the curl utility to make a request to a special local IP address, 169.254.169.254, which is the fixed address for the Instance Metadata Service (IMDS) within an EC2 instance. The specific path /latest/meta-data/iam/info retrieves a JSON document containing details about the IAM Role attached to the instance, including the ARN (Amazon Resource Name) and the name of the role. This information is typically used by applications to automatically assume the role and gain necessary permissions for interacting with other AWS services (like S3, DynamoDB, etc.).

##### Expected output:

```
{
  "Code" : "Success",
  "InstanceProfileArn" : "arn:aws:iam::123456789012:instance-profile/AdvancedLab-EC2-Role",
  "InstanceProfileId" : "AIPAXXXXX"
}
```

**✅ This means the role is attached and active**

##### Method B — Test AWS API Access (BEST PRACTICE)

##### 🔑 AWS CLI: Getting the Caller's Identity

```
aws sts get-caller-identity
```

**🎙️ Explanation:**

>This command uses the curl utility to make a request to a special local IP address, 169.254.169.254, which is the fixed address for the Instance Metadata Service (IMDS) within an EC2 instance. The specific path /latest/meta-data/iam/info retrieves a JSON document containing details about the IAM Role attached to the instance, including the ARN (Amazon Resource Name) and the name of the role. This information is typically used by applications to automatically assume the role and gain necessary permissions for interacting with other AWS services (like S3, DynamoDB, etc.).

##### Expected output:

```
{
  "Arn": "arn:aws:sts::123456789012:assumed-role/AdvancedLab-EC2-Role/i-0abcd1234"
}
```

### 1.4 Download and install the CloudWatch agent package (Amazon Linux 2023)

```
sudo dnf install -y amazon-cloudwatch-agent
```

**🎙️ Explanation:**

>This command uses the Dandified New Frontend (dnf), a modern package manager for RPM-based Linux distributions, to install the software package named amazon-cloudwatch-agent. The sudo prefix runs the command with administrative privileges, which is required for installation. The -y flag tells DNF to automatically answer "yes" to any confirmation prompts, allowing for non-interactive installation.


#### 1️⃣ Verify CloudWatch Agent is Installed

##### Check service status:

```
sudo systemctl status amazon-cloudwatch-agent
```

**🎙️ Explanation:**

>This command utilizes the systemctl utility, which is the main control interface for the systemd service manager (used in modern Linux distributions like Amazon Linux, Ubuntu, and CentOS).

##### Expected output:

```
active (running)
```

##### Check binary exists:

```
ls /opt/aws/amazon-cloudwatch-agent/bin/
```

**🎙️ Explanation:**

>This command is used for Navigating the Linux File System and is essential for server administration tasks, especially when dealing with monitoring agents like the AWS CloudWatch Agent.

#### 2️⃣ Verify CloudWatch Agent Configuration Loaded

```
sudo cat /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
```

**🎙️ Explanation:**

>This command is a standard Linux utility command used for viewing the content of a file, specifically the configuration file for the Amazon CloudWatch Agent.

**✔ File exists**

**✔ Logs + metrics configured**

Verify Agent is ACTUALLY Sending Data
Check agent logs:


#### 3️⃣ Verify Agent is ACTUALLY Sending Data

##### Check agent logs:

```
sudo tail -n 50 /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
```

##### Look for:

```
Successfully published metrics
Successfully published log events
```

**❌ If you see AccessDenied → IAM issue**

**❌ If region mismatch → config issue**


#### 4️⃣ Verify CloudWatch Logs (From AWS Console)

- **Go to: CloudWatch → Logs → Log groups**

##### You should see:

```
/ec2/advancedlab/system
```

##### Inside:

**✔ Log streams named after instance ID**

**✔ Logs updating every few seconds**

#### 5️⃣ Verify CloudWatch Metrics (NO AGENT REQUIRED)

Go to:
CloudWatch → Metrics → EC2

Check these metrics:

StatusCheckFailed

StatusCheckFailed_System

StatusCheckFailed_Instance

These confirm hardware + instance health


#### 6️⃣ Verify CloudWatch Agent Metrics (Agent-Based)

- **Go to: CloudWatch → Metrics → CWAgent**

- **Metrics:**

```
✔ mem_used_percent

✔ disk_used_percent

✔ cpu_usage_idle

```

#### 7️⃣ Verify SSM Works (ROLE VALIDATION)

```
sudo systemctl status amazon-ssm-agent
```

##### Then: 

- **EC2 → Connect → Session Manager**

##### If it opens:

✅ IAM role + networking + agent are correct

#### 🔎 HOW YOU KNOW EVERYTHING IS WORKING

```
| Check        | Result       |
| ------------ | ------------ |
| Metadata IAM | Role visible |
| STS identity | Role assumed |
| CW agent     | Running      |
| Agent logs   | Publishing   |
| Log group    | Exists       |
| Metrics      | Updating     |
| SSM          | Works        |
```

**✔ This is 100% verification**

#### 🧠 Tip & Trick

**If any one of these fails:**

**✔ Fix IAM first**

**✔ Then agent**

**Then CloudWatch config**

### 1.5 🎯 CLOUDWATCH ALARMS PRACTICE

###### You will create two real production alarms:

**1️⃣ EC2 CPU Utilization > 70%**

**2️⃣ RDS Free Storage Space < 20%**


### 🟢 PART 1 — EC2 CPU UTILIZATION ALARM (>70%)

#### Step 1️⃣ Open Alarm Wizard

- **Go to: CloudWatch → Alarms → Create alarm**

#### Step 2️⃣ Select Metric

- **Go to : Select metric → EC2 → Per-Instance Metrics → CPUUtilization**

- **Select your EC2 instance ID**

#### Step 3️⃣ Define Condition

```
| Setting        | Value     |
| -------------- | --------- |
| Statistic      | Average   |
| Period         | 5 minutes |
| Threshold type | Static    |
| Condition      | Greater   |
| Threshold      | 70        |
```

##### Meaning:

- **CPU average > 70% for 5 minutes**

#### Step 4️⃣ Configure Notification

##### Create SNS topic:

```
Topic name: ec2-cpu-alert
Email: your-email@example.com
```

**⚠️ Confirm email (very important)**


#### Step 5️⃣ Name & Create Alarm

```
Alarm name: EC2-CPU-High-70
Description: Alert when EC2 CPU exceeds 70%
```

- **Click Create alarm**


#### Step 6️⃣ TEST EC2 CPU Alarm (VERY IMPORTANT)

##### Login to EC2 and run:

```
sudo yum install -y stress
stress --cpu 2 --timeout 300
```

##### After ~5 minutes:

- **Alarm state → ALARM**

**✔ Email received 📧**

**✔ Stop test automatically after 5 minutes.**


### 🟢 PART 2 — RDS FREE STORAGE ALARM (<20%)

#### Step 1️⃣ Calculate 20% Storage (Trainer Tip)

##### Example:


- **RDS allocated storage = 20 GB**

- **20% = 4 GB**

**CloudWatch metric uses BYTES, not GB:**

```
4 GB = 4 × 1024 × 1024 × 1024 = 4294967296 bytes
```

**📌 Write this number — you need it.**

#### Step 2️⃣ Select RDS Metric

- **Go to:**
    * **CloudWatch → Alarms → Create alarm → Select metric → RDS → Per-DBInstance Metrics → FreeStorageSpace**

- **Select your DB instance**

#### Step 3️⃣ Define Condition


```
| Setting        | Value      |
| -------------- | ---------- |
| Statistic      | Average    |
| Period         | 5 minutes  |
| Threshold type | Static     |
| Condition      | Less       |
| Threshold      | 4294967296 |
```

##### Meaning:

- **Free storage < 20%**

#### Step 4️⃣ Configure Notification

##### Use same or new SNS topic:

```
Topic: rds-storage-alert
```

#### Step 5️⃣ Name & Create Alarm

```
Alarm name: RDS-Free-Storage-Low-20Percent
Description: Alert when RDS free storage drops below 20%
```

#### Step 6️⃣ TEST RDS ALARM (SAFE WAY)

**1️⃣ Option 1 — Fill DB (Not Recommended)**

**2️⃣ Option 2 — Temporary Threshold Change (BEST PRACTICE)**

##### Edit alarm threshold:

```
Set threshold = current free storage + small buffer
```

**✔ Alarm should go to ALARM quickly.**

**✔ Revert threshold after test.**

#### 🧠 WHAT EACH ALARM TEACHES YOU

```
| Alarm       | What You Learn          |
| ----------- | ----------------------- |
| EC2 CPU     | Performance bottlenecks |
| RDS Storage | Data growth risk        |
| SNS         | Incident alerting       |
| Thresholds  | Capacity planning       |
```

#### 🔥 COMMON MISTAKES (AVOID THESE)

**❌ Using MemoryUtilization (not default)**

**❌ Forgetting unit conversion (GB → bytes)**

**❌ Using 1-minute period for free tier**

**❌ Forgetting email confirmation**

**❌ Alarm OK but no action attached**


---

## Section 2 - Auto Scaling Action to EC2 CPU Alarm

### 2.1 -  Add Auto Scaling Action to EC2 CPU Alarm

**🎯 Goal:  When CPU > 70%, automatically scale out (add EC2).**

##### 🧠 IMPORTANT CONCEPT FIRST

> **Auto Scaling only works with an Auto Scaling Group (ASG)
You cannot attach scaling actions to a single standalone EC2.**

###### 💡 So the flow is:

```
CPU Alarm → Auto Scaling Policy → Auto Scaling Group → New EC2
```

#### 1️⃣ Create Auto Scaling Group (If Not Exists)

- **Go to EC2 → Auto Scaling Groups**

- **Create:**

```
Launch template (use your EC2 AMI)

VPC & subnets

Desired = 1

Min = 1

Max = 3
```

#### 2️⃣ Create Scaling Policy

- **Inside ASG → Automatic scaling → Create policy**

```
Policy type: Simple scaling
Scaling action: Add 1 instance
Cooldown: 300 seconds
```
- **Save policy.**

#### 3️⃣ Attach CPU Alarm to ASG

- **Go to CloudWatch → Alarms → EC2-CPU-High-70**

- **Edit alarm → Actions**

- **Under In alarm:**

```
Select Auto Scaling action
Choose your ASG scaling policy
```

- **Save.**

#### 4️⃣ — TEST

- **Stress EC2 again:**

```
stress --cpu 2 --timeout 600
```

#### 5️⃣ Result:

- **Alarm → ALARM**

**ASG launches new EC2 🎉**

---

## Section 3 - Add Lambda Action to RDS Storage Alarm

### 3.1 -  Add Lambda Action to RDS Storage Alarm
**🎯 Goal: When RDS storage < 20%, run Lambda automatically
(e.g., log warning, notify, take snapshot)**

#### 1️⃣ — Create Lambda Function

```
Name: RDSStorageAlarmHandler
Runtime: Python 3.10
Role: AWSLambdaBasicExecutionRole + AmazonRDSReadOnlyAccess
```

#### 2️⃣ — Lambda Code (Simple & Clear)

```
def lambda_handler(event, context):
    print("RDS Storage Alarm Triggered")
    print(event)
```

- **Deploy.**

#### 3️⃣ — Add Lambda as Alarm Action

- **Go to: CloudWatch → Alarms → RDS-Free-Storage-Low-20Percent**

- **Edit alarm → Actions**

- **Under In alarm:**

```
Select Lambda function
Choose RDSStorageAlarmHandler
```

- **Save.**

#### 4️⃣ — TEST

- **Temporarily increase threshold so alarm triggers.**

- **Check:**

```
 CloudWatch → Logs → /aws/lambda/RDSStorageAlarmHandler
```

**Logs appear = SUCCESS ✅**

---

## Section 4 - Create Composite Alarm

### 4.1 -  Create Composite Alarm

**🎯 Goal: Trigger alert only if multiple alarms fail together**

##### Example:

```
CPU High AND RDS Storage Low
```

### 🧠 WHY Composite Alarms MATTER

- **Reduce false alarms**

- **Combine application health signals**

- **Used heavily in enterprise monitoring**

#### 1️⃣ — Create Composite Alarm

- **Go to: CloudWatch → Alarms → Create alarm → Composite alarm**

#### 2️⃣ — Define Rule (IMPORTANT)

- **Select:**

```
EC2-CPU-High-70

RDS-Free-Storage-Low-20Percent
```

- **Rule:**

```
ALARM(EC2-CPU-High-70) AND ALARM(RDS-Free-Storage-Low-20Percent)
```

#### 3️⃣ — Configure Notification

- **Attach SNS topic:**

```
critical-app-alert
```

#### 4️⃣ — Name Alarm

```
Composite-App-Critical-Alarm
```

----

## Section 5 - Visualize Alarms in CloudWatch Dashboard

### 5.1 -  Visualize Alarms in CloudWatch Dashboard

**🎯 Goal: Single dashboard to see health instantly.**

#### 1️⃣ — Create Dashboard

- **Go to: CloudWatch → Dashboards → Create dashboard**

- **Name:**

```
AdvancedLab-Health-Dashboard
```

#### 2️⃣ — Add Alarm Widgets

- **Choose:**

```
Widget type → Alarm
```

- **Add:**

```
EC2-CPU-High-70

RDS-Free-Storage-Low-20Percent

Composite-App-Critical-Alarm
```


#### 3️⃣ — Add Metrics (Optional but Pro)

- **Add widgets:**

```
EC2 CPUUtilization

RDS FreeStorageSpace

EC2 StatusCheckFailed
```


#### 4️⃣ — Save Dashboard

- **Now you have real NOC-style monitoring**

---

## Section 6 -FINAL MENTAL MODEL (IMPORTANT)

### 6.1 -  FINAL MENTAL MODEL (IMPORTANT)

- **Go to: Metric → Alarm → Action → Automation**

- **Actions can be:**

```
SNS

Auto Scaling

Lambda

Composite logic
```




---

## 🎓 Research & Study

#### 🎓 INTERVIEW-LEVEL ANSWER

> “IAM role attachment and CloudWatch Agent functionality can be verified directly from EC2 using instance metadata, STS calls, agent status, and CloudWatch metrics/logs.”

> **Why CPU alarm works without agent?** “CPUUtilization is a hypervisor-level metric published by EC2 automatically.”

> **Why RDS storage alarm uses bytes?** “CloudWatch stores metrics in base units for consistency and precision.”

> “CloudWatch alarms can trigger Auto Scaling policies to automatically scale EC2 capacity based on metrics.”

> “CloudWatch alarms can invoke Lambda for automated remediation or notifications.”

> “Composite alarms combine multiple CloudWatch alarms to represent application-level health.”

> “CloudWatch dashboards provide real-time visualization of alarms and metrics for operational awareness.”









