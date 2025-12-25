# 🚀 AWS Route 53 Integrated Hands-On Lab

**Combine Route 53 with EC2, ALB, CloudFront, and S3**  
**Level:** Beginner → Intermediate  
**Trainer Mode:** Expert AWS Cloud Trainer

---

## 🎯 Lab Objective

In this lab, you will learn how **Amazon Route 53 works with core AWS services** to deliver a real-world web architecture.

By the end of this lab, you will:
- Route traffic using **Route 53**
- Host a website on **EC2**
- Distribute traffic using **Application Load Balancer (ALB)**
- Accelerate content using **CloudFront**
- Host static content on **S3**
- Use **Alias records** in Route 53

---

## 🧠 Lab Architecture (High-Level)

User Browser  
→ Route 53 (DNS & Routing)  
→ CloudFront (CDN)  
→ ALB (Load Balancer)  
→ EC2 Instances (Web Servers)  
→ S3 (Static Content)

---

## 📋 Prerequisites

- AWS Free Tier Account
- A registered domain name
- Basic knowledge of:
  - EC2
  - VPC
  - Security Groups
  - Route 53 basics

---

## 🧪 Lab 1: Launch EC2 Web Servers

### Step 1: Launch EC2 Instances
- AMI: Amazon Linux 2
- Instance type: t2.micro
- VPC: Default
- Subnets: Two different AZs

### Step 2: Install Web Server

```bash
sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
echo "EC2 Web Server $(hostname)" | sudo tee /var/www/html/index.html
```

### Step 3: Security Group
- Allow HTTP (80) from anywhere

---

## 🧪 Lab 2: Create Application Load Balancer (ALB)

### Steps
1. Go to EC2 → Load Balancers
2. Create **Application Load Balancer**
3. Internet-facing
4. Select 2 public subnets
5. Create target group (HTTP)
6. Register EC2 instances

### Test
- Access ALB DNS name in browser

---

## 🧪 Lab 3: Create S3 Static Website

### Step 1: Create Bucket
- Name: `my-static-site-<unique>`
- Disable Block Public Access

### Step 2: Enable Static Website Hosting
- Index document: `index.html`

### Step 3: Upload Static Content

```html
<h1>Welcome from S3 Static Website</h1>
```

---

## 🧪 Lab 4: Create CloudFront Distribution

### Origin Options
- ALB (dynamic content)
- S3 bucket (static content)

### Steps
1. Open CloudFront
2. Create distribution
3. Set origins:
   - ALB DNS
   - S3 bucket endpoint
4. Default behavior → ALB

---

## 🧪 Lab 5: Create Route 53 Hosted Zone

### Steps
1. Open Route 53
2. Create **Public Hosted Zone**
3. Domain: `example.com`

---

## 🧪 Lab 6: Route 53 Alias to CloudFront

### Create Alias Record

- Record name: `www`
- Record type: A
- Alias: Yes
- Target: CloudFront distribution
- Routing policy: Simple

📌 *This routes traffic globally via CloudFront*

---

## 🧪 Lab 7: Route 53 Alias to ALB (Optional)

### Create Another Record

- Record name: `app`
- Record type: A
- Alias: Yes
- Target: ALB

---

## 🧪 Lab 8: DNS Testing

### Browser Test

```text
http://www.example.com
```

### CLI Test

```bash
nslookup www.example.com
dig www.example.com
```

---

## 🧪 Lab 9: Understand Traffic Flow

### DNS Resolution
- Route 53 returns CloudFront IP

### Request Handling
- CloudFront caches static content
- Dynamic requests forwarded to ALB
- ALB distributes to EC2

---

## 🔐 Security & Best Practices

- Use Alias instead of CNAME
- Use HTTPS (ACM certificate)
- Enable health checks
- Restrict S3 access via OAI/OAC

---

## 💰 Cost Awareness

- Route 53 hosted zone
- CloudFront requests
- ALB hours

⚠️ Clean up after lab

---

## 🧹 Lab 10: Clean-Up Resources

1. Delete Route 53 records & hosted zone
2. Delete CloudFront distribution
3. Delete ALB & target group
4. Terminate EC2 instances
5. Delete S3 bucket

---

## 🎓 What You Learned

- How Route 53 integrates with AWS services
- Real-world DNS routing
- Global content delivery
- High availability architecture

---

## 🚀 Next Advanced Labs

- Route 53 Health Check & Failover
- Multi-region architecture
- Blue/Green deployment

---

## ✅ Lab Completed

You have successfully completed a **real-world AWS Route 53 integrated lab** 🎉

---



## 🔥 What this lab covers (end-to-end architecture)

#### This single lab combines Route 53 with all major AWS services exactly the way it’s used in production:

### ✅ Services Integrated

- Route 53 – DNS & traffic routing

- EC2 – Web servers

- ALB (Application Load Balancer) – Traffic distribution

- CloudFront – Global CDN

- S3 – Static website hosting

### ✅ What you practice step-by-step

- Launch EC2 web servers (multi-AZ)

- Create & test an ALB

- Host static content on S3

- Create CloudFront distribution (ALB + S3)

- Create Route 53 public hosted zone

#### Use Alias records:

- Route 53 → CloudFront

- Route 53 → ALB

- Test DNS using browser + CLI

- Understand real traffic flow

- Clean up safely (cost-aware)

**This is interview-ready + production-style learning, not just theory.**

---

**End of Lab Guide**