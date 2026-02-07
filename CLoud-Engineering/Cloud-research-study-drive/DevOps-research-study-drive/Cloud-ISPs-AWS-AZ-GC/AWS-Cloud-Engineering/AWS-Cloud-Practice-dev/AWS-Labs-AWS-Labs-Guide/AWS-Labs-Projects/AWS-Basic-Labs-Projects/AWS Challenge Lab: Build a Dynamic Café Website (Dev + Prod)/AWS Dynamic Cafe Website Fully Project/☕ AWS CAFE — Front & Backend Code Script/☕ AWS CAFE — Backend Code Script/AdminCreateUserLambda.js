export const handler = async (event) => {
    console.log("Event body:", event.body);

    const request = JSON.parse(event.body);
    const username = request.username;
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
