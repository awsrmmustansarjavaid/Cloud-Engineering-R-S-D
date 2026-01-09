# AWS Cafe

## AWS Cafe Common Issues & Troubleshooting

### PHASE 1 — Cafe-Order

| Issue                              | Solution                                                                |
| ---------------------------------- | ----------------------------------------------------------------------- |
| CORS error in browser              | Ensure CORS is enabled for `/orders` with POST method                   |
| 403 Forbidden / Lambda not invoked | Check Lambda permissions (API Gateway needs `lambda:InvokeFunction`)    |
| 500 Internal Server Error          | Check Lambda CloudWatch logs for errors, confirm secrets are accessible |
| Orders not saving                  | Verify DB credentials in Secrets Manager and Lambda function            |


## ✅ FINAL CHECKLIST

* [ ] Dev works
* [ ] Secrets secure
* [ ] Lambda inserts orders
* [ ] API Gateway reachable
* [ ] Prod mirrors Dev

---

### PHASE 2 — Cafe-Order

