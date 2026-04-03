# Charlie Cafe - EC2-Cafe-Secrets-Role

### 1️⃣ IAM Role for EC2 (Secrets Access)

#### IAM Role Name:

```
EC2-Cafe-Secrets-Role
```

- **IAM Role for EC2 (Secrets Access) Policies**

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "secretsmanager:GetSecretValue",
    "Resource": "arn:aws:secretsmanager:us-east-1:*:secret:CafeDevDBSM*"
  }]
}
```

- **IAM Role for EC2 (Secrets Access) Policies**

- name: Lambda_test_EC2-CLI 

```json
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": "lambda:InvokeFunction",
			"Resource": "arn:aws:lambda:us-east-1:your aws account id :function:*"
		}
	]
}
```
 or 
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "FullLambdaAccessForTesting",
      "Effect": "Allow",
      "Action": [
        "lambda:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DynamoDBFull",
      "Effect": "Allow",
      "Action": "dynamodb:*",
      "Resource": "*"
    },
    {
      "Sid": "SQSFull",
      "Effect": "Allow",
      "Action": "sqs:*",
      "Resource": "*"
    },
    {
      "Sid": "S3FullForTesting",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    },
    {
      "Sid": "SecretsManagerFull",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "RDSManagementAndConnect",
      "Effect": "Allow",
      "Action": [
        "rds:*",
        "rds-data:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "APIGatewayManagement",
      "Effect": "Allow",
      "Action": "apigateway:*",
      "Resource": "*"
    },
    {
      "Sid": "CloudWatchLogsAndMetrics",
      "Effect": "Allow",
      "Action": [
        "logs:*",
        "cloudwatch:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ALBFullAccess",
      "Effect": "Allow",
      "Action": "elasticloadbalancing:*",
      "Resource": "*"
    },
    {
      "Sid": "CloudFrontFull",
      "Effect": "Allow",
      "Action": "cloudfront:*",
      "Resource": "*"
    }
  ]
}
```

You can merge both IAM policies into one by combining the Statements into a single policy document.
I also corrected a small issue in your first policy where the Lambda ARN had spaces.

Below is the merged IAM policy JSON you can save and create with the name:

### ✅ Fully Final EC2-Cafe-Secrets-Role


```
{
  "Version": "2012-10-17",
  "Statement": [
    
    {
      "Sid": "InvokeLambdaFunctions",
      "Effect": "Allow",
      "Action": "lambda:InvokeFunction",
      "Resource": "arn:aws:lambda:us-east-1:YOUR_ACCOUNT_ID:function:*"
    },

    {
      "Sid": "FullLambdaAccessForTesting",
      "Effect": "Allow",
      "Action": [
        "lambda:*"
      ],
      "Resource": "*"
    },

    {
      "Sid": "DynamoDBFull",
      "Effect": "Allow",
      "Action": "dynamodb:*",
      "Resource": "*"
    },

    {
      "Sid": "SQSFull",
      "Effect": "Allow",
      "Action": "sqs:*",
      "Resource": "*"
    },

    {
      "Sid": "S3FullForTesting",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    },

    {
      "Sid": "SecretsManagerFull",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:*"
      ],
      "Resource": "*"
    },

    {
      "Sid": "RDSManagementAndConnect",
      "Effect": "Allow",
      "Action": [
        "rds:*",
        "rds-data:*"
      ],
      "Resource": "*"
    },

    {
      "Sid": "APIGatewayManagement",
      "Effect": "Allow",
      "Action": "apigateway:*",
      "Resource": "*"
    },

    {
      "Sid": "CloudWatchLogsAndMetrics",
      "Effect": "Allow",
      "Action": [
        "logs:*",
        "cloudwatch:*"
      ],
      "Resource": "*"
    },

    {
      "Sid": "ALBFullAccess",
      "Effect": "Allow",
      "Action": "elasticloadbalancing:*",
      "Resource": "*"
    },

    {
      "Sid": "CloudFrontFull",
      "Effect": "Allow",
      "Action": "cloudfront:*",
      "Resource": "*"
    }

  ]
}
```

Important

Replace:

```
YOUR_ACCOUNT_ID
```

with your AWS account ID, for example:

```
arn:aws:lambda:us-east-1:123456789012:function:*
```

#### How to create it in AWS

- Open IAM Console

- Go to Policies

- Click Create Policy

- Select JSON

- Paste the merged policy

- Click Next

- Name it:

```
EC2-Cafe-Secrets-Role
```

- Create policy and attach it to your EC2 Role

### ✅ Small Professional Advice (Important)

This policy gives very wide permissions (*), which is fine for lab/testing, but not recommended for production.

For production you should restrict:

- S3 bucket names

- Specific Lambda functions

- Specific RDS resources

- Specific Secrets Manager secrets

### ✅ S3 Full Access added

Below is your fully merged and updated IAM policy with S3 Full Access added.
This policy includes permissions for:

Lambda

DynamoDB

SQS

S3 (Full Access)

Secrets Manager

RDS

API Gateway

CloudWatch

ALB

CloudFront

### Final Working Merged IAM Policy

Replace YOUR_ACCOUNT_ID with your AWS account ID.

```
{
  "Version": "2012-10-17",
  "Statement": [

    {
      "Sid": "InvokeLambdaFunctions",
      "Effect": "Allow",
      "Action": "lambda:InvokeFunction",
      "Resource": "arn:aws:lambda:us-east-1:YOUR_ACCOUNT_ID:function:*"
    },

    {
      "Sid": "LambdaFullAccess",
      "Effect": "Allow",
      "Action": "lambda:*",
      "Resource": "*"
    },

    {
      "Sid": "DynamoDBFullAccess",
      "Effect": "Allow",
      "Action": "dynamodb:*",
      "Resource": "*"
    },

    {
      "Sid": "SQSFullAccess",
      "Effect": "Allow",
      "Action": "sqs:*",
      "Resource": "*"
    },

    {
      "Sid": "S3FullAccess",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    },

    {
      "Sid": "SecretsManagerFullAccess",
      "Effect": "Allow",
      "Action": "secretsmanager:*",
      "Resource": "*"
    },

    {
      "Sid": "RDSFullAccess",
      "Effect": "Allow",
      "Action": [
        "rds:*",
        "rds-data:*"
      ],
      "Resource": "*"
    },

    {
      "Sid": "APIGatewayFullAccess",
      "Effect": "Allow",
      "Action": "apigateway:*",
      "Resource": "*"
    },

    {
      "Sid": "CloudWatchFullAccess",
      "Effect": "Allow",
      "Action": [
        "logs:*",
        "cloudwatch:*"
      ],
      "Resource": "*"
    },

    {
      "Sid": "ElasticLoadBalancingFullAccess",
      "Effect": "Allow",
      "Action": "elasticloadbalancing:*",
      "Resource": "*"
    },

    {
      "Sid": "CloudFrontFullAccess",
      "Effect": "Allow",
      "Action": "cloudfront:*",
      "Resource": "*"
    }

  ]
}
```

### Important Note (For Your AWS Café Project)

This policy gives very broad permissions (*), which is OK for learning, labs, and testing, especially if you are building your:

- Charlie Café AWS architecture

- Lambda + API Gateway

- RDS attendance system

- Cognito login system

- CloudFront frontend

- But in production, permissions should be restricted.

### ✅ IAM Role for EC2 (Secrets Access) Policies

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "secretsmanager:GetSecretValue",
    "Resource": "arn:aws:secretsmanager:us-east-1:*:secret:CafeDevDBSM*"
  }]
}
```

Below is your fully merged final IAM policy including the new permission for Secrets Manager GetSecretValue for CafeDevDBSM secrets.

I merged all policies into one clean final policy.

### ✅ Final IAM Policy (EC2-Cafe-Secrets-Role)

Replace YOUR_ACCOUNT_ID with your AWS account ID.

Example account ID:

```
123456789012
```

### ✅ Fully final EC2-Cafe-Secrets-Role

```
{
  "Version": "2012-10-17",
  "Statement": [

    {
      "Sid": "InvokeLambdaFunctions",
      "Effect": "Allow",
      "Action": "lambda:InvokeFunction",
      "Resource": "arn:aws:lambda:us-east-1:YOUR_ACCOUNT_ID:function:*"
    },

    {
      "Sid": "LambdaFullAccess",
      "Effect": "Allow",
      "Action": "lambda:*",
      "Resource": "*"
    },

    {
      "Sid": "DynamoDBFullAccess",
      "Effect": "Allow",
      "Action": "dynamodb:*",
      "Resource": "*"
    },

    {
      "Sid": "SQSFullAccess",
      "Effect": "Allow",
      "Action": "sqs:*",
      "Resource": "*"
    },

    {
      "Sid": "S3FullAccess",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    },

    {
      "Sid": "SecretsManagerFullAccess",
      "Effect": "Allow",
      "Action": "secretsmanager:*",
      "Resource": "*"
    },

    {
      "Sid": "GetCafeDevDBSecret",
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "arn:aws:secretsmanager:us-east-1:*:secret:CafeDevDBSM*"
    },

    {
      "Sid": "RDSFullAccess",
      "Effect": "Allow",
      "Action": [
        "rds:*",
        "rds-data:*"
      ],
      "Resource": "*"
    },

    {
      "Sid": "APIGatewayFullAccess",
      "Effect": "Allow",
      "Action": "apigateway:*",
      "Resource": "*"
    },

    {
      "Sid": "CloudWatchFullAccess",
      "Effect": "Allow",
      "Action": [
        "logs:*",
        "cloudwatch:*"
      ],
      "Resource": "*"
    },

    {
      "Sid": "ElasticLoadBalancingFullAccess",
      "Effect": "Allow",
      "Action": "elasticloadbalancing:*",
      "Resource": "*"
    },

    {
      "Sid": "CloudFrontFullAccess",
      "Effect": "Allow",
      "Action": "cloudfront:*",
      "Resource": "*"
    }

  ]
}
```

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

### Policy Breakdown

Your merged policy contains 12 permission statements.

Services Included

| Service         | Permission             |
| --------------- | ---------------------- |
| Lambda          | Full + Invoke          |
| DynamoDB        | Full                   |
| SQS             | Full                   |
| S3              | Full                   |
| Secrets Manager | Full + Specific Secret |
| RDS             | Full                   |
| API Gateway     | Full                   |
| CloudWatch      | Full                   |
| ALB             | Full                   |
| CloudFront      | Full                   |

### AWS Policies vs Custom Policies

Important concept in AWS IAM.

AWS Managed Policies

These are created by AWS like:

AmazonS3FullAccess

AWSLambdaFullAccess

CloudWatchFullAccess

You are NOT using any AWS managed policies here.

Custom Policies

Your merged policy is a single custom policy.

| Type                     | Count  |
| ------------------------ | ------ |
| AWS Managed Policies     | **0**  |
| Custom Policies          | **1**  |
| Statements inside policy | **12** |

### What You Will Do In AWS

1️⃣ Open IAM Console

2️⃣ Go to Policies

3️⃣ Click Create Policy

4️⃣ Select JSON

5️⃣ Paste the policy

6️⃣ Click Next

7️⃣ Name: EC2-Cafe-Secrets-Role

8️⃣ Create Policy

9️⃣ Attach it to your EC2 IAM Role

### Important Security Note

This policy is very permissive (*).

Good for:

Labs

AWS practice

Development

Your Charlie Café project

But not recommended for production.

✅ If you want, I can also show you the professional AWS architecture IAM setup used by real companies for your system:

```
CloudFront
   ↓
S3 (Frontend)
   ↓
API Gateway
   ↓
Lambda
   ↓
Secrets Manager
   ↓
RDS MySQL
```

with proper IAM roles and least-privilege policies.

This will make your project look like a senior AWS engineer project.
---
### EC2-Cafe-Secrets-Role.json

> #### Latest Version: 1.0  for Github

```
{
  "Version": "2012-10-17",
  "Statement": [

    {
      "Sid": "AmazonEC2FullAccess",
      "Effect": "Allow",
      "Action": "ec2:*", 
      "Resource": "*"
    },

    {
      "Sid": "InvokeLambdaFunctions",
      "Effect": "Allow",
      "Action": "lambda:InvokeFunction",
      "Resource": "arn:aws:lambda:us-east-1:YOUR_ACCOUNT_ID:function:*"
    },

    {
      "Sid": "LambdaFullAccess",
      "Effect": "Allow",
      "Action": "lambda:*",
      "Resource": "*"
    },

    {
      "Sid": "DynamoDBFullAccess",
      "Effect": "Allow",
      "Action": "dynamodb:*",
      "Resource": "*"
    },

    {
      "Sid": "SQSFullAccess",
      "Effect": "Allow",
      "Action": "sqs:*",
      "Resource": "*"
    },

    {
      "Sid": "S3FullAccess",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    },

    {
      "Sid": "SecretsManagerFullAccess",
      "Effect": "Allow",
      "Action": "secretsmanager:*",
      "Resource": "*"
    },

    {
      "Sid": "GetCafeDevDBSecret",
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "arn:aws:secretsmanager:us-east-1:*:secret:CafeDevDBSM*"
    },

    {
      "Sid": "RDSFullAccess",
      "Effect": "Allow",
      "Action": [
        "rds:*",
        "rds-data:*"
      ],
      "Resource": "*"
    },

    {
      "Sid": "APIGatewayFullAccess",
      "Effect": "Allow",
      "Action": "apigateway:*",
      "Resource": "*"
    },

    {
      "Sid": "CloudWatchFullAccess",
      "Effect": "Allow",
      "Action": [
        "logs:*",
        "cloudwatch:*"
      ],
      "Resource": "*"
    },

    {
      "Sid": "ElasticLoadBalancingFullAccess",
      "Effect": "Allow",
      "Action": "elasticloadbalancing:*",
      "Resource": "*"
    },

    {
      "Sid": "CloudFrontFullAccess",
      "Effect": "Allow",
      "Action": "cloudfront:*",
      "Resource": "*"
    }

  ]
}
```


---