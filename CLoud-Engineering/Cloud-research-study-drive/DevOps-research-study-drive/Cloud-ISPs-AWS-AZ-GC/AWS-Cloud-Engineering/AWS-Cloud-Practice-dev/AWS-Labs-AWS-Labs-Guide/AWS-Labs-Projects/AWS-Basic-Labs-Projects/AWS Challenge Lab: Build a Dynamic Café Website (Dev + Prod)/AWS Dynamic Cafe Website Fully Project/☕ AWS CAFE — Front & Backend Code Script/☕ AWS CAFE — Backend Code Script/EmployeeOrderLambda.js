export const handler = async (event) => {
    console.log("Event body:", event.body);

    const request = JSON.parse(event.body);

    const response = {
        message: `Order ${request.order_id} created successfully`,
        order: request
    };

    return {
        statusCode: 200,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(response)
    };
};
