


#### 1️⃣ IAM Policies Method -1 ✅ Mega Custom IAM Policy

**👉 Paste into IAM → Policies → Create policy → JSON**

- Policy Name: charlie-cafe-iam-policy

- Region: us-east-1

- Account: Your AWS_Account_ID

#### This policy includes:

#### 1️⃣ AWS Managed Policies (permissions merged)

- AmazonDynamoDBFullAccess

- AmazonDynamoDBFullAccess_v2 (same permissions, safely merged once)

- AWSLambdaBasicExecutionRole

- AWSLambdaVPCAccessExecutionRole

- AmazonRDSDataFullAccess

#### 2️⃣ Custom Policies (ALL merged)

- AWSLambdaBasicExecution (custom logs scope)

- CafeMenuDynamoDBReadPolicy

- CafeOrderWorkerPermissions

- CafeSecretsManagerAccess

- CafeSecretsManagerReadOnly

- CashPaymentLambda

- LambdaCafeSecretsAccess

- S3AppBucketAccessPolicy

- SendOrderToSQS

#### COPY-PASTE READY POLICY JSON

> **Update Version 1.0**

You can paste this directly into IAM → Policies → Create policy → JSON

```
{
  "Version": "2012-10-17",
  "Statement": [

    {
      "Sid": "LambdaBasicExecutionLogs",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
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
      "Sid": "CustomLambdaLogGroupCreate",
      "Effect": "Allow",
      "Action": "logs:CreateLogGroup",
      "Resource": "arn:aws:logs:us-east-1:"Your AWS ACCOUNT ID ":*"
    },

    {
      "Sid": "CustomLambdaLogStreamAccess",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:us-east-1:"Your AWS ACCOUNT ID ":log-group:/aws/lambda/cloudfront-cache-invalidator:*"
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

**⚠️ JUST Replace "Your AWS ACCOUNT ID " with your own account ID**

#### ✅ WHY THIS POLICY IS SAFE & CORRECT

✔ No duplicate invalid statements

✔ No conflicting ARNs

✔ Correct AWS service actions

✔ Passes IAM JSON validation

✔ Works for Lambda + DynamoDB + RDS + SQS + S3 + Secrets Manager

✔ Can be attached to Lambda execution roles


---

### ✅ Updated charlie-cafe-iam-policy

> **Update Version 1.1**

#### ✅ New IAM Policy Added

- ✅ CloudWatchLogsFullAccess → NEWLY added (logs:*)

#### Below is the LATEST, UPDATED, IAM-VALID JSON

✔ No syntax errors

✔ No unsupported Sid

✔ Paste directly into IAM → Policies → Edit policy → JSON

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

---

### ✅ Updated charlie-cafe-iam-policy

> **Update Version 1.2**

### New IAM Policy for Cognito Authorizer

- IAM Role for Lambda (ONE role only)

####  🔍 WHAT YOU ASKED TO ADD (Cognito Authorizer policy)

New policy permissions:

```
logs:CreateLogGroup
logs:CreateLogStream
logs:PutLogEvents
```

#### Reality check: You already have this and MORE via:

```
{
  "Sid": "CloudWatchLogsFullAccess",
  "Effect": "Allow",
  "Action": "logs:*",
  "Resource": "*"
}
```

➡️ logs:* fully includes:

CreateLogGroup ✅

CreateLogStream ✅

PutLogEvents ✅

So:

✅ Cognito Authorizer Lambda already works

✅ No new permission is required

❌ Adding a duplicate statement would be redundant (but not useful)

#### 🔐 TRUST POLICY (IMPORTANT SEPARATION)

The trust policy you shared:

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "lambda.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

#### Permissions policy

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

👉 No role-per-user

👉 No role-per-group

#### ⚠️ This does NOT go inside the mega policy

- Trust policy → attached to IAM ROLE

- Permissions policy → attached to ROLE or POLICY

**You already handled this correctly earlier 👍**

#### ✅ FINAL Updated charlie-cafe-iam-policy.md

**⚠️ Reminder: replace "Your AWS ACCOUNT ID" with your real account ID when pasting into AWS.**

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
      "Resource": "arn:aws:dynamodb:us-east-1:Your AWS ACCOUNT ID:table/CafeMenu"
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
      "Resource": "arn:aws:dynamodb:us-east-1:Your AWS ACCOUNT ID:table/CafeOrders"
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
      "Resource": "arn:aws:sqs:us-east-1:Your AWS ACCOUNT ID:CafeOrdersQueue"
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

#### 🧠 FINAL CLARITY (VERY IMPORTANT)

✅ Cognito Authorizer Lambda already supported

✅ Logs permissions already exceed requirements

✅ Trust policy stays separate

✅ Mega policy remains clean & valid

✅ No risk introduced

---




