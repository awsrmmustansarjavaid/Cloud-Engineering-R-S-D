# ☕ CAFE LAB – SALES ANALYTICS & REPORTING SYSTEM
> **(Using Existing Order Status System)**

### 🎯 WHAT YOU ARE BUILDING (CLEAR SCOPE)

You will build ONE analytics system that:

✔ Reads data from existing Order Status DynamoDB table

✔ Calculates Today / Weekly / Monthly Sales

✔ Calculates Cost, Profit, Loss

✔ Displays professional Bootstrap analytics dashboard

✔ Generates PDF reports (custom date OR month-end)

✔ Supports manual PDF download

✔ Supports monthly auto-PDF generation

✔ Uses existing API Gateway + Lambda (minimal additions)

### 🧱 ARCHITECTURE (FINAL)

```
Frontend (Bootstrap Analytics Page)
        |
        |--- GET /analytics
        |--- POST /report/pdf
        |
API Gateway
        |
        |--- Analytics Lambda
        |--- PDF Lambda
        |
DynamoDB (Existing Orders Table)
        |
EventBridge (Monthly Trigger)
```

## PHASE 1 DYNAMODB DESIGN 

### PART 1️⃣ – DYNAMODB DESIGN (NO NEW TABLE)

#### ✅ Existing Orders Table (REQUIRED STRUCTURE)

Table Name: CafeOrders

Partition Key (PK):