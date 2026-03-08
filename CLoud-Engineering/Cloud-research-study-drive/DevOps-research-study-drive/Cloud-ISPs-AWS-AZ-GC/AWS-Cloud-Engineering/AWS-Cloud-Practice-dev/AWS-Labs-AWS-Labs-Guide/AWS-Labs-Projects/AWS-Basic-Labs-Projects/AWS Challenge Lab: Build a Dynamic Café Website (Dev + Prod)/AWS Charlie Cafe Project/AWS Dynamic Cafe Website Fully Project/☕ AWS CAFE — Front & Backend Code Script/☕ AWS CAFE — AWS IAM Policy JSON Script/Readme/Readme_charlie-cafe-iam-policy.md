# Charlie Cafe - charlie-cafe-iam-policy.json

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
**Replace ARN with  Your Lambda Functions**
