# ☕ AWS CAFE — AWS IAM Policy JSON Script

### 1️⃣ IAM Role for EC2 (Secrets Access)

#### 1️⃣ IAM Role Name:

```
EC2-Cafe-Secrets-Role
```

#### 2️⃣ Service You Must Select

When creating the IAM role:

- Trusted Entity Type : AWS Service

- Use Case / Service : ✅ EC2

> **This allows the EC2 instance to assume the role and use the permissions defined in your policy.**

#### ✅ Complete IAM Role Creation Steps:

- Go to: AWS Console → IAM → Roles

- Click: Create Role

- Select: Trusted entity type → AWS Service

- Then select: Use case → EC2

- Click: Next

- Attach your custom policy: EC2-Cafe-Secrets-Role

- Role name example: Cafe-EC2-Secrets-Role

- (Optional description): 

```
Role for EC2 to access Lambda, RDS, Secrets Manager, S3 and other services
```

- Click: Create Role

#### ✅ This policy contains permissions for:

- Lambda

- DynamoDB

- SQS

- S3

- Secrets Manager

- RDS

- API Gateway

- CloudWatch

- Elastic Load Balancer

- CloudFront

So this single custom policy replaces many AWS managed policies.

### AWS Managed Policies

In your merged setup you are using 0 AWS Managed Policies.

If you had used AWS managed policies instead of merging, the list would normally be something like:

- AWSLambda_FullAccess

- AmazonDynamoDBFullAccess

- AmazonS3FullAccess

- AmazonSQSFullAccess

- SecretsManagerReadWrite

- AmazonRDSFullAccess

- AmazonAPIGatewayAdministrator

- CloudWatchFullAccess

- ElasticLoadBalancingFullAccess

- CloudFrontFullAccess

### What You Need To Replace

Only ONE value needs to be replaced.

Replace:

```
YOUR_ACCOUNT_ID
```

Example:

```
arn:aws:lambda:us-east-1:123456789012:function:*
```

You can find your account ID here:

AWS Console → Top Right → Account ID

#### 1️⃣ Number of AWS Managed Policies

AWS Managed Policies:
These are policies created by Amazon Web Services like:

AmazonS3FullAccess

AWSLambdaFullAccess

AmazonDynamoDBFullAccess

In your case:

You did NOT use any AWS managed policy.

✅ AWS Managed Policies = 0

#### 2️⃣ Number of Custom Policies

You created your own policy JSON and merged everything into one file.

So in IAM it will appear as:

#### ✅ COPY-PASTE READY POLICY JSON

You can paste this directly into IAM → Policies → Create policy → JSON

[EC2-Cafe-Secrets-Role](./EC2-Cafe-Secrets-Role.json)

**⚠️ Attach role to EC2 (NO reboot).**

- **✔️ Click Create IAM ROLE**

### 2️⃣ IAM Role for Charlie Cafe

- **IAM Role Name:**

```
charlie-cafe-iam-Role
```

- Trusted entity type: AWS service

- Service: Lambda

- Click Next

- **Description:**

```
This IAM role is designed to support the backend services of the Charlie Cafe system by providing controlled access to AWS resources required for logging, database operations, message queue processing, secrets management, and file storage.
```

#### Step 3️⃣: Attach Permissions

- **IAM Role for Charlie Cafe Policies**

### 1️⃣ IAM Policies Method -1 ✅ Mega Custom IAM Policy

**👉 Paste into IAM → Policies → Create policy → JSON**

- Policy Name: charlie-cafe-iam-policy

- Region: us-east-1

- Account: Your AWS_Account_ID

- **Description:**

```
This IAM policy is designed to support the backend services of the Charlie Cafe system by providing controlled access to AWS resources required for logging, database operations, message queue processing, secrets management, and file storage.
```

### ✅ This policy includes:

### 1️⃣ AWS Managed Policies (permissions merged)

- AmazonDynamoDBFullAccess

- AmazonDynamoDBFullAccess_v2 (same permissions, safely merged once)

- AWSLambdaBasicExecutionRole

- AWSLambdaVPCAccessExecutionRole

- AmazonRDSDataFullAccess

- CloudWatchLogsFullAccess

### 2️⃣ Custom Policies (ALL merged)

- AWSLambdaBasicExecution (custom logs scope)

- CafeMenuDynamoDBReadPolicy

- CafeOrderWorkerPermissions

- CafeSecretsManagerAccess

- CafeSecretsManagerReadOnly

- CashPaymentLambda

- LambdaCafeSecretsAccess

- S3AppBucketAccessPolicy

- SendOrderToSQS

#### ✅ COPY-PASTE READY POLICY JSON

You can paste this directly into IAM → Policies → Create policy → JSON

[charlie-cafe-iam-policy](./charlie-cafe-iam-policy.json)

**⚠️ JUST Replace 123456789012 with your real AWS account ID. with your own account ID**

#### ✅ WHY THIS POLICY IS SAFE & CORRECT

✔ No duplicate invalid statements

✔ No conflicting ARNs

✔ Correct AWS service actions

✔ Passes IAM JSON validation

✔ Works for Lambda + DynamoDB + RDS + SQS + S3 + Secrets Manager

✔ Can be attached to Lambda execution roles

**✔️ Click Create policy**

---



