export const handler = async (event) => {
    console.log("Event:", event);

    const employeeId = event.queryStringParameters?.employee_id || "all";

    const orders = [
        { order_id: "O-101", employee: "alice", total: 23.5 },
        { order_id: "O-102", employee: "bob", total: 12.0 }
    ];

    const filteredOrders = employeeId === "all"
        ? orders
        : orders.filter(o => o.employee === employeeId);

    return {
        statusCode: 200,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(filteredOrders)
    };
};
