exports.handler = async (event) => {

    // Parse Stripe event
    const stripeEvent = JSON.parse(event.body);

    // Only process successful payments
    if (stripeEvent.type === 'payment_intent.succeeded') {

        const paymentIntent = stripeEvent.data.object;
        const orderId = paymentIntent.metadata.order_id;

        // Update DB → mark order PAID
        await updateOrderToPaid(orderId, paymentIntent.id);
    }

    return {
        statusCode: 200,
        body: 'Webhook processed'
    };
};
