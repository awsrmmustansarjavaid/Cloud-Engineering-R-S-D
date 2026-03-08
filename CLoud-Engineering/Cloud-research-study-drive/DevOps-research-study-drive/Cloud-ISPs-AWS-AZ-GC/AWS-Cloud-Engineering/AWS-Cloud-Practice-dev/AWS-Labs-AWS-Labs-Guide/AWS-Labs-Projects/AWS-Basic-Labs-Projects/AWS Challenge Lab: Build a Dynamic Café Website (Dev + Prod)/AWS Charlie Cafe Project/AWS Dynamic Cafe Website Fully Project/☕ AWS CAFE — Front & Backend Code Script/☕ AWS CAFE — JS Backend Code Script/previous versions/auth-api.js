// ===============================================
// CHARLIE CAFE - Central Auth & API Configuration
// ===============================================

const AUTH_API = (() => {

    // ================================
    // 1️⃣ RDS & AWS Secrets Manager
    // ================================
    // This section stores info about your RDS credentials stored in Secrets Manager.
    // Use these to fetch DB credentials securely if needed.
    const rds = {
        secretManagerName: "CafeDevDBSM",       // Secret name in AWS Secrets Manager
        region: "us-east-1",
        getCredentials: async function() {
            try {
                // Example: fetch secret using AWS SDK
                const AWS = window.AWS; // If using in browser with Cognito Auth
                AWS.config.region = this.region;
                const client = new AWS.SecretsManager();
                const data = await client.getSecretValue({ SecretId: this.secretManagerName }).promise();
                return JSON.parse(data.SecretString);
            } catch (err) {
                console.error("Error fetching RDS secret:", err);
                throw err;
            }
        }
    };

    // ================================
    // 2️⃣ API Gateway REST APIs
    // ================================
    // Centralize all API endpoints for PHP pages and front-end calls
    const apiGateway = {
        baseUrl: "https://bs0vgnth0f.execute-api.us-east-1.amazonaws.com/dev/orders",

        // Orders API (used by orders.php)
        ordersEndpoint: "/orders",
        async placeOrder(orderPayload) {
            const url = this.baseUrl + this.ordersEndpoint;
            try {
                const response = await fetch(url, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify(orderPayload)
                });
                return await response.json();
            } catch (err) {
                console.error("Error placing order:", err);
                throw err;
            }
        },

        // Payment endpoint (used by Stripe)
        paymentEndpoint: "/payment/create-intent",
        async createPaymentIntent(orderId, amount) {
            const url = this.baseUrl + this.paymentEndpoint;
            try {
                const response = await fetch(url, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ orderId, amount })
                });
                return await response.json();
            } catch (err) {
                console.error("Error creating payment intent:", err);
                throw err;
            }
        },

        // Order Status endpoint
        orderStatusEndpoint: "/order-status",
        async getOrderStatus(orderId) {
            const url = `${this.baseUrl}${this.orderStatusEndpoint}?order_id=${orderId}`;
            try {
                const response = await fetch(url);
                return await response.json();
            } catch (err) {
                console.error("Error fetching order status:", err);
                throw err;
            }
        }
    };

    // ================================
    // 3️⃣ Cognito Authentication
    // ================================
    // This section stores AWS Cognito configuration
    const cognito = {
        userPoolId: "us-east-1_xxxxxxxx",
        clientId: "xxxxxxxxxxxx",
        region: "us-east-1",
        // Example method: get current session (frontend JS)
        getSession: async function() {
            try {
                const poolData = {
                    UserPoolId: this.userPoolId,
                    ClientId: this.clientId
                };
                const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);
                const cognitoUser = userPool.getCurrentUser();
                if (cognitoUser) {
                    return new Promise((resolve, reject) => {
                        cognitoUser.getSession((err, session) => {
                            if (err) reject(err);
                            else resolve(session);
                        });
                    });
                } else {
                    return null;
                }
            } catch (err) {
                console.error("Error fetching Cognito session:", err);
                throw err;
            }
        }
    };

    // ================================
    // 4️⃣ CloudFront Configuration
    // ================================
    // Store URLs for assets or distribution endpoints
    const cloudFront = {
        baseUrl: "https://dxxxxx.cloudfront.net/",
        // Example: get full URL for an asset
        getAssetUrl: function(assetPath) {
            return this.baseUrl + assetPath;
        }
    };

    // ================================
    // RETURN MODULE
    // ================================
    return {
        rds,
        apiGateway,
        cognito,
        cloudFront
    };

})();