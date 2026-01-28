// ===============================================
// CHARLIE CAFE - Central Auth & API Endpoints
// Stores all API Gateway, Cognito, RDS, SecretManager, CloudFront info
// ===============================================

const AUTH_API = (() => {

    // -------------------------------
    // CONFIGURATION
    // -------------------------------
    const config = {
        apiGatewayBaseUrl: "https://bs0vgnth0f.execute-api.us-east-1.amazonaws.com/dev",
        paymentEndpoint: "/payment/create-intent",
        ordersEndpoint: "/orders",           // <- Added for orders.php
        orderStatusEndpoint: "/order-status", 
        cognito: {
            userPoolId: "us-east-1_xxxxxxxx",
            clientId: "xxxxxxxxxxxx",
            region: "us-east-1"
        },
        cloudFrontUrl: "https://dxxxxx.cloudfront.net/",
        secretManager: {
            rdsSecretName: "CafeDevDBSM"
        }
    };

    // -------------------------------
    // API CALLS
    // -------------------------------

    async function placeOrder(orderPayload) {
        const url = config.apiGatewayBaseUrl + config.ordersEndpoint;
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
    }

    async function createPaymentIntent(orderId, amount) {
        const url = config.apiGatewayBaseUrl + config.paymentEndpoint;
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
    }

    async function getOrderStatus(orderId) {
        const url = `${config.apiGatewayBaseUrl}${config.orderStatusEndpoint}?order_id=${orderId}`;
        try {
            const response = await fetch(url);
            return await response.json();
        } catch (err) {
            console.error("Error fetching order status:", err);
            throw err;
        }
    }

    return {
        config,
        placeOrder,
        createPaymentIntent,
        getOrderStatus
    };

})();
