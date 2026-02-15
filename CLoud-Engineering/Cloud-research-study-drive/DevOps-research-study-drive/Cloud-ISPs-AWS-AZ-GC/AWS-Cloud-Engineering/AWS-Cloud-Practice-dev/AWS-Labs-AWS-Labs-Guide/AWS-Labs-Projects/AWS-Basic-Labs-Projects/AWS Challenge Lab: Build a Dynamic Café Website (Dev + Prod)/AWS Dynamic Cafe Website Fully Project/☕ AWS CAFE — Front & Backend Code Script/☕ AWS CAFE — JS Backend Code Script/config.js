/* =========================================================
   CONFIGURATION FILE
   Never hardcode values inside logic files
========================================================= */

export const CONFIG = {

    // AWS Region
    REGION: "us-east-1",

    // Cognito
    USER_POOL_ID: "us-east-1_oeMWJar3T",
    CLIENT_ID: "42haggs0jctmq5rnaajfi3hmqu",
    COGNITO_DOMAIN: "us-east-1oemwjar3t.auth.us-east-1.amazoncognito.com",

    // API Gateway (Single prod stage)
    API_BASE: "https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/prod",

    // CloudFront
    CLOUDFRONT_BASE: "https://d163j9zwndcxgl.cloudfront.net"
};
