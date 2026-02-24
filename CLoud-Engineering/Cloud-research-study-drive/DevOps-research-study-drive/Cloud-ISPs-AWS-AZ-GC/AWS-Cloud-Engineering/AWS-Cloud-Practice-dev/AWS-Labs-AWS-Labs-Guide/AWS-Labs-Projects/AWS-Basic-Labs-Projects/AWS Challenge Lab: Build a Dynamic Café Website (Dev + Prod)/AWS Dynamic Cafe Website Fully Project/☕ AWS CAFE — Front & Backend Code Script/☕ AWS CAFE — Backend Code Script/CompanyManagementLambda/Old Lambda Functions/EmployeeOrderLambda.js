// Lambda: EmployeeOrderLambda
// Runtime: Node.js 18.x

export const handler = async (event) => {
  // If invoked via API Gateway, event.body will be a string
  // If invoked directly (Lambda test), event is already the object
  let request;

  try {
    if (event.body) {
      // Parse string body from API Gateway
      request = JSON.parse(event.body);
    } else {
      // Direct invocation (Lambda console test)
      request = event;
    }
  } catch (err) {
    console.error("Failed to parse event body:", event.body);
    return {
      statusCode: 400,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ error: "Invalid JSON input" }),
    };
  }

  console.log("Order request:", request);

  // Construct response
  const response = {
    message: `Order ${request.order_id} created successfully`,
    order: request,
  };

  return {
    statusCode: 200,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(response),
  };
};
