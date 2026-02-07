// AdminDashboardLambda — ES Module Version
export const handler = async (event) => {
    console.log("Event:", event);

    const data = {
        totalEmployees: 25,
        totalOrdersToday: 42,
        revenueToday: 1234.56
    };

    return {
        statusCode: 200,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data)
    };
};