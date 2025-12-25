# AWS Lab Guide: Café Website High Availability & Auto-Scaling

**Lab Objective:**  
Rebuild a single-AZ EC2-based café website into a **highly available, resilient, and auto-scaling architecture** using AWS services.

---

## 📝 Prerequisites

1. AWS Account with Administrator privileges.
2. Basic understanding of:
   - VPC, Subnets, Route Tables
   - EC2, AMI, Security Groups
   - Auto Scaling Groups (ASG) & Launch Templates
   - Elastic Load Balancer (ALB)
   - NAT Gateways
3. Installed tools (optional but recommended):
   - AWS CLI
   - SSH client (e.g., PuTTY or Terminal)
   - Web browser

---

## 1️⃣ Step 1: Plan Your Architecture

Target Architecture:

- **VPC** with two public and two private subnets (Multi-AZ)
- **NAT Gateways** in each AZ
- **Internet Gateway** attached to the VPC
- **Route Tables** configured for public/private subnets
- **Application Load Balancer** for traffic distribution
- **Auto Scaling Group** with Launch Template
- **EC2 Instances** in private subnets
- **Security Groups** for ALB and EC2

---

## 2️⃣ Step 2: Create VPC

1. Go to **VPC Console → Your VPCs → Create VPC**
   - Name: `CafeVPC`
   - IPv4 CIDR: `10.0.0.0/16`
   - Tenancy: Default
2. Click **Create VPC**

---

## 3️⃣ Step 3: Create Subnets (Multi-AZ)

- **Public Subnets:**
  - `10.0.1.0/24` → AZ-1
  - `10.0.2.0/24` → AZ-2
- **Private Subnets:**
  - `10.0.11.0/24` → AZ-1
  - `10.0.12.0/24` → AZ-2

> Go to **VPC → Subnets → Create Subnet**, assign AZs accordingly.

---

## 4️⃣ Step 4: Create Internet Gateway (IGW)

1. Go to **VPC → Internet Gateways → Create Internet Gateway**
2. Name: `CafeIGW`
3. Attach to `CafeVPC`

---

## 5️⃣ Step 5: Create NAT Gateways (High Availability)

1. Go to **VPC → NAT Gateways → Create NAT Gateway**
2. For AZ-1:  
   - Subnet: Public Subnet AZ-1  
   - Allocate Elastic IP  
3. For AZ-2:  
   - Subnet: Public Subnet AZ-2  
   - Allocate Elastic IP  

> NAT Gateways allow private instances to access the Internet securely.

---

## 6️⃣ Step 6: Configure Route Tables

- **Public Route Table:**  
  - Destination: `0.0.0.0/0` → Target: `Internet Gateway`  
  - Associate with public subnets only
- **Private Route Table:**  
  - Destination: `0.0.0.0/0` → Target: respective NAT Gateway  
  - Associate with private subnets only

---

## 7️⃣ Step 7: Create Security Groups

- **ALB Security Group:**  
  - Inbound: HTTP `80`, HTTPS `443` from `0.0.0.0/0`  
  - Outbound: All traffic
- **EC2 Security Group:**  
  - Inbound: HTTP `80` from ALB SG  
  - SSH `22` from your IP (for testing)  
  - Outbound: All traffic

---

## 8️⃣ Step 8: Create Launch Template

1. Go to **EC2 → Launch Templates → Create Launch Template**
2. Name: `CafeLaunchTemplate`
3. AMI: Latest Amazon Linux 2
4. Instance Type: `t3.micro` (or suitable)
5. Key Pair: Your Key
6. Security Group: EC2 SG
7. User Data (optional):

```bash
   #!/bin/bash
   yum update -y
   yum install -y httpd
   systemctl enable httpd
   systemctl start httpd
   echo "<h1>Welcome to Café Website</h1>" > /var/www/html/index.html
```

8. Save Launch Template


## 9️⃣ Step 9: Create Auto Scaling Group (ASG)

1. Go to EC2 → Auto Scaling → Auto Scaling Groups → Create

2. Choose Launch Template: CafeLaunchTemplate

3. Name: CafeASG

4. Network: VPC → Select Private Subnets (Multi-AZ)

5. Load Balancer: Attach ALB (we will create next)

6. Scaling Policies:

    - Minimum: 2 instances

    - Desired: 2 instances

    - Maximum: 4 instances

7. Review & Create

## 🔟 Step 10: Create Application Load Balancer (ALB)

1. Go to EC2 → Load Balancers → Create Load Balancer → Application Load Balancer

2. Name: CafeALB

3. Scheme: Internet-facing

4. Listeners: HTTP 80

5. VPC: CafeVPC

6. Availability Zones: Include both public subnets

7. Security Group: ALB SG

8. Target Group:

    - Name: CafeTG

    - Target Type: Instance

    - Protocol: HTTP

    - Port: 80

    - Health Check Path: /

9. Register Auto Scaling instances (ASG)

10. Create ALB

## 1️⃣1️⃣ Step 11: Verify & Test

- Check ALB: Open ALB DNS → see the website content

- Test Auto-Scaling:

    - Simulate high traffic → ASG scales out

    - Reduce traffic → ASG scales in

- Multi-AZ Test:

    - Stop one instance in AZ-1 → traffic handled by AZ-2

- Security Test:

    - Verify only ALB can reach EC2 instances (SSH from your IP works)

---

## 1️⃣2️⃣ Common Issues & Solutions

```
| Issue                                | Cause                         | Solution                                    |
| ------------------------------------ | ----------------------------- | ------------------------------------------- |
| EC2 not reachable via ALB            | Security Group misconfigured  | Allow inbound HTTP from ALB SG              |
| Auto Scaling not launching instances | Launch Template misconfigured | Check AMI, SG, subnets                      |
| ALB shows `503`                      | No healthy targets            | Check EC2 health check & instance user data |
| NAT Gateway not working              | Route Table misconfigured     | Ensure private subnet route points to NAT   |
| High traffic crashes site            | Insufficient ASG max size     | Increase max instances in ASG               |
```


