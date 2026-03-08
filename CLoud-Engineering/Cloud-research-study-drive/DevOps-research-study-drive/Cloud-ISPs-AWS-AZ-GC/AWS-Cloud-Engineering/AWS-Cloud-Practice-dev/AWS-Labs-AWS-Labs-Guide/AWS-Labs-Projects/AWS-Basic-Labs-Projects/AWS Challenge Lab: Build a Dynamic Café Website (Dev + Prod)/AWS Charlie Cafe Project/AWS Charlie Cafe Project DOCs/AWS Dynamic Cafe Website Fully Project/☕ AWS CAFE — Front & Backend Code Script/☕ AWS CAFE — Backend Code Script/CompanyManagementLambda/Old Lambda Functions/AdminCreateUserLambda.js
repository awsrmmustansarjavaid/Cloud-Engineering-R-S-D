export const handler = async (event) => {
    console.log("Event:", event);

    // Safely parse body
    const request = event.body ? JSON.parse(event.body) : {};

    const username = request.username || "unknown";
    const role = request.role || "employee";

    const response = {
        message: `User ${username} created with role ${role}`,
        username,
        role
    };

    return {
        statusCode: 200,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(response)
    };
};
