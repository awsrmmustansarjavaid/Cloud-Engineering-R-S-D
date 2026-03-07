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

---

