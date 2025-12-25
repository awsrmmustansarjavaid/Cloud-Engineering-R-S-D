# 🧪 AWS Route 53 — Basic Hands-On Lab (Beginner Level)

> **Author:** Charlie
> 
> **Level:** Absolute Beginners (Associate → Professional)
> 
> **Goal:** Understand how Route 53 works by doing

## 📖 AWS Route 53 Conceptual Theory

[AWS Route 53 ](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/main/AWS-Cloud-Engineering/aws-research-study-drive/AWS-Course/aws_route_53_complete_guide_beginner_to_advanced.md)

---

## 🎯 Lab Objective

By the end of this lab, you will:
- Understand how DNS works in AWS
- Create a **Public Hosted Zone**
- Create basic **DNS records**
- Route a domain to an AWS resource
- Verify DNS resolution

---

## 🧠 Lab Prerequisites

Before starting, you should have:
- AWS Free Tier account
- Basic understanding of:
  - EC2
  - IP addresses
  - Domain names
- A **test domain name** (recommended)
  - You can buy from Route 53 or use any external registrar

⚠️ *If you don’t have a domain, you can still practice hosted zones conceptually.*

---

## 🧩 Lab Architecture (Concept)

User Browser → Route 53 DNS → EC2 Public IP

## 🎓 AWS Architecture Diagram

![AWS Route 53 — Basic Hands-On Lab (Beginner Level)](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/main/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Visual-Architecture-Diagram/aws_route_53_basic_hands_on_lab_beginner.png?raw=true)

---

## 🔬 Lab 1: Understand DNS Resolution Flow

### What Happens Internally
1. User enters domain name
2. DNS resolver queries Route 53
3. Route 53 returns IP address
4. Browser connects to EC2

📌 *Route 53 acts as the authoritative DNS server*

---

## 🧪 Lab 2: Create a Public Hosted Zone

### Step 1: Open Route 53 Console
1. Login to AWS Console
2. Search **Route 53**
3. Click **Hosted Zones**

### Step 2: Create Hosted Zone
1. Click **Create Hosted Zone**
2. Domain name:
   ```
   example.com
   ```
3. Type:
   - Public Hosted Zone
4. Comment:
   - Basic Route 53 practice
5. Click **Create Hosted Zone**

### Result
- NS and SOA records created automatically

---

## 🧪 Lab 3: Understand Default DNS Records

### NS Record
- Shows Route 53 name servers
- Must be added at domain registrar

### SOA Record
- Contains zone authority info

📌 *These records are mandatory for DNS operation*

---

## 🧪 Lab 4: Create an A Record (IPv4)

### Goal
Map domain to server IP

### Steps
1. Open your Hosted Zone
2. Click **Create Record**
3. Record name:
   ```
   www
   ```
4. Record type:
   - A
5. Value:
   ```
   <EC2-PUBLIC-IP>
   ```
6. TTL:
   - 300 seconds
7. Routing policy:
   - Simple
8. Click **Create records**

---

## 🧪 Lab 5: Test DNS Resolution

### Method 1: Using Browser
```
http://www.example.com
```

### Method 2: Using Command Line

#### Windows
```
nslookup www.example.com
```

#### Linux / macOS
```
dig www.example.com
```

### Expected Result
- Domain resolves to EC2 IP

---

## 🧪 Lab 6: Create a CNAME Record

### Goal
Point one domain to another

### Steps
1. Create record
2. Record name:
   ```
   blog
   ```
3. Record type:
   - CNAME
4. Value:
   ```
   www.example.com
   ```
5. TTL: 300
6. Save record

📌 *CNAME cannot be used at root domain*

---

## 🧪 Lab 7: TTL Experiment

### Goal
Understand DNS caching

1. Change A record IP
2. Observe delay in update
3. Reduce TTL to 60
4. Observe faster propagation

📌 *Lower TTL = faster changes, more DNS queries*

---

## 🧪 Lab 8: Alias Record (Concept Only)

### Why Alias?
- AWS-specific
- Free
- Auto-updates IP

### Alias Targets
- ALB
- CloudFront
- S3 Website

📌 *Alias replaces CNAME for AWS resources*

---

## 🧪 Lab 9: Clean-Up (Important)

### Steps
1. Delete DNS records
2. Delete hosted zone
3. Release unused resources

⚠️ *Avoid unnecessary charges*

---

## 🧠 Key Learnings

- What is Hosted Zone
- How DNS records work
- How Route 53 resolves queries
- TTL behavior

---

## 🎓 Beginner Interview Questions

- What is Route 53?
- What is a hosted zone?
- Difference between A and CNAME?
- What is TTL?

---

## 🚀 Next-Level Labs (Recommended)

- Route 53 + EC2
- Route 53 + ALB (Alias)
- Health checks & failover
- Private Hosted Zone

---

## ✅ Lab Completed

You have successfully completed your **first AWS Route 53 hands-on lab** 🎉

📌 *Practice this lab 2–3 times to gain confidence*

---

**End of Lab Guide**

