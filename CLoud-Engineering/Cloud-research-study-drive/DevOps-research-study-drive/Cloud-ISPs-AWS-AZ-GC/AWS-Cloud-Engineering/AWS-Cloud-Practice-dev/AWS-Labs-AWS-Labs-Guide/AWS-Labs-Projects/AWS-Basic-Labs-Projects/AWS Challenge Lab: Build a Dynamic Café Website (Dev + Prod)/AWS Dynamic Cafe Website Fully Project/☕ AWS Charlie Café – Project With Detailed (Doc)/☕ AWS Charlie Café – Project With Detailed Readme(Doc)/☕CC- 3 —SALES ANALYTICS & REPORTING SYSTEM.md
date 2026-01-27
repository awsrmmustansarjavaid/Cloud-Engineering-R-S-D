# ☕ CAFE LAB – ADVANCED SALES ANALYTICS & REPORTING SYSTEM
> **(Using Existing Order Status System)**


# SECTION 1️⃣ SALES ANALYTICS & REPORTING SYSTEM

## PHASE 1️⃣ – DYNAMODB DESIGN (NO NEW TABLE)

> **⚠️ This phase is mandatory before Lambda works.**

**Goal of this phase:**

Ensure your existing DynamoDB table structure, index, and query logic are 100% correct and testable before analytics logic is added.

### 1️⃣ VERIFY EXISTING ORDERS TABLE (REQUIRED STRUCTURE)

#### 2️⃣ Confirm Table Name: 

```        
CafeOrders
```

#### ❌ If table name is:

- cafeorders

- cafe_orders

- Orders

👉 STOP

👉 Either rename Lambda code OR recreate table

👉 Do NOT rename the table randomly

#### 3️⃣ Verify Table Keys (CRITICAL)

#### Why this matters

Analytics requires GSI, not main keys.

#### ⚠️ DO NOT ADD A SORT KEY TO MAIN TABLE

Adding one breaks:

- Existing writes

- Existing Lambdas

- API Gateway

👉 Analytics filtering happens via GSI, not main table.

### STEP 3️⃣ — UNDERSTAND THE “DATA CONTRACT”

This is the MOST IMPORTANT CONCEPT you were missing.

❓ What is a Data Contract?

It means:

“Analytics Lambda EXPECTS these attributes to already exist in every COMPLETED order”

- Lambda does not create them

- Lambda does not fix them

- Lambda only reads

