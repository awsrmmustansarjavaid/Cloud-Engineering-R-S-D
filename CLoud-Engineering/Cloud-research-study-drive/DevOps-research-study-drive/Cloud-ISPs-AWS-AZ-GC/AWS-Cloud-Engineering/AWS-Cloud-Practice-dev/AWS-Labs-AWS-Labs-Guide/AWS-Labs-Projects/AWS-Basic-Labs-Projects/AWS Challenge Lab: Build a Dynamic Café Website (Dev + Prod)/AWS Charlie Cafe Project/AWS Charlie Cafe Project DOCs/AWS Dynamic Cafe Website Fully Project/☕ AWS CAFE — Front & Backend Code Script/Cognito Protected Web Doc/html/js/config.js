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
       🔑 Secrets Manager Name for RDS
    =============================== */
    rdsSecretName: "CafeDevDBSM",   // Must match your Secrets Manager secret name

    /* ===============================
       🔐 AWS Cognito Configuration
    =============================== */
    USER_POOL_ID: "us-east-1_qPVmxxxR2",
    CLIENT_ID: "7c5793cnvnbl110ljthmdiohch",
    COGNITO_DOMAIN: "https://us-east-1qpvmxxxr2.auth.us-east-1.amazoncognito.com",

    /* ===============================
       🚀 API Gateway (PRODUCTION)
    =============================== */
    API_BASE: "https://cdnky6qicd.execute-api.us-east-1.amazonaws.com/prod",

    /* ===============================
       ☁ CloudFront Distribution
    =============================== */
    CLOUDFRONT_BASE: "https://d2xb54di3chfgj.cloudfront.net"
};
