# Charlie Cafe - charlie-cafe-iam-policy.json

### 🔑 Core Rule (Simple)

- { } → Object (one policy block)

- [ ] → Array (list of objects)

- , → separates items in a list

### 🧠 Your IAM Structure (VERY IMPORTANT)

```
{
  "Version": "2012-10-17",
  "Statement": [
    { ... },
    { ... },
    { ... }
  ]
}
```

👉 "Statement" is an array [ ]

👉 Inside it, you have multiple { } objects

### ✅ How to ADD a NEW policy block

#### Rule:

✔ Add comma , after the previous block

✔ Then add a new { } object inside the array

### ❌ WRONG (what beginners do)

```
{
  "Sid": "S3ECSAccess",
  ...
}
{
  "Sid": "NewPolicy",
  ...
}
```

👉 ❌ Missing comma → JSON error

### ✅ CORRECT WAY

```
{
  "Sid": "S3ECSAccess",
  "Effect": "Allow",
  "Action": [
    "s3:GetObject",
    "s3:PutObject"
  ],
  "Resource": "*"
},
{
  "Sid": "NewPolicy",
  "Effect": "Allow",
  "Action": [
    "sns:Publish"
  ],
  "Resource": "*"
}
```

### 📌 VERY IMPORTANT RULES

### 1. Last item → NO comma

```
{ ... },
{ ... }   ❌ no comma here
]
```

### 2. Every new policy = new { }

```
[
  { policy1 },
  { policy2 },
  { policy3 }
]
```

### 3. Never repeat this:

❌ DO NOT add another "Statement": [ ] inside

```
{
  "Statement": [
    { ... },

    ❌ WRONG:
    {
      "Statement": [ ... ]
    }
  ]
}
```

### 🔥 Your Exact Case (How to extend after S3ECSAccess)

You currently have:

```
{
  "Sid": "S3ECSAccess",
  "Effect": "Allow",
  "Action": [
    "s3:GetObject",
    "s3:PutObject"
  ],
  "Resource": "*"
}
```

### 👉 To ADD another policy after it:

Step 1: Add comma ,

Step 2: Add new { }

```
{
  "Sid": "S3ECSAccess",
  "Effect": "Allow",
  "Action": [
    "s3:GetObject",
    "s3:PutObject"
  ],
  "Resource": "*"
},
{
  "Sid": "MyNewPolicy",
  "Effect": "Allow",
  "Action": [
    "sns:Publish"
  ],
  "Resource": "*"
}
```

### 💡 Memory Trick (Best Way to Remember)

#### Think like this:

👉 "Statement" = list of permissions

👉 Each permission = { }

👉 Separate them with ,

### 🧪 Pro Tip (Avoid Errors)

#### Before saving:

- Paste JSON into validator 👉 https://jsonlint.com

- AWS will reject if:

- missing comma

- extra comma

- wrong brackets

### 🚀 Simple 

```
Add new policy =
1. Go to last }
2. Add ,
3. Paste new { ... }
```
---

### charlie-cafe-iam-policy.json

```
{
  "Version": "2012-10-17",
  "Statement": [

    {
      "Sid": "CloudWatchLogsFullAccess",
      "Effect": "Allow",
      "Action": "logs:*",
      "Resource": "*"
    },

    {
      "Sid": "LambdaVPCAccess",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:AssignPrivateIpAddresses",
        "ec2:UnassignPrivateIpAddresses"
      ],
      "Resource": "*"
    },

    {
      "Sid": "DynamoDBFullAccess",
      "Effect": "Allow",
      "Action": "dynamodb:*",
      "Resource": "*"
    },

    {
      "Sid": "RDSDataAPIFullAccess",
      "Effect": "Allow",
      "Action": [
        "rds-data:ExecuteStatement",
        "rds-data:BatchExecuteStatement",
        "rds-data:BeginTransaction",
        "rds-data:CommitTransaction",
        "rds-data:RollbackTransaction"
      ],
      "Resource": "*"
    },

    {
      "Sid": "CafeMenuTableAccess",
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:Scan",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:"Your AWS ACCOUNT ID ":table/CafeMenu"
    },

    {
      "Sid": "CafeOrdersTableAccess",
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:"Your AWS ACCOUNT ID ":table/CafeOrders"
    },

    {
      "Sid": "CafeOrdersQueueAccess",
      "Effect": "Allow",
      "Action": [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": "arn:aws:sqs:us-east-1:"Your AWS ACCOUNT ID ":CafeOrdersQueue"
    },

    {
      "Sid": "CafeSecretsManagerAccess",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": [
        "arn:aws:secretsmanager:us-east-1:*:secret:CafeDevDBSM*",
        "arn:aws:secretsmanager:us-east-1:*:secret:CafeDevDBSecret*"
      ]
    },

    {
      "Sid": "CafeS3AppBucketAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::demo-test-s3-b",
        "arn:aws:s3:::demo-test-s3-b/*"
      ]
    }

  ]
}
```

### ✅ Fixed & Fully Working IAM Policy

Replace 123456789012 with your real AWS account ID.

```
{
  "Version": "2012-10-17",
  "Statement": [

    {
      "Sid": "CloudWatchLogsFullAccess",
      "Effect": "Allow",
      "Action": "logs:*",
      "Resource": "*"
    },

    {
      "Sid": "LambdaVPCAccess",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:AssignPrivateIpAddresses",
        "ec2:UnassignPrivateIpAddresses"
      ],
      "Resource": "*"
    },

    {
      "Sid": "DynamoDBFullAccess",
      "Effect": "Allow",
      "Action": "dynamodb:*",
      "Resource": "*"
    },

    {
      "Sid": "RDSDataAPIFullAccess",
      "Effect": "Allow",
      "Action": [
        "rds-data:ExecuteStatement",
        "rds-data:BatchExecuteStatement",
        "rds-data:BeginTransaction",
        "rds-data:CommitTransaction",
        "rds-data:RollbackTransaction"
      ],
      "Resource": "*"
    },

    {
      "Sid": "CafeMenuTableAccess",
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:Scan",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:123456789012:table/CafeMenu"
    },

    {
      "Sid": "CafeOrdersTableAccess",
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:123456789012:table/CafeOrders"
    },

    {
      "Sid": "CafeOrdersQueueAccess",
      "Effect": "Allow",
      "Action": [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": "arn:aws:sqs:us-east-1:123456789012:CafeOrdersQueue"
    },

    {
      "Sid": "CafeSecretsManagerAccess",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": [
        "arn:aws:secretsmanager:us-east-1:*:secret:CafeDevDBSM*",
        "arn:aws:secretsmanager:us-east-1:*:secret:CafeDevDBSecret*"
      ]
    },

    {
      "Sid": "CafeS3AppBucketAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::demo-test-s3-b",
        "arn:aws:s3:::demo-test-s3-b/*"
      ]
    }

  ]
}
```


#### 2️⃣ IAM Policies Method - 2 1-2-1 Each Single IAM Policies

#### 1️⃣ Create IAM Policy for  PRODUCER LAMBDA
> **Your API Lambda must be allowed to send messages.**

- **Custom Policy name:** 

```
SendOrderToSQS
```

#### Paste exactly:

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:CafeOrdersQueue"
    }
  ]
}
```

**✔️ Click Create policy**

#### 2️⃣ Create IAM Policy for DynamoDB Access
> **Now Lambda needs permission to read from DynamoDB.**

- **Custom Policy name:** 

```        
CafeMenuDynamoDBReadPolicy
```

#### JSON

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:Scan",
        "dynamodb:PutItem"
      ],
      "Resource": "arn:aws:dynamodb:YOUR-REGION:YOUR-ACCOUNT-ID:table/CafeMenu"
    }
  ]
}
```

#### 📌 Example:

```
arn:aws:dynamodb:us-east-1:123456789012:table/CafeMenu
```
**✔️ Click Create policy**

#### 3️⃣ Create IAM Policy FOR WORKER LAMBDA
> **Your worker needs 3 permissions**

**AWS IAM Policies:**

```
AmazonDynamoDBFullAccess
AWSSecretsManagerReadOnly
AmazonSQSFullAccess
```

- **Custom Policy name:** 

```
CafeOrderWorkerPermissions
```

#### Add inline policy with:
> **Attach These Permissions**

#### JSON

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": "your SQS arn url"
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "your secrets manager arn url*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:GetItem"
      ],
      "Resource": "your DynamoDB arn url"
    }
  ]
}
```

**✔️ Click Create policy**

#### 4️⃣ Create IAM Policy FOR DYNAMODB METRICS TABLE (FULL)

- **Custom Policy name:** 

```
CafeSecretsManagerReadOnly
```

- **Description:**

```
Read-only access to Secrets Manager for Lambda
```

#### Add inline policy with:
> **Attach These Permissions**

#### JSON

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "*"
    }
  ]
}
```

#### ✅ This allows:

- Read secret value

- Describe secret

- ❌ No delete

- ❌ No update


**✔️ Click Create policy**

#### 5️⃣ Create IAM Policy FOR DYNAMODB METRICS TABLE (FULL)
> **RDS access (same as Worker)**

**AWS IAM Policies:**

```
AmazonDynamoDBReadOnlyAccess
```

**✔️ Click Create policy**

#### 6️⃣ Create IAM Policy FOR CafeAnalyticsLambda

**AWS IAM Policies:**

```
AmazonDynamoDBReadOnlyAccess
CloudWatchLogsFullAccess
```

✅ Without this → Lambda fails silently

✅ With this → Lambda can read DynamoDB + write logs

**✔️ Click Create policy**

#### 7️⃣ Create IAM Policy FOR CashPaymentLambda & AdminMarkPaidLambda
> **⚠️ If this is missing → Lambda WILL FAIL.**

- **Custom Policy name:** 

```
CashPaymentLambda
```

Attach this policy (or ensure it exists):

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:aaaaaa55564333:table/CafeOrders"
    }
  ]
}
```

**✔️ Click Create policy**

#### 8️⃣ Create IAM Policy FOR HR System
> **If you already have a Lambda role that accesses RDS + CloudWatch, reuse it. If not, follow every step below.**

- Trusted entity type: AWS service

- Service: Lambda

- Click Next

#### Step 3️⃣: Attach Permissions

- Attach exactly these policies:

    - AWSLambdaBasicExecutionRole

    - AmazonRDSDataFullAccess (or your custom RDS policy)

- Click Next

**✔️ Click Create policy**

#### 9️⃣ Create IAM Policy  HR ATTENDANCE DASHBOARD

- Lambda role permissions:

  - AmazonDynamoDBFullAccess

  - CloudWatchLogsFullAccess

#### 🔟 Create IAM Policy Cognito Authorizer

- **Custom Policy name:** 

```
Cognito-Authorizer-IAM
```

Attach this policy (or ensure it exists):

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
```
**✔️ Click Create policy**

- **✔️ Click Create IAM ROLE**

### 3️⃣ IAM Role for Router Lambda

- **IAM Role Name:**

```
charlie-cafe-RouterLambda
```

- **Description:**

```
Allow Lambda invoke permissions for other Lambdas.
```

#### 1️⃣ Create IAM Policy Cognito Authorizer

- **Custom Policy name:** 

```
OrderStatusRouterLambda
```

Attach this policy (or ensure it exists):

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "lambda:InvokeFunction",
            "Resource": [
                "arn:aws:lambda:us-east-1:123456789012:function:GetOrderStatusLambda",
                "arn:aws:lambda:us-east-1:123456789012:function:CafeOrderStatusLambda",
                "arn:aws:lambda:us-east-1:123456789012:function:OrderStatusLambda"
            ]
        }
    ]
}
```

### Fully final charlie-cafe-iam-policy.json

```
{
  "Version": "2012-10-17",
  "Statement": [

    {
      "Sid": "CloudWatchLogsFullAccess",
      "Effect": "Allow",
      "Action": "logs:*",
      "Resource": "*"
    },

    {
      "Sid": "LambdaVPCAccess",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:AssignPrivateIpAddresses",
        "ec2:UnassignPrivateIpAddresses"
      ],
      "Resource": "*"
    },

    {
      "Sid": "DynamoDBFullAccess",
      "Effect": "Allow",
      "Action": "dynamodb:*",
      "Resource": "*"
    },

    {
      "Sid": "RDSDataAPIFullAccess",
      "Effect": "Allow",
      "Action": [
        "rds-data:ExecuteStatement",
        "rds-data:BatchExecuteStatement",
        "rds-data:BeginTransaction",
        "rds-data:CommitTransaction",
        "rds-data:RollbackTransaction"
      ],
      "Resource": "*"
    },

    {
      "Sid": "CafeMenuTableAccess",
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:Scan",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:123456789012:table/CafeMenu"
    },

    {
      "Sid": "CafeOrdersTableAccess",
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:123456789012:table/CafeOrders"
    },

    {
      "Sid": "CafeOrdersQueueAccess",
      "Effect": "Allow",
      "Action": [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": "arn:aws:sqs:us-east-1:123456789012:CafeOrdersQueue"
    },

    {
      "Sid": "CafeSecretsManagerAccess",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": [
        "arn:aws:secretsmanager:us-east-1:*:secret:CafeDevDBSM*",
        "arn:aws:secretsmanager:us-east-1:*:secret:CafeDevDBSecret*"
      ]
    },

    {
      "Sid": "CafeS3AppBucketAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::demo-test-s3-b",
        "arn:aws:s3:::demo-test-s3-b/*"
      ]
    }

  ]
}
```

**Replace ARN with  Your Lambda Functions**
---
### ✅ charlie-cafe-iam-policy.json

> #### Update Version: 1.1

### ✅ AWS DEVOPS IAM Policies

### 🔐 🎯 WHY IAM IS REQUIRED

#### IAM allows:


- GitHub → push image to ECR

- ECS → pull image from ECR

- ECS → write logs to CloudWatch

- ECS → access Secrets / RDS

👉 Without IAM = ❌ deployment fails

### 🧠 🔑 IAM ROLES YOU NEED (IMPORTANT)

#### You need 3 IAM roles:

| Role                    | Used By   | Purpose                  |
| ----------------------- | --------- | ------------------------ |
| GitHub Role / User      | CI/CD     | Push to ECR + deploy ECS |
| ECS Task Execution Role | ECS       | Pull image + logs        |
| ECS Task Role           | Container | Access AWS services      |

### 🧱 1️⃣ GITHUB IAM POLICY (CI/CD)

Attach this to your IAM User or Role used in GitHub Secrets

#### ✅ JSON POLICY (FULL)

```
{
  "Version": "2012-10-17",
  "Statement": [

    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage"
      ],
      "Resource": "*"
    },

    {
      "Effect": "Allow",
      "Action": [
        "ecs:UpdateService",
        "ecs:DescribeServices",
        "ecs:RegisterTaskDefinition"
      ],
      "Resource": "*"
    },

    {
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": "*"
    }
  ]
}
```

### 🐳 2️⃣ ECS TASK EXECUTION ROLE POLICY

This is VERY IMPORTANT
Attach to:

```
ecsTaskExecutionRole
```

#### ✅ JSON POLICY

```
{
  "Version": "2012-10-17",
  "Statement": [

    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ],
      "Resource": "*"
    },

    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
```

### 🔐 3️⃣ ECS TASK ROLE (OPTIONAL BUT BEST PRACTICE)

Used by your app inside container

#### 👉 Needed if:

- You use Secrets Manager

- You access S3

- You call Lambda

#### ✅ Example 

```
{
  "Version": "2012-10-17",
  "Statement": [

    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "*"
    },

    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "*"
    }
  ]
}
```

### 📦 4️⃣ OPTIONAL (CloudWatch Logs FULL)

If logs fail → use this:

```
{
  "Effect": "Allow",
  "Action": [
    "logs:*"
  ],
  "Resource": "*"
}
```

### ✅ Fully final merged IAM Policies

```
{
  "Version": "2012-10-17",
  "Statement": [

    // ================================
    // ECR Permissions (GitHub + ECS)
    // ================================
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ],
      "Resource": "*"
    },

    // ================================
    // ECS Permissions (GitHub CI/CD)
    // ================================
    {
      "Effect": "Allow",
      "Action": [
        "ecs:UpdateService",
        "ecs:DescribeServices",
        "ecs:RegisterTaskDefinition"
      ],
      "Resource": "*"
    },

    // ================================
    // IAM Pass Role (required for ECS)
    // ================================
    {
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": "*"
    },

    // ================================
    // CloudWatch Logs (ECS Task Execution)
    // ================================
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:CreateLogGroup"
      ],
      "Resource": "*"
    },

    // ================================
    // Secrets Manager (ECS Task Role)
    // ================================
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "*"
    },

    // ================================
    // S3 Access (ECS Task Role)
    // ================================
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "*"
    }
  ]
}
```

### ✅ Explanation of the merged policy

| Section         | Purpose                                                          |
| --------------- | ---------------------------------------------------------------- |
| ECR Permissions | GitHub CI/CD can push Docker images to ECR and ECS can pull them |
| ECS Permissions | Update ECS services and register task definitions                |
| IAM Pass Role   | Needed for ECS tasks to assume roles (required in deployments)   |
| CloudWatch Logs | ECS containers can log output for monitoring/debugging           |
| Secrets Manager | ECS containers can read database credentials or other secrets    |
| S3 Access       | Optional: ECS containers can read/write files from S3 if needed  |



### 🔐 5️⃣ CONNECT TO GITHUB

### ✅ Step 1 — Create IAM User

```
IAM → Users → Create user
```

#### Enable:

✔ Programmatic access

### ✅ Step 2 — Attach Policy

#### Attach:

```
CharlieCafe-ECR-ECS-Policy
```

### ✅ Step 3 — Copy Keys

#### You will get:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

### ✅ Step 4 — Add to GitHub

- 👉 Repo → Settings → Secrets

#### Add:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

### 🚨 COMMON MISTAKES (IMPORTANT)

❌ Missing iam:PassRole → ECS deployment fails

❌ Missing ECR permissions → push fails

❌ Missing logs → debugging impossible

### 🎯 FINAL RESULT

#### After IAM setup:

✅ GitHub can push Docker image

✅ ECS can pull image

✅ Containers can run properly

✅ Logs work

✅ Secrets access works

### 🔐 ✅ FINAL MERGED IAM POLICY (PRODUCTION READY)

👉 You can copy-paste this directly into AWS IAM

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CloudWatchLogsFullAccess",
            "Effect": "Allow",
            "Action": "logs:*",
            "Resource": "*"
        },
        {
            "Sid": "LambdaVPCAccess",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface",
                "ec2:AssignPrivateIpAddresses",
                "ec2:UnassignPrivateIpAddresses"
            ],
            "Resource": "*"
        },
        {
            "Sid": "DynamoDBFullAccess",
            "Effect": "Allow",
            "Action": "dynamodb:*",
            "Resource": "*"
        },
        {
            "Sid": "RDSDataAPIFullAccess",
            "Effect": "Allow",
            "Action": [
                "rds-data:ExecuteStatement",
                "rds-data:BatchExecuteStatement",
                "rds-data:BeginTransaction",
                "rds-data:CommitTransaction",
                "rds-data:RollbackTransaction"
            ],
            "Resource": "*"
        },
        {
            "Sid": "CafeMenuTableAccess",
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:Scan",
                "dynamodb:PutItem",
                "dynamodb:UpdateItem"
            ],
            "Resource": "arn:aws:dynamodb:us-east-1:537236558357:table/CafeMenu"
        },
        {
            "Sid": "CafeOrdersTableAccess",
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:GetItem",
                "dynamodb:UpdateItem",
                "dynamodb:DeleteItem",
                "dynamodb:Query",
                "dynamodb:Scan"
            ],
            "Resource": "arn:aws:dynamodb:us-east-1:537236558357:table/CafeOrders"
        },
        {
            "Sid": "CafeOrdersQueueAccess",
            "Effect": "Allow",
            "Action": [
                "sqs:SendMessage",
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage",
                "sqs:GetQueueAttributes"
            ],
            "Resource": "arn:aws:sqs:us-east-1:537236558357:CafeOrdersQueue"
        },
        {
            "Sid": "CafeSecretsManagerAccess",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
            ],
            "Resource": [
                "arn:aws:secretsmanager:us-east-1:*:secret:CafeDevDBSM*",
                "arn:aws:secretsmanager:us-east-1:*:secret:CafeDevDBSecret*"
            ]
        },
        {
            "Sid": "CafeS3AppBucketAccess",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::demo-test-s3-b",
                "arn:aws:s3:::demo-test-s3-b/*"
            ]
        },
        {
            "Sid": "ECRFullAccess",
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:CompleteLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:InitiateLayerUpload",
                "ecr:PutImage",
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ECSFullAccess",
            "Effect": "Allow",
            "Action": [
                "ecs:UpdateService",
                "ecs:DescribeServices",
                "ecs:RegisterTaskDefinition"
            ],
            "Resource": "*"
        },
        {
            "Sid": "IAMPassRoleSecure",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": [
                        "ecs.amazonaws.com",
                        "lambda.amazonaws.com",
                        "codepipeline.amazonaws.com"
                    ]
                }
            }
        }
    ]
}
```

### ⚠️ VERY IMPORTANT NOTE

👉 Replace this:

```
"123456789012"
```

with your real AWS Account ID.

### 🧠 WHAT YOU JUST BUILT

This single policy now supports:

#### ✅ Your existing system

- Lambda (VPC access)

- DynamoDB

- RDS Data API

- SQS

- S3

- Secrets Manager

#### ✅ Your new DevOps system

- ECR (Docker push/pull)

- ECS (deployment)

- GitHub CI/CD

- CloudWatch logs

### 🚨 CRITICAL WARNING (REAL WORLD)

#### This policy uses:

```
"Resource": "*"
```

#### 👉 This is OK for:

✔ Lab

✔ Learning

✔ Portfolio

❌ Not recommended for production (should be restricted later)

### 🎯 FINAL RESULT

#### You now have:

✅ One unified IAM policy

✅ Covers ALL services

✅ Ready for ECS + ECR + CI/CD

✅ Clean Sid labels (interview friendly)


---


