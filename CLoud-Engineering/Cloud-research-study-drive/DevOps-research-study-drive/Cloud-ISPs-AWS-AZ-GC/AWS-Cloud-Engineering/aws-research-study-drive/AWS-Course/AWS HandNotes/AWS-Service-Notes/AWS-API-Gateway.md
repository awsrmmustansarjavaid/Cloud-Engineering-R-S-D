# AWS API Gateway: Beginner to Advanced Guide

> **Author:** AWS Cloud Trainer  
> **Audience:** Beginner → Advanced AWS Cloud Engineers  
> **Goal:** Learn AWS API Gateway from scratch, master it for professional cloud engineering.

---

## 📚 Table of Contents

1. [Introduction](#introduction)
2. [Core Concepts](#core-concepts)
3. [Types of API Gateway](#types-of-api-gateway)
4. [Key Features](#key-features)
5. [Setting Up Your First API](#setting-up-your-first-api)
6. [Method Request & Integration](#method-request--integration)
7. [Stages and Deployment](#stages-and-deployment)
8. [Security & Authorization](#security--authorization)
9. [Monitoring & Logging](#monitoring--logging)
10. [Advanced Features](#advanced-features)
11. [Best Practices](#best-practices)
12. [Common Issues & Troubleshooting](#common-issues--troubleshooting)
13. [Hands-On Labs](#hands-on-labs)
14. [References](#references)

---

## 1. Introduction

AWS API Gateway is a **fully managed service** that allows you to create, publish, maintain, monitor, and secure **RESTful, HTTP, and WebSocket APIs** at any scale.  
It acts as a "front door" for applications to access data, business logic, or functionality from your backend services such as **AWS Lambda, EC2, or other AWS services**.

**Use cases:**

- Build serverless backends using Lambda
- Proxy requests to existing services
- Enable microservices architecture
- Mobile and web app integration

---

## 2. Core Concepts

| Concept | Description |
|---------|-------------|
| API | A set of rules to allow applications to communicate. |
| REST API | Representational State Transfer API, the most common API type. |
| HTTP API | Lightweight alternative to REST APIs, lower cost. |
| WebSocket API | Real-time, two-way communication between client and server. |
| Resource | A logical endpoint in the API (e.g., `/users`). |
| Method | HTTP operation allowed on a resource (`GET`, `POST`, `PUT`, `DELETE`). |
| Integration | Backend service connected to API Gateway (Lambda, HTTP endpoint, Mock, etc.). |
| Stage | Represents a deployment environment (`dev`, `test`, `prod`). |
| Mapping Template | Transforms client request data into backend-compatible format. |
| Usage Plan | Limits API usage per client key for throttling and quotas. |

---

## 3. Types of API Gateway

1. **REST API**
   - Fully-featured
   - Supports request/response transformation
   - Caching, throttling, authorization

2. **HTTP API**
   - Lower latency and cost
   - Simple setup
   - Supports JWT authorizers (Cognito, OIDC)

3. **WebSocket API**
   - Real-time communication
   - Maintains persistent connections
   - Useful for chat apps, gaming, live dashboards

---

## 4. Key Features

- **Throttling & Quotas:** Control the request rate to prevent abuse.
- **Authorization:** IAM, Cognito, Lambda authorizers.
- **Caching:** Reduce backend load and improve latency.
- **Request/Response Transformation:** Map incoming requests to backend format.
- **Custom Domain Names:** Use your own domain for APIs.
- **Monitoring & Logging:** CloudWatch metrics, logs, and X-Ray tracing.
- **SDK Generation:** Automatically generate SDKs for mobile/web apps.

---

## 5. Setting Up Your First API

### Step 1: Create REST API
1. Go to AWS Management Console → API Gateway → **Create API** → REST API.
2. Choose **New API** → Enter `API Name` and description → Create.

### Step 2: Create Resource
1. In your API, click **Actions → Create Resource**.
2. Enter Resource Name (e.g., `users`) → Create Resource.

### Step 3: Create Method
1. Select your resource → Actions → Create Method → Choose `GET`.
2. Select **Lambda Function** as Integration Type → Choose your Lambda → Save.
3. Allow API Gateway to invoke Lambda.

### Step 4: Deploy API
1. Actions → Deploy API.
2. Choose **Stage** → e.g., `dev` → Deploy.
3. Note the **Invoke URL**.

---

## 6. Method Request & Integration

**Method Request:** Defines client request validation (parameters, headers).  
**Integration Request:** Connects API method to backend service.  
**Mapping Templates:** Transform JSON/XML to the format backend expects.

**Example:** Transform client JSON `{ "name": "John" }` to `{ "userName": "John" }`.

---

## 7. Stages and Deployment

- **Stage:** Represents a lifecycle stage of your API (`dev`, `prod`).
- **Stage Variables:** Key-value pairs to pass environment-specific configs.
- **Deployment Best Practices:**
  - Use separate stages for dev/test/prod.
  - Track deployments using CloudFormation or Terraform.

---

## 8. Security & Authorization

| Method | Description |
|--------|-------------|
| IAM | Control access using AWS IAM policies. |
| Cognito | Authenticate users using Amazon Cognito User Pools. |
| Lambda Authorizer | Custom logic to authorize requests. |
| API Keys | Limit access for specific clients. |
| CORS | Enable cross-origin requests for web clients. |

**Example: Enable CORS**
- Select Resource → Actions → Enable CORS → Save.

---

## 9. Monitoring & Logging

- **CloudWatch Metrics:** Count, latency, error rates.
- **CloudWatch Logs:** Detailed request/response logging.
- **X-Ray Tracing:** Visualize request flow across AWS services.

**Enable Logging:**
1. Select Stage → Logs/Tracing → Enable CloudWatch Logs.
2. Define Log Level: `INFO` or `ERROR`.

---

## 10. Advanced Features

1. **Custom Domain & SSL**
   - Route custom domain to API Gateway.
2. **Request/Response Mapping**
   - Transform payloads using Velocity Template Language (VTL).
3. **Rate Limiting & Throttling**
   - Protect API from overuse.
4. **Lambda Proxy Integration**
   - Sends full request to Lambda for flexible handling.
5. **Integration with Other AWS Services**
   - S3, DynamoDB, Step Functions, Kinesis, etc.

---

## 11. Best Practices

- Use **HTTP APIs** for simple, low-latency APIs.
- Separate **dev/test/prod stages**.
- Enable **CloudWatch logging and X-Ray tracing**.
- Use **Cognito or IAM** for secure access.
- Implement **throttling and caching** for efficiency.
- Version APIs for backward compatibility.

---

## 12. Common Issues & Troubleshooting

| Issue | Solution |
|-------|---------|
| `403 Forbidden` | Check IAM permissions and authorizers. |
| `500 Internal Server Error` | Check Lambda logs in CloudWatch. |
| `CORS error` | Enable CORS for your resource/method. |
| Slow response | Enable caching and optimize backend. |
| Deployment not reflecting | Redeploy API after changes. |

---

## 13. Hands-On Labs

### Lab 1: Build REST API with Lambda
1. Create Lambda function `HelloWorld`.
2. Create REST API `/hello`.
3. Integrate GET method with Lambda.
4. Deploy to `dev` stage.
5. Test using browser or Postman.

### Lab 2: Enable Authorization
1. Create Cognito User Pool.
2. Configure API Gateway method with Cognito Authorizer.
3. Test API with authenticated user token.

### Lab 3: Custom Domain & SSL
1. Create a custom domain in API Gateway.
2. Map stage to domain.
3. Test API using custom URL.

---

## 14. References

- [AWS API Gateway Official Docs](https://docs.aws.amazon.com/apigateway/latest/developerguide/welcome.html)  
- [AWS Lambda Integration Guide](https://docs.aws.amazon.com/apigateway/latest/developerguide/getting-started-with-lambda-integration.html)  
- [API Gateway Best Practices](https://aws.amazon.com/blogs/compute/best-practices-for-using-api-gateway/)

---

> ✅ This guide covers **API Gateway from basic to advanced**, including concepts, setup, security, monitoring, and best practices.
