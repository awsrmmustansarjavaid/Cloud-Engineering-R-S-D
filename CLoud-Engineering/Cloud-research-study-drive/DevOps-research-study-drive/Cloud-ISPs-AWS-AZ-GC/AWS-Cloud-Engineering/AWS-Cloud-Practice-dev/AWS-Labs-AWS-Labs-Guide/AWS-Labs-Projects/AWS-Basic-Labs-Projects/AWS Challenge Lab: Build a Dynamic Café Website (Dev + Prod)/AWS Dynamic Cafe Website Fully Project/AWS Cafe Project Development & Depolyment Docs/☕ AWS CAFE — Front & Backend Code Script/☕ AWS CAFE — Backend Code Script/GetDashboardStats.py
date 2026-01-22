// Import DB connection (same as your other Lambdas)
const mysql = require('mysql2/promise');

// Create DB connection config
const dbConfig = {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
};

exports.handler = async () => {

    // Connect to database
    const connection = await mysql.createConnection(dbConfig);

    // 1️⃣ Get ALL paid orders (for table view)
    const [paidOrders] = await connection.execute(`
        SELECT *
        FROM orders
        WHERE payment_status = 'PAID'
    `);

    // 2️⃣ Get daily revenue
    const [dailyRevenue] = await connection.execute(`
        SELECT DATE(payment_time) AS day,
               SUM(payment_amount) AS total
        FROM orders
        WHERE payment_status = 'PAID'
        GROUP BY day
    `);

    // 3️⃣ Get weekly revenue
    const [weeklyRevenue] = await connection.execute(`
        SELECT WEEK(payment_time) AS week,
               SUM(payment_amount) AS total
        FROM orders
        WHERE payment_status = 'PAID'
        GROUP BY week
    `);

    // Close DB connection
    await connection.end();

    // Return dashboard data
    return {
        statusCode: 200,
        body: JSON.stringify({
            paidOrders: paidOrders,
            dailyRevenue: dailyRevenue,
            weeklyRevenue: weeklyRevenue
        })
    };
};
