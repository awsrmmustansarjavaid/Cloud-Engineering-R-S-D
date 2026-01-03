# 🚀 AWS Lambda Automation Project

## EC2 Auto Start & Stop Using Amazon EventBridge (100% AWS Console Guide)

> **Trainer Note:** This guide is written assuming **ZERO gaps**. Every click, option, and verification step is included. Follow line‑by‑line using the **AWS Management Console** only.

---

## 📌 Lab Overview

In this hands‑on lab, you will build a **real‑world AWS automation** that automatically:

* ✅ **Starts EC2 instances at working hours**
* 🛑 **Stops EC2 instances after working hours**

### AWS Services Used

* IAM (Roles & Policies)
* EC2
* AWS Lambda (Python)
* Amazon EventBridge (Scheduler)
* CloudWatch Logs (for verification)

---

## 🎯 Architecture Flow (Simple Words)

EventBridge (Time Schedule)
→ Triggers Lambda Function
→ Lambda Calls EC2 API
→ EC2 Instance Starts or Stops

---

## ⚠️ Prerequisites

* AWS Free Tier Account
* Region selected (example: **us-east-1**) ⚠️ Use ONE region only
* One running or stopped EC2 instance

---

# 🟢 STEP 1: Create an EC2 Instance (Target Instance)

### 1. Open EC2 Console

* Go to **AWS Console → Services → EC2**

### 2. Launch Instance

* Click **Launch instance**

### 3. Configure Instance

* **Name:** `Auto-Start-Stop-EC2`
* **AMI:** Amazon Linux 2023 AMI
* **Instance type:** t2.micro (Free Tier)
* **Key pair:** Proceed without key pair
* **Network settings:** Default

### 4. Launch

* Click **Launch instance**

### 5. Copy Instance ID

* Example: `i-0abcd1234efgh5678`
* 🔒 Save it (you will use it in Lambda)

---

# 🟢 STEP 2: Create IAM Policy for EC2 Control

### 1. Open IAM Console

* Services → IAM → Policies

### 2. Create Policy

* Click **Create policy**
* Choose **JSON** tab

### 3. Paste Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:DescribeInstances"
      ],
      "Resource": "*"
    }
  ]
}
```

### 4. Next

* Click **Next**

### 5. Policy Name

* **Policy name:** `Lambda-EC2-Start-Stop-Policy`
* Click **Create policy**

---

# 🟢 STEP 3: Create IAM Role for Lambda

### 1. Go to Roles

* IAM → Roles → **Create role**

### 2. Trusted Entity

* Select **AWS service**
* Choose **Lambda**
* Click **Next**

### 3. Attach Permissions

* Search and select:

  * `Lambda-EC2-Start-Stop-Policy`
  * `AWSLambdaBasicExecutionRole`

### 4. Role Name

* **Role name:** `Lambda-EC2-AutoStartStop-Role`
* Click **Create role**

---

# 🟢 STEP 4: Create Lambda Function

### 1. Open Lambda Console

* Services → Lambda → **Create function**

### 2. Function Settings

* **Author from scratch**
* **Function name:** `EC2-Auto-Start-Stop`
* **Runtime:** Python 3.12
* **Execution role:** Use existing role
* **Role:** `Lambda-EC2-AutoStartStop-Role`

Click **Create function**

---

# 🟢 STEP 5: Add Lambda Code (VERY IMPORTANT)

### 1. Scroll to Code Section

* Replace existing code with below 👇

```python
import boto3

ec2 = boto3.client('ec2')

INSTANCE_IDS = ['i-0abcd1234efgh5678']  # REPLACE WITH YOUR INSTANCE ID

def lambda_handler(event, context):
    action = event.get('action')

    if action == 'start':
        ec2.start_instances(InstanceIds=INSTANCE_IDS)
        return 'EC2 Started'

    elif action == 'stop':
        ec2.stop_instances(InstanceIds=INSTANCE_IDS)
        return 'EC2 Stopped'

    else:
        return 'No valid action provided'
```

### 2. Click **Deploy**

---

# 🟢 STEP 6: Test Lambda Manually

### 1. Create Test Event (START)

* Click **Test** → **Configure test event**
* Event name: `StartEC2`
* JSON:

```json
{
  "action": "start"
}
```

* Click **Test**

✅ EC2 should move to **Running** state

---

### 2. Create Test Event (STOP)

```json
{
  "action": "stop"
}
```

✅ EC2 should move to **Stopped** state

---

# 🟢 STEP 7: Create EventBridge Rule (START Schedule)

### 1. Open EventBridge

* Services → EventBridge → Rules

### 2. Create Rule

* **Name:** `EC2-Start-Schedule`
* **Rule type:** Schedule

### 3. Schedule Pattern

* Choose **Cron**
* Example (9 AM Daily):

```
0 9 * * ? *
```

### 4. Target

* Target type: AWS service
* Select **Lambda function**
* Function: `EC2-Auto-Start-Stop`

### 5. Input

* Constant JSON:

```json
{
  "action": "start"
}
```

### 6. Create Rule

---

# 🟢 STEP 8: Create EventBridge Rule (STOP Schedule)

### Same Steps as Above

* **Rule name:** `EC2-Stop-Schedule`
* Cron (6 PM):

```
0 18 * * ? *
```

* Input JSON:

```json
{
  "action": "stop"
}
```

---

# 🟢 STEP 9: Grant Permission to EventBridge

⚠️ **VERY IMPORTANT – Often Missed**

* Go to Lambda → Function → **Configuration** → Permissions
* Ensure **EventBridge** has permission

If missing:

* EventBridge → Rule → Target → **Add permission automatically**

---

# 🟢 STEP 10: Verification & Testing

### 1. EC2 Console

* Observe instance auto start/stop

### 2. CloudWatch Logs

* Lambda → Monitor → Logs

### 3. EventBridge Monitoring

* Rule → Monitoring → Invocations = SUCCESS

---

# 🎯 Final Result

✅ EC2 starts automatically at office hours
✅ EC2 stops automatically after office hours
✅ Zero manual effort
✅ Cost optimized AWS usage

---

## 🔥 Real‑World Extensions

* Multiple EC2 instances (tag based)
* Different schedules per team
* Slack / Email notifications
* Weekend shutdown logic

---

## 🧠 Trainer Tip

> This project is **INTERVIEW‑READY**. It proves:

* AWS Automation
* Serverless mindset
* Cost optimization skills

---

✅ **LAB COMPLETE – 100% SUCCESSFUL**
