# 👨‍🏫 AWS Cloud Engineer Foundations

> **Author:** Charlie
> 
> **Level:** Absolute Beginners (Associate → Professional)

This document is written as if I am your **personal AWS cloud trainer**, and you are starting from **zero**. We will build **strong fundamentals** first, then immediately reinforce them with **hands-on labs**.

> 🎯 Goal: Make you comfortable with **Linux + Bash + AWS CLI + Python** so you can think and work like a real **AWS Cloud Engineer**.

---

## 📌 LEARNING PHILOSOPHY (IMPORTANT)

Cloud engineers do **three things daily**:
1. Use **Linux terminals**
2. Automate tasks with **CLI, Bash & Python**
3. Manage **AWS services programmatically**

So we learn in this order:

1️⃣ Linux basics → 2️⃣ Bash scripting → 3️⃣ AWS CLI → 4️⃣ Python for AWS


## 🧾 HandNotes 

## Python Language

[Python Language ](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/tree/main/CLoud-Engineering/Python)

## Linux

[Linux ](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/tree/main/CLoud-Engineering/Linux-research-study-drive/Linux)

## AWS CLI

[Linux ](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/tree/main/AWS-Cloud-Engineering/aws-research-study-drive/AWS%20CheatSheet/AWS_CLI)



Each chapter has:
- ✅ **Concept Notes (Why & What)**
- 🧪 **Hands-on AWS Lab (How)**

---

# 🔰 CHAPTER 1: LINUX FUNDAMENTALS FOR CLOUD ENGINEERS

## 1.1 What is Linux & Why AWS Uses It

Linux is:
- An **operating system**
- Lightweight, stable, secure
- Default OS for **EC2, containers, servers**

📌 In AWS:
- Amazon Linux
- Red Hat
- Ubuntu

> 💡 Cloud engineers do **90% work via Linux terminal**, not GUI.

---

## 1.2 Linux Directory Structure (VERY IMPORTANT)

| Directory | Purpose |
|--------|--------|
| / | Root of filesystem |
| /home | User home directories |
| /etc | Configuration files |
| /var | Logs & runtime data |
| /opt | Optional software (AWS agents) |
| /tmp | Temporary files |

---

## 1.3 Basic Linux Commands (First Chapter Commands)

### File & Directory Commands
```bash
pwd        # show current directory
ls         # list files
ls -l      # long listing
ls -a      # show hidden files
cd /path   # change directory
mkdir lab1 # create directory
rmdir lab1 # remove empty directory
```

### File Operations
```bash
touch file.txt
cp file.txt file2.txt
mv file.txt /tmp/
rm file.txt
```

### View Files
```bash
cat file.txt
less file.txt
head file.txt
tail file.txt
```

---

## 🧪 LAB 1: Linux Practice (EC2)

🎯 **Objective:** Get comfortable with Linux terminal

### Steps
1. Launch **Amazon Linux EC2** (t2.micro)
2. Connect via **SSH**
3. Run commands:

```bash
pwd
ls
mkdir aws-lab
cd aws-lab
touch cloud.txt
echo "Learning AWS Linux" > cloud.txt
cat cloud.txt
```

✅ **Outcome:** You understand navigation & files

---

# 🔰 CHAPTER 2: BASH SCRIPTING FUNDAMENTALS

## 2.1 What is Bash & Why Cloud Engineers Need It

Bash = **Automation language for Linux**

Used for:
- Server setup
- User data scripts
- Cron jobs
- Deployment scripts

> 💡 If Linux is the body, Bash is the **muscle**.

---

## 2.2 Bash Script Structure

```bash
#!/bin/bash
# This is a comment

echo "Hello AWS Cloud"
```

Make executable:
```bash
chmod +x script.sh
./script.sh
```

---

## 2.3 Variables & Input

```bash
NAME="AWS"
echo "Welcome $NAME"

read -p "Enter region: " REGION
echo "Region is $REGION"
```

---

## 2.4 Conditions & Loops

### If Condition
```bash
if [ $REGION == "us-east-1" ]; then
  echo "Free tier region"
else
  echo "Check pricing"
fi
```

### Loop
```bash
for i in 1 2 3
do
 echo "Instance $i"
done
```

---

## 🧪 LAB 2: Bash Automation Lab

🎯 **Objective:** Automate Linux tasks

### Task
Create script `setup.sh`

```bash
#!/bin/bash
mkdir aws-project
touch aws-project/info.txt
echo "AWS Automation Started" >> aws-project/info.txt
ls -l aws-project
```

Run:
```bash
chmod +x setup.sh
./setup.sh
```

✅ **Outcome:** You automated system tasks

---

# 🔰 CHAPTER 3: AWS CLI FUNDAMENTALS

## 3.1 What is AWS CLI

AWS CLI allows you to:
- Manage AWS **without console**
- Automate cloud operations
- Work faster & professionally

> 💡 Console = Learning | CLI = Real Job

---

## 3.2 Install & Configure AWS CLI

```bash
aws --version
aws configure
```

You provide:
- Access Key
- Secret Key
- Region
- Output format

📌 Stored in:
```bash
~/.aws/credentials
~/.aws/config
```

---

## 3.3 First AWS CLI Commands

### IAM
```bash
aws iam list-users
```

### EC2
```bash
aws ec2 describe-instances
```

### S3
```bash
aws s3 ls
```

---

## 🧪 LAB 3: AWS CLI Hands-on

🎯 **Objective:** Control AWS using terminal

### Tasks
```bash
aws s3 mb s3://my-cli-lab-bucket-123
aws s3 cp cloud.txt s3://my-cli-lab-bucket-123/
aws s3 ls s3://my-cli-lab-bucket-123
```

Cleanup:
```bash
aws s3 rb s3://my-cli-lab-bucket-123 --force
```

✅ **Outcome:** You managed AWS without GUI

---

# 🔰 CHAPTER 4: PYTHON FUNDAMENTALS FOR AWS

## 4.1 Why Python for Cloud Engineers

Python is used for:
- Automation
- AWS Lambda
- DevOps tools
- boto3 SDK

> 💡 Bash = system automation | Python = cloud logic

---

## 4.2 Python Basics (First Chapter)

```python
print("Hello AWS")
```

### Variables & Types
```python
region = "us-east-1"
instances = 3
print(region, instances)
```

### Conditions
```python
if region == "us-east-1":
    print("Primary region")
```

### Loop
```python
for i in range(3):
    print("EC2", i)
```

---

## 4.3 Python + AWS (boto3 Intro)

```python
import boto3

s3 = boto3.client('s3')
response = s3.list_buckets()
print(response)
```

---

## 🧪 LAB 4: Python AWS Automation

🎯 **Objective:** Use Python to talk to AWS

### Steps
1. Install SDK
```bash
pip3 install boto3
```

2. Create `list_s3.py`
```python
import boto3
s3 = boto3.client('s3')
buckets = s3.list_buckets()
for b in buckets['Buckets']:
    print(b['Name'])
```

Run:
```bash
python3 list_s3.py
```

✅ **Outcome:** Python + AWS automation achieved

---

# 🧭 WHAT YOU SHOULD DO NEXT (TRAINER ADVICE)

### Week 1:
- **Linux + Bash daily practice**

### Week 2:
- **AWS CLI + S3 + EC2**

### Week 3:
- **Python + boto3**

### Week 4:
- **Mini projects (backup, monitoring)**

---

### 🏆 The End

