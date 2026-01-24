// Import AWS SDK (already available in Lambda)
const AWS = require('aws-sdk');

// Import Stripe SDK
const Stripe = require('stripe');

// Create Secrets Manager client
const secretsManager = new AWS.SecretsManager();

/**
 * Get Stripe client securely from Secrets Manager
 */
async function getStripeClient() {

    // Fetch secret value
    const secretValue = await secretsManager.getSecretValue({
        SecretId: 'stripe/charlie-cafe'
    }).promise();

    // Parse JSON secret
    const secret = JSON.parse(secretValue.SecretString);

    // Initialize Stripe with secret key
    return new Stripe(secret.STRIPE_SECRET_KEY);
}

exports.handler = async (event) => {

    // Parse request body from API Gateway
    const body = JSON.parse(event.body);

    // Extract values
    const orderId = body.orderId;
    const amount = body.amount; // MUST be in cents

    // Initialize Stripe
    const stripe = await getStripeClient();

    // Create payment intent in Stripe
    const paymentIntent = await stripe.paymentIntents.create({
        amount: amount,
        currency: 'usd',

        // Store order ID inside Stripe for reference
        metadata: {
            order_id: orderId
        }
    });

    // Send client secret back to frontend
    return {
        statusCode: 200,
        body: JSON.stringify({
            clientSecret: paymentIntent.client_secret,
            paymentIntentId: paymentIntent.id
        })
    };
};