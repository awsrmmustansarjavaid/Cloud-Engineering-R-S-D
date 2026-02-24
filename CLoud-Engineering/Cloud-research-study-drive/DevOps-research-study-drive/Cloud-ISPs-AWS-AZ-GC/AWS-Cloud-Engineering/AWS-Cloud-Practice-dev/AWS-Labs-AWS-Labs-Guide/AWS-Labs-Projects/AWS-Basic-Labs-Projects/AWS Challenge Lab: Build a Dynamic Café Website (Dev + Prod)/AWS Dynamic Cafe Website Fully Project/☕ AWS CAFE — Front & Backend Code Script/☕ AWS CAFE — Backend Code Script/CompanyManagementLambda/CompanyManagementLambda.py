// CompanyManagementLambda
// Runtime: Node.js 18.x
// Handles:
// GET    /admin/dashboard
// POST   /admin/create-user
// GET    /employee/orders
// POST   /employee/order

export const handler = async (event) => {
  console.log("Incoming Event:", JSON.stringify(event));

  const method = event.httpMethod;
  const path = event.resource || event.rawPath;

  try {

    // ==============================
    // 1️⃣ ADMIN DASHBOARD
    // GET /admin/dashboard
    // ==============================
    if (method === "GET" && path === "/admin/dashboard") {
      const data = {
        totalEmployees: 25,
        totalOrdersToday: 42,
        revenueToday: 1234.56
      };

      return response(200, data);
    }

    // ==============================
    // 2️⃣ ADMIN CREATE USER
    // POST /admin/create-user
    // ==============================
    if (method === "POST" && path === "/admin/create-user") {

      let request = parseBody(event);

      const username = request.username || "unknown";
      const role = request.role || "employee";

      return response(200, {
        message: `User ${username} created with role ${role}`,
        username,
        role
      });
    }

    // ==============================
    // 3️⃣ EMPLOYEE ORDERS
    // GET /employee/orders
    // ==============================
    if (method === "GET" && path === "/employee/orders") {

      const employeeId =
        event.queryStringParameters?.employee_id || "all";

      const orders = [
        { order_id: "O-101", employee: "alice", total: 23.5 },
        { order_id: "O-102", employee: "bob", total: 12.0 }
      ];

      const filteredOrders =
        employeeId === "all"
          ? orders
          : orders.filter(o => o.employee === employeeId);

      return response(200, filteredOrders);
    }

    // ==============================
    // 4️⃣ CREATE EMPLOYEE ORDER
    // POST /employee/order
    // ==============================
    if (method === "POST" && path === "/employee/order") {

      let request = parseBody(event);

      return response(200, {
        message: `Order ${request.order_id} created successfully`,
        order: request
      });
    }

    // ==============================
    // ❌ ROUTE NOT FOUND
    // ==============================
    return response(404, { error: "Route not found" });

  } catch (error) {
    console.error("Error:", error);
    return response(500, { error: "Internal Server Error" });
  }
};


// ==============================
// Helper: Standard Response
// ==============================
function response(statusCode, body) {
  return {
    statusCode,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body)
  };
}


// ==============================
// Helper: Safe Body Parser
// ==============================
function parseBody(event) {
  try {
    return event.body ? JSON.parse(event.body) : {};
  } catch {
    throw new Error("Invalid JSON input");
  }
}