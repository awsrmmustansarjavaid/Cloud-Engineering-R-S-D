# Charlie Cafe -- AdminMarkPaid

### 1️⃣ Features & Roles - Lambda Function — AdminMarkPaidLambda

#### Purpose:

- Exclusive for admin users.

- Marks CASH orders as PAID in DynamoDB.

#### Key Features:

- Accepts POST requests with a JSON body:

```
{ "order_id": "ORD-123456" }
```

- Connects to DynamoDB table CafeOrders.

- Updates the payment_status field to "PAID" for the given order_id.

- Returns a JSON response:

```
{
  "success": true,
  "message": "Order marked as PAID"
}
```

- Handles errors gracefully with 500 status and error message.

- CORS enabled to allow frontend to call API.

### Frontend — admin-orders.html

#### Purpose:

- Admin dashboard for viewing all orders, marking CASH orders as paid, and printing orders.

#### Key Features:

Dashboard Table

- Displays orders with:

    - Order ID

    - Table number

    - Item name

    - Quantity

    - Payment method (CASH / CARD)

    - Status (PAID / PENDING)

    - Action buttons

Mark Paid Button

- Visible only for CASH orders with status PENDING.

- Calls markAsPaid() function → triggers Lambda via CHARLIE_API.public.updateOrder.

Print Buttons

- Print single order or all orders.

Auto-refresh

- Table reloads every 30 seconds.

Admin protection

- CHARLIE_AUTH.protectPage() and CHARLIE_AUTH.requireAdmin() ensure only authorized admins can access.

### 2️⃣ Integration & Data Flow

Here’s the end-to-end workflow:

Frontend Load Orders

- loadOrders() → Calls CHARLIE_API.public.adminDashboard()

- API returns orders list (from DynamoDB or RDS, depending on backend logic).

- Table rows dynamically generated with buttons.

Admin Marks an Order Paid

- Click Mark Paid → triggers markAsPaid(button)

- markAsPaid() calls:

```
CHARLIE_API.public.updateOrder({ order_id: orderId })
```

→ sends POST request to AdminMarkPaidLambda via /admin/mark-paid endpoint.

- Lambda receives order_id → updates CafeOrders DynamoDB table → responds with success.

- Frontend reloads table via loadOrders() to reflect PAID status.

Print Orders

- Pulls order info from DOM table and opens printable view (local, no backend call).

### 3️⃣ Backend & Frontend Alignment

#### ✅ Checks:

| Feature                  | Lambda                   | Frontend                                      | Status                |
| ------------------------ | ------------------------ | --------------------------------------------- | --------------------- |
| Mark CASH order as PAID  | ✅ updates DynamoDB       | ✅ button visible only for CASH pending orders | ✅ aligned             |
| Success/Failure response | ✅ returns JSON           | ✅ handles `success` and alerts admin          | ✅ aligned             |
| CORS                     | ✅ enabled                | ✅ required for API call                       | ✅ aligned             |
| Auto-refresh             | N/A                      | ✅ refresh table every 30s                     | ✅ works independently |
| Admin protection         | N/A (API is Lambda-only) | ✅ page protected via CHARLIE_AUTH             | ✅ aligned             |


### Conclusion:

- Lambda and frontend align perfectly.

- The updateOrder call in frontend should point to the deployed POST endpoint:

```
https://xxxx.execute-api.us-east-1.amazonaws.com/dev/admin/mark-paid
```

### 4️⃣ Architecture & Data Flow Diagram

Here’s a visual representation of how the flow works:

```
 ┌─────────────┐       GET Orders      ┌──────────────┐
 │             │--------------------->│              │
 │ admin-orders│                       │  CHARLIE_API│
 │ .html page  │<---------------------│ public.admin │
 │             │   JSON orders         │ Dashboard()  │
 └─────────────┘                       └──────────────┘
       │                                      │
       │Click Mark Paid                        │
       │                                       
       ▼
 ┌───────────────────────────┐
 │ markAsPaid(button)        │
 │ - confirm                  │
 │ - button UI feedback       │
 │ - calls updateOrder()      │
 └─────────────┬─────────────┘
               │
               ▼ POST /admin/mark-paid
 ┌───────────────────────────┐
 │ AdminMarkPaidLambda       │
 │ - Parses order_id         │
 │ - Updates DynamoDB        │
 │   CafeOrders.payment_status
 │ - Returns JSON success    │
 └─────────────┬─────────────┘
               │
               ▼
        JSON response
               │
               ▼
 ┌───────────────────────────┐
 │ admin-orders.html          │
 │ - Alert success            │
 │ - Reload orders table      │
 └───────────────────────────┘
 ```

#### Data Flow Notes:

- Orders data is read from DynamoDB or backend via adminDashboard().

- Mark Paid updates only payment_status in DynamoDB.

- Frontend reflects changes on table reload.

### ✅ Key Takeaways

- AdminMarkPaidLambda + /admin/mark-paid endpoint is fully compatible with admin-orders.html.

- CASH order marking, UI feedback, and auto-refresh are correctly integrated.

- The data flow is simple, secure, and aligned for admin usage.

- All actions are idempotent — clicking Mark Paid again will just overwrite the status to PAID.

---
