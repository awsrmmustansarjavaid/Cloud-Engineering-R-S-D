

## Central UNIVERSAL Backend RBAC

### ✅ STEP-BY-STEP CONFIGURATION GUIDE

### 1️⃣ Confirm Cognito Groups (ONCE)

#### You already did this, but verify:

- Cognito User Pool → Groups:

    - admin

    - employee

- Users:

    - admin user → member of admin

    - employee user → member of employee

**👉 Group names must match permissions.json exactly**
> **(lowercase = best practice ✅)**

### 2️⃣ Create permissions.json (YOU DID THIS)

Example (keep it simple first):

```
[
  {
    "path": "/order-status",
    "roles": ["admin"]
  },
  {
    "path": "/attendance",
    "roles": ["admin", "employee"]
  },
  {
    "path": "/hr",
    "roles": ["admin"]
  }
]
```

#### 🔐 Rule:

- If path matches → check roles

- If no rule → DENY by default (secure)

### 3️⃣ Decide HOW rbac.py is used (IMPORTANT)

You have 2 valid options.

✅ OPTION A (RECOMMENDED): Lambda Layer

❌ OPTION B: Copy file into each Lambda (temporary)

We’ll do Option A (professional + clean).

### 4️⃣ Create Lambda Layer (RBAC)

#### 📁 Local folder structure (VERY IMPORTANT)

```
cafe-rbac-layer/
└── python/
    ├── rbac.py
    └── permissions.json
```

**⚠️ Folder name MUST be python/**
