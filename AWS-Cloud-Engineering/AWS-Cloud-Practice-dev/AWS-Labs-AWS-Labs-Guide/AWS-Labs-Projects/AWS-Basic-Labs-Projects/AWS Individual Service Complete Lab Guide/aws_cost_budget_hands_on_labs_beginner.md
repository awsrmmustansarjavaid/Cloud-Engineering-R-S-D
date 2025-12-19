# Lab No 1 — CloudWatch Billing Alarms

## Cloud Service Provider
* Amazon Web Services (AWS)

## Difficulty
Level 100 (Introductory)

## Estimated Time
10–15 minutes

## Objectives
You need to complete the following:
* Create a billing alarm for **$5**
* Create a billing alarm for **$25**
* Create a billing alarm for **$100**

---

## Hands-on Steps

### Step 1: Enable Billing Alerts
1. Open **Billing & Cost Management**
2. Go to **Billing preferences**
3. Enable **Receive Billing Alerts**
4. Save preferences

---

### Step 2: Create SNS Topic
1. Open **Amazon SNS**
2. Create topic: `billing-alerts-topic`
3. Create email subscription and confirm it

---

### Step 3: Create Billing Alarms
1. Open **CloudWatch → Alarms → Create alarm**
2. Metric: **Billing → Total Estimated Charge**
3. Currency: **USD**
4. Thresholds:
   * Alarm 1: $5
   * Alarm 2: $25
   * Alarm 3: $100
5. Action: Notify SNS topic

---

## Questions & Answers

### 1. How many billing alarms are free?
Up to **10 billing alarms** are free under the AWS Free Tier.

### 2. How will you know when an alarm is triggered?
You will receive notifications via **Amazon SNS** (email/SMS/endpoint).

### 3. Difference between Billing Alarm and CloudWatch Alarm?
* **Billing Alarm:** Monitors estimated AWS charges only.
* **CloudWatch Alarm:** Monitors service/resource metrics like CPU, memory, etc.

---

## Output
✔ Billing alarms visible in CloudWatch

---
---

# Lab No 2 — Create an AWS Cost Budget

## Cloud Service Provider
* Amazon Web Services (AWS)

## Difficulty
Level 100 (Introductory)

## Estimated Time
20–40 minutes

## Objectives
* Create a monthly cost budget
* Configure alerts

---

## Hands-on Steps

### Step 1: Create Cost Budget
1. Go to **Billing → Budgets → Create budget**
2. Choose **Cost budget**
3. Budget name: `Monthly-Cost-Budget`
4. Period: **Monthly**
5. Amount: **$20**

---

### Step 2: Configure Alerts
Create alerts at:
* 70% actual cost
* 90% forecasted cost
* 100% actual cost

Notifications via **Email or SNS**

---

## Questions & Answers

### 1. What permissions are required for IAM users?
* `budgets:CreateBudget`
* `budgets:ViewBudget`
* `billing:ViewBilling`

### 2. Other ways to create budgets?
* AWS CLI
* AWS SDKs
* CloudFormation
* AWS Budgets API

### 3. Recurring vs time-bound budgets?
Recurring budgets are better for **long-term cost control**.

### 4. Types of budgets?
* Cost budgets
* Usage budgets
* RI utilization & coverage
* Savings Plans utilization & coverage

### 5. Alert options?
* Actual vs forecasted
* Percentage thresholds
* Email / SNS notifications

---

## Output
✔ Active cost budget with alerts

---
---

# 💰 AWS Cost & Budget Hands-On Labs (Beginner Friendly)

These labs are **similar in style and difficulty** to your CloudWatch Billing Alarm and Cost Budget labs. They are designed for **Level 100 learners** who want strong **cost governance fundamentals**.

---

# Lab No 3 — Enable Cost Allocation Tags & Track EC2 Costs

## Cloud Service Provider
* Amazon Web Services (AWS)

## Difficulty
Level 100 (Introductory)

## Estimated Time
20–30 minutes

## Objectives
You need to complete the following:
* Enable AWS cost allocation tags
* Tag EC2 resources
* View tagged costs in Cost Explorer

## Hands-on Steps

### Step 1: Enable Cost Allocation Tags
1. Open **Billing & Cost Management**
2. Go to **Cost Allocation Tags**
3. Enable:
   * `Name`
   * `Environment`
   * `Project`
4. Click **Activate**

⏱️ Note: It may take up to **24 hours** for tags to appear in reports.

---

### Step 2: Tag an EC2 Instance
1. Go to **EC2 Console → Instances**
2. Select any instance
3. Add tags:
   * Name = test-ec2
   * Environment = dev
   * Project = cost-lab

---

### Step 3: View Costs Using Cost Explorer
1. Open **Cost Explorer**
2. Filter by **Tag → Project = cost-lab**
3. Group by **Service**

---

## Questions & Answers

### 1. Why are cost allocation tags important?
They allow you to **track, group, and optimize costs** by project, environment, or team.

### 2. Are tags applied retroactively?
❌ No. Tags only apply to costs generated **after activation**.

---

## Output
✔ Tagged EC2 costs visible in Cost Explorer

---
---

# Lab No 4 — Create a Usage Budget for EC2

## Cloud Service Provider
* Amazon Web Services (AWS)

## Difficulty
Level 100 (Introductory)

## Estimated Time
15–25 minutes

## Objectives
* Create an EC2 usage budget
* Trigger alerts based on instance hours

---

## Hands-on Steps

### Step 1: Create Usage Budget
1. Go to **Billing → Budgets → Create budget**
2. Choose **Usage budget**
3. Budget name: `EC2-Usage-Budget`
4. Service: **EC2**
5. Usage type: **Instance hours**
6. Set limit: **50 hours/month**

---

### Step 2: Configure Alerts
Create alerts:
* 70% actual usage → Email
* 100% forecasted usage → Email

---

## Questions & Answers

### 1. When should you use a usage budget instead of cost budget?
When **resource consumption** matters more than price changes.

### 2. Can usage budgets stop resources automatically?
❌ No. They only send alerts.

---

## Output
✔ Email alerts triggered based on EC2 usage

---
---

# Lab No 5 — Enable AWS Cost Anomaly Detection

## Cloud Service Provider
* Amazon Web Services (AWS)

## Difficulty
Level 100 (Introductory)

## Estimated Time
15–20 minutes

## Objectives
* Detect unexpected cost spikes automatically
* Configure anomaly alerts

---

## Hands-on Steps

### Step 1: Create Anomaly Monitor
1. Open **Billing → Cost Anomaly Detection**
2. Create monitor:
   * Type: **AWS Services**
   * Monitor name: `Service-Anomaly-Monitor`

---

### Step 2: Create Alert Subscription
1. Alert name: `Cost-Spike-Alert`
2. Threshold: **$10 impact**
3. Notification: Email or SNS

---

## Questions & Answers

### 1. How is anomaly detection different from budgets?
Budgets are **rule-based**, anomaly detection is **ML-based**.

### 2. Is anomaly detection free?
✔ Basic anomaly detection is included at no extra cost.

---

## Output
✔ Alerts generated for unusual spending patterns

---
---

# Lab No 6 — Forecast Cost Alert Using Budgets

## Difficulty
Level 100

## Objectives
* Create a forecast-based cost alert

## Steps
1. Create **Cost Budget**
2. Monthly limit: **$20**
3. Alert type: **Forecasted cost**
4. Threshold: **80%**

---

## Why Forecast Alerts Matter
They warn you **before** costs exceed limits—not after damage is done.

---

# 🎯 What You Learn From These Labs

✔ AWS billing fundamentals
✔ Cost governance best practices
✔ Budget vs usage vs anomaly alerts
✔ Real-world FinOps skills

---

## Next Recommended Labs
* AWS Compute Optimizer
* Trusted Advisor cost checks
* Budgets with CloudFormation
* Lambda auto-shutdown on budget breach

---

✅ These labs are **Free Tier safe** and **resume-ready**.

