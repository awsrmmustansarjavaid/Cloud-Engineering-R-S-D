/* =========================================================
   CHARLIE CAFE — GLOBAL CONFIGURATION
   ---------------------------------------------------------
   ✔ AWS Region
   ✔ Cognito Config
   ✔ API Gateway Base (PROD)
   ✔ CloudFront Base
========================================================= */

window.CHARLIE_CONFIG = {

    /* ===============================
       🌍 AWS REGION
    =============================== */
    REGION: "us-east-1",

    /* ===============================
       🔐 AWS Cognito Configuration
    =============================== */
    USER_POOL_ID: "us-east-1_oeMWJar3T",
    CLIENT_ID: "42haggs0jctmq5rnaajfi3hmqu",
    COGNITO_DOMAIN: "us-east-1oemwjar3t.auth.us-east-1.amazoncognito.com",

    /* ===============================
       🚀 API Gateway (PRODUCTION)
    =============================== */
    API_BASE: "https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/prod",

    /* ===============================
       ☁ CloudFront Distribution
    =============================== */
    CLOUDFRONT_BASE: "https://d163j9zwndcxgl.cloudfront.net"
};
