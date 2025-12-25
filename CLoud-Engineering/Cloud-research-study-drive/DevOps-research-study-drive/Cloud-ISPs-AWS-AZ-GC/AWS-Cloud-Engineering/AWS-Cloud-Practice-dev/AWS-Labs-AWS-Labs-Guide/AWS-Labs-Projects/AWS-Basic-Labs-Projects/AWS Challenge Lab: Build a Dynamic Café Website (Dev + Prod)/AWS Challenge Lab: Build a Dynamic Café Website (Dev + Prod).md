# 🚀 AWS Challenge Lab: Build a Dynamic Café Website (Dev + Prod)

**Objective:**  
Transform a simple café website into a fully functional dynamic online ordering system deployed across two AWS Regions.

---

## Prerequisites

- AWS account with full EC2, VPC, RDS, IAM, and Secrets Manager access  
- Basic understanding of Linux commands  
- Installed VS Code with AWS Cloud9 or local SSH setup  
- Knowledge of MySQL, PHP, and Apache  

---

## 1️⃣ Create the Development Environment (us-east-1)

### Step 1: Launch a VPC & Networking
1. Go to **VPC Console → Create VPC**  
   - Name: `CafeDevVPC`  
   - CIDR block: `10.0.0.0/16`  
2. Create a **public subnet**  
   - Name: `CafeDevPublicSubnet`  
   - CIDR: `10.0.1.0/24`  
   - Map public IP: Enabled  
3. Create **Internet Gateway → Attach to CafeDevVPC**  
4. Create **Route Table → Associate with public subnet**  
   - Route: `0.0.0.0/0 → Internet Gateway`  

---

### Step 2: Launch EC2 Instance (LAMP Stack)
1. Go to **EC2 Console → Launch Instance**  
2. Select **Amazon Linux 2023 AMI**  
3. Instance type: `t2.micro` (free tier if eligible)  
4. Configure network:  
   - VPC: `CafeDevVPC`  
   - Subnet: `CafeDevPublicSubnet`  
5. Storage: default 8 GB  
6. Tags: `Name = CafeDevWebServer`  
7. Security Group:  
   - Allow SSH (22) from your IP  
   - Allow HTTP (80) from anywhere  
8. Launch → Download key pair `.pem`  

---

### Step 3: Connect to EC2
```bash
chmod 400 CafeDevKey.pem
ssh -i "CafeDevKey.pem" ec2-user@<Public-IP>
```

