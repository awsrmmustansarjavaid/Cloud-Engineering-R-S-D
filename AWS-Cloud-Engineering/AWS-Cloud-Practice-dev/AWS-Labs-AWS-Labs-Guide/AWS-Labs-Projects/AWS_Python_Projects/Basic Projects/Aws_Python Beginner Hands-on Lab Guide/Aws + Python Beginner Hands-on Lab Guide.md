# 🎓 AWS Cloud Computing + Python (Beginner Hands-On Lab Guide)

> **Trainer Mode:** AWS Cloud Architect & Trainer
> **Student Level:** Absolute Beginner (AWS + Python)

---

## 📌 Purpose of This Lab

This lab is designed to help you:

* Understand **basic Python concepts**
* Perform **real AWS tasks using Python**
* Learn how Python automates AWS services

You will learn **slowly, practically, and clearly**.

---

## 🧰 Prerequisites (One-Time Setup)

### 1️⃣ AWS Account

* Create an AWS Free Tier account
* Use **Free Tier services only**

### 2️⃣ Required Tools

Install on your **local machine or Linux EC2**:

```bash
python3 --version
pip3 --version
pip3 install boto3 awscli
```

### 3️⃣ Configure AWS CLI

```bash
aws configure
```

Provide:

* AWS Access Key
* AWS Secret Key
* Region: `us-east-1`
* Output format: `json`

---

# 🧪 LAB 0 — Python Basics (No AWS)

## Task 0.1 — Hello Python

```python
print("Hello AWS World")
```

**Explanation:**

* `print()` displays output
* Used to show program results

---

## Task 0.2 — Variables

```python
name = "Charlie"
cloud = "AWS"

print("My name is", name)
print("I am learning", cloud)
```

**Explanation:**

* Variables store data
* Used everywhere in Python & AWS automation

---

## Task 0.3 — Python List

```python
services = ["EC2", "S3", "IAM"]
print(services)
print(services[0])
```

**Explanation:**

* Lists store multiple values
* AWS responses often return lists

---

# ☁️ LAB 1 — Connect Python to AWS (S3)

## Task 1.1 — AWS Connection Test

```python
import boto3

s3 = boto3.client("s3")
print("Connected to AWS S3")
```

**Explanation:**

* `boto3` is AWS SDK for Python
* `client("s3")` connects to S3

---

## Task 1.2 — List S3 Buckets

```python
import boto3

s3 = boto3.client("s3")
response = s3.list_buckets()

for bucket in response["Buckets"]:
    print(bucket["Name"])
```

**Concepts Learned:**

* Python `for` loop
* AWS resource listing

---

# ☁️ LAB 2 — Create S3 Bucket Using Python

```python
import boto3

s3 = boto3.client("s3")

bucket_name = "my-first-python-bucket-12345"

s3.create_bucket(
    Bucket=bucket_name,
    CreateBucketConfiguration={"LocationConstraint": "us-east-1"}
)

print("Bucket created:", bucket_name)
```

**AWS Concept:** Resource creation

---

# ☁️ LAB 3 — Upload File to S3

## Step 1 — Create File

```bash
echo "Hello from Python AWS Lab" > demo.txt
```

## Step 2 — Upload Using Python

```python
import boto3

s3 = boto3.client("s3")

s3.upload_file(
    "demo.txt",
    "my-first-python-bucket-12345",
    "demo.txt"
)

print("File uploaded to S3")
```

---

# ☁️ LAB 4 — EC2 Information Using Python

```python
import boto3

ec2 = boto3.client("ec2")

instances = ec2.describe_instances()

for reservation in instances["Reservations"]:
    for instance in reservation["Instances"]:
        print("Instance ID:", instance["InstanceId"])
        print("State:", instance["State"]["Name"])
```

**Concepts Learned:**

* Nested loops
* EC2 resource reading

---

# 🔐 LAB 5 — IAM Users List

```python
import boto3

iam = boto3.client("iam")

users = iam.list_users()

for user in users["Users"]:
    print(user["UserName"])
```

**AWS Concept:** Identity & Access Management

---

# 🧠 Skills You Gained

| Area       | Skills                  |
| ---------- | ----------------------- |
| Python     | Variables, loops, lists |
| AWS        | S3, EC2, IAM            |
| Automation | Cloud scripting         |

---

# 🚀 Next Learning Steps

* Python functions & error handling
* Create EC2 with Python
* AWS Lambda with Python
* Mini Project: Python-based S3 Backup Tool

---

> 🎯 **You are now officially started on AWS + Python Cloud Automation Path**
