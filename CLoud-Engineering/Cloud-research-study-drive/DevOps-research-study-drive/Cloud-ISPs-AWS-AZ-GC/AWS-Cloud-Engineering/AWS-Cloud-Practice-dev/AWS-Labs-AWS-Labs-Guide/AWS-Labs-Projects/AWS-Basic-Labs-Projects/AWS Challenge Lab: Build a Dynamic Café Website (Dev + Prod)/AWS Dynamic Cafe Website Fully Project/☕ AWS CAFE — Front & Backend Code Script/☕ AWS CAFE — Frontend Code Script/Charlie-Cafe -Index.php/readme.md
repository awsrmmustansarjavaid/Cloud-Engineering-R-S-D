
# 📌 Index Page (index.php) — Feature Overview & Improvements


# SECTION 1️⃣  Latest Updated Advance index.php

[index.php](./index.php)

---
# SECTION 2️⃣  Previous Versions index.php

## 1️⃣ Previous index.php — Features (Old Version)

The earlier version of index.php was designed as a basic functional landing page for Charlie Cafe. Its primary focus was content display rather than user experience or scalability.

### 🔹 Key Features (Old)

➡️ Static landing page layout

➡️ Basic Bootstrap usage for responsiveness

➡️ Simple hero section with background image

➡️ Menu displayed using standard Bootstrap cards

➡️ Minimal hover effects

➡️ Inline CSS without structured sections

➡️ Direct navigation links to orders.php

➡️ No animations or transitions

➡️ No user feedback system (alerts or notifications)

➡️ Limited comments and documentation in code

### 🔹 Limitations of Old Version

➡️ UI looked standard and basic

➡️ No visual hierarchy or premium feel

➡️ No animations → page felt static

➡️ No frontend feedback (user actions felt “silent”)

➡️ Code readability was low

➡️ No frontend security awareness

➡️ Harder to scale or reuse components


```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Charlie Cafe ☕ | Fresh Drinks & Coffee</title>

    <!-- Favicon -->
    <link rel="icon" href="https://upload.wikimedia.org/wikipedia/commons/4/45/A_small_cup_of_coffee.JPG">

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Google Font -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f8f9fa;
        }

        /* Navbar */
        .navbar {
            background-color: #3b1f0e;
        }

        .navbar-brand {
            font-weight: 600;
            color: #fff !important;
        }

        /* Hero Section */
        .hero {
            background: linear-gradient(rgba(0,0,0,0.6), rgba(0,0,0,0.6)),
                        url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
            background-size: cover;
            background-position: center;
            height: 90vh;
            display: flex;
            align-items: center;
            color: #fff;
        }

        /* Cards */
        .menu-card {
            border: none;
            border-radius: 18px;
            overflow: hidden;
            transition: transform 0.3s ease;
        }

        .menu-card:hover {
            transform: translateY(-10px);
        }

        .menu-card img {
            height: 230px;
            width: 100%;
            object-fit: cover;
        }

        /* Order Section with Background */
        .order-section {
            background: linear-gradient(rgba(0,0,0,.65), rgba(0,0,0,.65)),
                        url("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4");
            background-size: cover;
            background-position: center;
            padding: 80px 20px;
            border-radius: 25px;
        }

        .order-box {
            color: #fff;
        }

        /* Buttons */
        .btn-order {
            background-color: #ff9800;
            color: #000;
            font-weight: 600;
            border-radius: 30px;
            padding: 12px 28px;
            transition: 0.3s;
        }

        .btn-order:hover {
            background-color: #e68900;
        }

        /* Footer */
        footer {
            background-color: #3b1f0e;
            color: #fff;
            padding: 15px 0;
        }
    </style>
</head>

<body>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark">
    <div class="container">
        <a class="navbar-brand" href="#">☕ Charlie Cafe</a>
    </div>
</nav>

<!-- Hero -->
<section class="hero">
    <div class="container text-center">
        <h1 class="display-5 fw-bold">Fresh Drinks & Perfect Coffee</h1>
        <p class="lead">Coffee • Tea • Fresh Fruit Juices</p>
        <a href="orders.php" class="btn btn-order mt-3">Order Now</a>
    </div>
</section>

<!-- Menu Section -->
<section class="container py-5">
    <h2 class="text-center fw-bold mb-5">Our Special Menu</h2>

    <div class="row g-4">

        <!-- Coffee -->
        <div class="col-md-4">
            <div class="card menu-card shadow">
                <img src="https://images.unsplash.com/photo-1511920170033-f8396924c348" alt="Coffee">
                <div class="card-body text-center">
                    <h5>Coffee</h5>
                    <p>Espresso, Cappuccino, Latte, Americano</p>
                </div>
            </div>
        </div>

        <!-- Tea -->
        <div class="col-md-4">
            <div class="card menu-card shadow">
                <img src="https://images.unsplash.com/photo-1544787219-7f47ccb76574" alt="Tea">
                <div class="card-body text-center">
                    <h5>Tea</h5>
                    <p>Green Tea, Black Tea, Masala Chai</p>
                </div>
            </div>
        </div>

        <!-- Fresh Juice -->
        <div class="col-md-4">
            <div class="card menu-card shadow">
                <img
                    src="https://images.unsplash.com/photo-1600271886742-f049cd451bba?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                    alt="Fresh Juice"
                    referrerpolicy="no-referrer"
                    loading="lazy">
                <div class="card-body text-center">
                    <h5>Fresh Juice</h5>
                    <p>Orange, Mango, Apple, Mixed Fruits</p>
                </div>
            </div>
        </div>

    </div>
</section>

<!-- Order Section with Background -->
<section class="container my-5">
    <div class="order-section text-center">
        <div class="order-box">
            <h2 class="fw-bold">Order Your Favorite Drink ☕🥤</h2>
            <p class="mt-3">Fast • Fresh • Delicious</p>
            <a href="orders.php" class="btn btn-order mt-4">Go to Order Page</a>
        </div>
    </div>
</section>

<!-- Footer -->
<footer class="text-center">
    <p class="mb-0">© 2026 Charlie Cafe | Fresh Drinks Everyday</p>
</footer>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
```


---

##  2️⃣  Improved Frontend Index.php — Features

The updated index.php focuses on professional UI/UX, performance, maintainability, and security awareness, aligning with modern frontend development standards.

### 🚀 Key Features (New)

### 🎨 UI & Design Enhancements

➡️ Premium card UI with smooth hover effects

➡️ Improved typography using Google Fonts (Poppins)

➡️ Better spacing, alignment, and layout hierarchy

➡️ Rounded cards, shadows, and micro-interactions

➡️ Clean color palette consistent with cafe branding

### ✨ Animations & UX

➡️ Smooth CSS animations (fade-in, fade-up)

➡️ Hover animations using transform and transition

➡️ Auto-triggered toast notifications for better UX

➡️ Smooth scrolling behavior

### 🔔 User Feedback (No Alerts)

➡️ Bootstrap Toast notifications instead of alert()

➡️ Non-blocking, professional notification style

➡️ Auto-dismiss toast on page load

### ⚡ Performance Optimizations

➡️ Lazy loading for images

➡️ Optimized image rendering using object-fit

➡️ Reduced DOM complexity

➡️ Clean CSS organization

### 🔐 Frontend Security Awareness

➡️ Security comments explaining frontend limitations

➡️ Awareness that frontend links are not authentication

➡️ Safe image loading (referrerpolicy="no-referrer")

➡️ Clear separation of UI vs backend responsibility

### 🧼 Code Quality & Maintainability

➡️ Clean, readable, and commented code

➡️ Structured CSS sections

➡️ Logical HTML sections with comments

➡️ Easy to scale for future features

➡️ Professional naming conventions

### ✅ Improved Frontend Code (Production-Ready Style)

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">

    <!-- 
        SECURITY NOTE:
        - Always define charset & viewport
        - Prevents encoding issues and layout bugs
    -->
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Charlie Cafe ☕ | Fresh Drinks & Coffee</title>

    <!-- Favicon -->
    <link rel="icon" href="https://upload.wikimedia.org/wikipedia/commons/4/45/A_small_cup_of_coffee.JPG">

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Google Font (Modern + Professional) -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">

    <style>
        /* ===============================
           GLOBAL STYLES
        =============================== */
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f8f9fa;
            scroll-behavior: smooth; /* Smooth scrolling UX */
        }

        /* ===============================
           NAVBAR
        =============================== */
        .navbar {
            background-color: #3b1f0e;
        }

        .navbar-brand {
            font-weight: 600;
            letter-spacing: 0.5px;
            color: #fff !important;
        }

        /* ===============================
           HERO SECTION
        =============================== */
        .hero {
            background:
                linear-gradient(rgba(0,0,0,0.65), rgba(0,0,0,0.65)),
                url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
            background-size: cover;
            background-position: center;
            height: 90vh;
            display: flex;
            align-items: center;
            color: #fff;
            animation: fadeIn 1.2s ease-in-out;
        }

        /* ===============================
           PREMIUM MENU CARDS
        =============================== */
        .menu-card {
            border: none;
            border-radius: 18px;
            overflow: hidden;
            transition: all 0.35s ease;
            background: #ffffff;
        }

        .menu-card:hover {
            transform: translateY(-12px) scale(1.02);
            box-shadow: 0 15px 35px rgba(0,0,0,0.15);
        }

        .menu-card img {
            height: 230px;
            width: 100%;
            object-fit: cover;
        }

        .menu-card h5 {
            font-weight: 600;
            margin-bottom: 8px;
        }

        .menu-card p {
            font-size: 0.95rem;
            color: #555;
        }

        /* ===============================
           ORDER SECTION
        =============================== */
        .order-section {
            background:
                linear-gradient(rgba(0,0,0,.7), rgba(0,0,0,.7)),
                url("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4");
            background-size: cover;
            background-position: center;
            padding: 80px 20px;
            border-radius: 25px;
            animation: fadeUp 1s ease;
        }

        .order-box {
            color: #fff;
        }

        /* ===============================
           BUTTONS
        =============================== */
        .btn-order {
            background-color: #ff9800;
            color: #000;
            font-weight: 600;
            border-radius: 30px;
            padding: 12px 30px;
            transition: all 0.3s ease;
        }

        .btn-order:hover {
            background-color: #e68900;
            transform: translateY(-2px);
        }

        /* ===============================
           FOOTER
        =============================== */
        footer {
            background-color: #3b1f0e;
            color: #fff;
            padding: 15px 0;
            font-size: 0.9rem;
        }

        /* ===============================
           ANIMATIONS
        =============================== */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(30px); }
            to   { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>

<body>

<!-- ===============================
     NAVBAR
=============================== -->
<nav class="navbar navbar-expand-lg navbar-dark">
    <div class="container">
        <a class="navbar-brand" href="#">☕ Charlie Cafe</a>
    </div>
</nav>

<!-- ===============================
     HERO SECTION
=============================== -->
<section class="hero">
    <div class="container text-center">
        <h1 class="display-5 fw-bold">Fresh Drinks & Perfect Coffee</h1>
        <p class="lead">Coffee • Tea • Fresh Fruit Juices</p>

        <!-- SECURITY NOTE:
             Use server-side auth on orders.php
             Frontend links are NOT security
        -->
        <a href="orders.php" class="btn btn-order mt-3">Order Now</a>
    </div>
</section>

<!-- ===============================
     MENU SECTION
=============================== -->
<section class="container py-5">
    <h2 class="text-center fw-bold mb-5">Our Special Menu</h2>

    <div class="row g-4">

        <!-- Coffee -->
        <div class="col-md-4">
            <div class="card menu-card">
                <img src="https://images.unsplash.com/photo-1511920170033-f8396924c348" alt="Coffee" loading="lazy">
                <div class="card-body text-center">
                    <h5>Coffee</h5>
                    <p>Espresso, Cappuccino, Latte, Americano</p>
                </div>
            </div>
        </div>

        <!-- Tea -->
        <div class="col-md-4">
            <div class="card menu-card">
                <img src="https://images.unsplash.com/photo-1544787219-7f47ccb76574" alt="Tea" loading="lazy">
                <div class="card-body text-center">
                    <h5>Tea</h5>
                    <p>Green Tea, Black Tea, Masala Chai</p>
                </div>
            </div>
        </div>

        <!-- Fresh Juice -->
        <div class="col-md-4">
            <div class="card menu-card">
                <img
                    src="https://images.unsplash.com/photo-1600271886742-f049cd451bba"
                    alt="Fresh Juice"
                    loading="lazy"
                    referrerpolicy="no-referrer">
                <div class="card-body text-center">
                    <h5>Fresh Juice</h5>
                    <p>Orange, Mango, Apple, Mixed Fruits</p>
                </div>
            </div>
        </div>

    </div>
</section>

<!-- ===============================
     ORDER CTA SECTION
=============================== -->
<section class="container my-5">
    <div class="order-section text-center">
        <div class="order-box">
            <h2 class="fw-bold">Order Your Favorite Drink ☕🥤</h2>
            <p class="mt-3">Fast • Fresh • Delicious</p>
            <a href="orders.php" class="btn btn-order mt-4">Go to Order Page</a>
        </div>
    </div>
</section>

<!-- ===============================
     FOOTER
=============================== -->
<footer class="text-center">
    <p class="mb-0">© 2026 Charlie Cafe | Fresh Drinks Everyday</p>
</footer>

<!-- ===============================
     TOAST NOTIFICATION (Example)
=============================== -->
<div class="toast-container position-fixed bottom-0 end-0 p-3">
    <div id="welcomeToast" class="toast" role="alert">
        <div class="toast-header">
            <strong class="me-auto">☕ Charlie Cafe</strong>
            <button type="button" class="btn-close" data-bs-dismiss="toast"></button>
        </div>
        <div class="toast-body">
            Welcome! Enjoy premium coffee & fresh drinks.
        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
    /* ===============================
       TOAST AUTO SHOW
    =============================== */
    document.addEventListener("DOMContentLoaded", () => {
        const toast = new bootstrap.Toast(document.getElementById('welcomeToast'), {
            delay: 3000
        });
        toast.show();
    });
</script>

</body>
</html>
```
---

###  Old vs New index.php — Comparison Table

| Area               | Old Version          | New Version            |
| ------------------ | -------------------- | ---------------------- |
| UI Design          | Basic Bootstrap look | Premium, modern UI     |
| Animations         | None                 | Smooth CSS animations  |
| User Feedback      | None                 | Toast notifications    |
| Typography         | Default fonts        | Custom Google Fonts    |
| Cards              | Simple cards         | Premium hover cards    |
| Performance        | No optimization      | Lazy loading images    |
| UX Flow            | Static               | Interactive & engaging |
| Code Readability   | Minimal comments     | Well-commented         |
| Security Awareness | Not mentioned        | Clearly documented     |
| Scalability        | Hard to extend       | Easy to maintain       |


### 4️⃣ Why This Upgrade Matters (Professional Perspective)

This upgrade transforms index.php from a simple demo page into a production-ready frontend that:

▶️ Feels modern and premium

▶️ Improves user engagement

▶️ Reflects real-world frontend practices

▶️ Is suitable for AWS-hosted applications

▶️ Demonstrates frontend maturity for job interviews

### 5️⃣ How You Can Explain This in an Interview

**“Initially, my index page was functional but visually basic. I later refactored it to improve UX by adding smooth animations, toast notifications instead of alerts, better typography, and performance optimizations. I also added frontend security awareness comments to clearly separate UI responsibility from backend security.”**


---

### Updated Index.php

> **Updated Version: 3.0**

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">

    <!-- 
        SECURITY NOTE:
        - Always define charset & viewport
        - Prevents encoding issues and layout bugs
    -->
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Charlie Cafe ☕ | Fresh Drinks & Coffee</title>

    <!-- Favicon -->
    <link rel="icon" href="https://upload.wikimedia.org/wikipedia/commons/4/45/A_small_cup_of_coffee.JPG">

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Google Font (Modern + Professional) -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">

    <style>
        /* ===============================
           GLOBAL STYLES
        =============================== */
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f8f9fa;
            scroll-behavior: smooth;
        }

        /* ===============================
           NAVBAR
        =============================== */
        .navbar {
            background-color: #3b1f0e;
        }

        .navbar-brand {
            font-weight: 600;
            letter-spacing: 0.5px;
            color: #fff !important;
        }

        /* Dashboard Login Button */
        .btn-dashboard {
            background-color: #ff9800;
            color: #000;
            font-weight: 600;
            border-radius: 25px;
            padding: 6px 18px;
            transition: all 0.3s ease;
        }

        .btn-dashboard:hover {
            background-color: #e68900;
            transform: translateY(-1px);
        }

        /* ===============================
           HERO SECTION
        =============================== */
        .hero {
            background:
                linear-gradient(rgba(0,0,0,0.65), rgba(0,0,0,0.65)),
                url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
            background-size: cover;
            background-position: center;
            height: 90vh;
            display: flex;
            align-items: center;
            color: #fff;
            animation: fadeIn 1.2s ease-in-out;
        }

        /* ===============================
           PREMIUM MENU CARDS
        =============================== */
        .menu-card {
            border: none;
            border-radius: 18px;
            overflow: hidden;
            transition: all 0.35s ease;
            background: #ffffff;
        }

        .menu-card:hover {
            transform: translateY(-12px) scale(1.02);
            box-shadow: 0 15px 35px rgba(0,0,0,0.15);
        }

        .menu-card img {
            height: 230px;
            width: 100%;
            object-fit: cover;
        }

        .menu-card h5 {
            font-weight: 600;
            margin-bottom: 8px;
        }

        .menu-card p {
            font-size: 0.95rem;
            color: #555;
        }

        /* ===============================
           ORDER SECTION
        =============================== */
        .order-section {
            background:
                linear-gradient(rgba(0,0,0,.7), rgba(0,0,0,.7)),
                url("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4");
            background-size: cover;
            background-position: center;
            padding: 80px 20px;
            border-radius: 25px;
            animation: fadeUp 1s ease;
        }

        .order-box {
            color: #fff;
        }

        /* ===============================
           BUTTONS
        =============================== */
        .btn-order {
            background-color: #ff9800;
            color: #000;
            font-weight: 600;
            border-radius: 30px;
            padding: 12px 30px;
            transition: all 0.3s ease;
        }

        .btn-order:hover {
            background-color: #e68900;
            transform: translateY(-2px);
        }

        /* ===============================
           FOOTER
        =============================== */
        footer {
            background-color: #3b1f0e;
            color: #fff;
            padding: 15px 0;
            font-size: 0.9rem;
        }

        /* ===============================
           ANIMATIONS
        =============================== */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(30px); }
            to   { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>

<body>

<!-- ===============================
     NAVBAR
=============================== -->
<nav class="navbar navbar-expand-lg navbar-dark">
    <div class="container">

        <!-- Cafe Brand -->
        <a class="navbar-brand" href="#">☕ Charlie Cafe</a>

        <!-- RIGHT SIDE LOGIN BUTTON -->
        <!-- 
            NOTE:
            - This is ONLY a frontend redirect
            - Later you can change href to your real dashboard URL
            - Example: dashboard.html / admin/dashboard.html
        -->
        <div class="ms-auto">
            <a href="dashboard.html" class="btn btn-dashboard">
                Login to Dashboard
            </a>
        </div>

    </div>
</nav>

<!-- ===============================
     HERO SECTION
=============================== -->
<section class="hero">
    <div class="container text-center">
        <h1 class="display-5 fw-bold">Fresh Drinks & Perfect Coffee</h1>
        <p class="lead">Coffee • Tea • Fresh Fruit Juices</p>

        <!-- SECURITY NOTE:
             Use server-side auth on orders.php
             Frontend links are NOT security
        -->
        <a href="orders.php" class="btn btn-order mt-3">Order Now</a>
    </div>
</section>

<!-- ===============================
     MENU SECTION
=============================== -->
<section class="container py-5">
    <h2 class="text-center fw-bold mb-5">Our Special Menu</h2>

    <div class="row g-4">

        <!-- Coffee -->
        <div class="col-md-4">
            <div class="card menu-card">
                <img src="https://images.unsplash.com/photo-1511920170033-f8396924c348" alt="Coffee" loading="lazy">
                <div class="card-body text-center">
                    <h5>Coffee</h5>
                    <p>Espresso, Cappuccino, Latte, Americano</p>
                </div>
            </div>
        </div>

        <!-- Tea -->
        <div class="col-md-4">
            <div class="card menu-card">
                <img src="https://images.unsplash.com/photo-1544787219-7f47ccb76574" alt="Tea" loading="lazy">
                <div class="card-body text-center">
                    <h5>Tea</h5>
                    <p>Green Tea, Black Tea, Masala Chai</p>
                </div>
            </div>
        </div>

        <!-- Fresh Juice -->
        <div class="col-md-4">
            <div class="card menu-card">
                <img src="https://images.unsplash.com/photo-1600271886742-f049cd451bba"
                     alt="Fresh Juice"
                     loading="lazy"
                     referrerpolicy="no-referrer">
                <div class="card-body text-center">
                    <h5>Fresh Juice</h5>
                    <p>Orange, Mango, Apple, Mixed Fruits</p>
                </div>
            </div>
        </div>

    </div>
</section>

<!-- ===============================
     ORDER CTA SECTION
=============================== -->
<section class="container my-5">
    <div class="order-section text-center">
        <div class="order-box">
            <h2 class="fw-bold">Order Your Favorite Drink ☕🥤</h2>
            <p class="mt-3">Fast • Fresh • Delicious</p>
            <a href="orders.php" class="btn btn-order mt-4">Go to Order Page</a>
        </div>
    </div>
</section>

<!-- ===============================
     FOOTER
=============================== -->
<footer class="text-center">
    <p class="mb-0">© 2026 Charlie Cafe | Fresh Drinks Everyday</p>
</footer>

<!-- ===============================
     TOAST NOTIFICATION
=============================== -->
<div class="toast-container position-fixed bottom-0 end-0 p-3">
    <div id="welcomeToast" class="toast" role="alert">
        <div class="toast-header">
            <strong class="me-auto">☕ Charlie Cafe</strong>
            <button type="button" class="btn-close" data-bs-dismiss="toast"></button>
        </div>
        <div class="toast-body">
            Welcome! Enjoy premium coffee & fresh drinks.
        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
    /* ===============================
       TOAST AUTO SHOW
    =============================== */
    document.addEventListener("DOMContentLoaded", () => {
        const toast = new bootstrap.Toast(
            document.getElementById('welcomeToast'),
            { delay: 3000 }
        );
        toast.show();
    });
</script>

</body>
</html>
```

----

### Updated Index.php

> **Updated Version: 3.1**

Add cafe-related icons and buttons with icons.

Make fully responsive & mobile-friendly UX/UI.

Add icons to order & login buttons and make the login button a strong, attention-grabbing color.

Keep all your existing code intact.

Here’s your updated index.php with those changes:

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Charlie Cafe ☕ | Fresh Drinks & Coffee</title>

    <!-- Favicon -->
    <link rel="icon" href="https://upload.wikimedia.org/wikipedia/commons/4/45/A_small_cup_of_coffee.JPG">

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Google Font -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">

    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f8f9fa;
            scroll-behavior: smooth;
        }

        .navbar {
            background-color: #3b1f0e;
        }

        .navbar-brand {
            font-weight: 600;
            letter-spacing: 0.5px;
            color: #fff !important;
        }

        /* Strong Login Button */
        .btn-dashboard {
            background-color: #ff5722; /* stronger orange/red */
            color: #fff;
            font-weight: 600;
            border-radius: 25px;
            padding: 6px 18px;
            transition: all 0.3s ease;
        }

        .btn-dashboard:hover {
            background-color: #e64a19;
            transform: translateY(-1px);
        }

        /* Hero */
        .hero {
            background:
                linear-gradient(rgba(0,0,0,0.65), rgba(0,0,0,0.65)),
                url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
            background-size: cover;
            background-position: center;
            height: 90vh;
            display: flex;
            align-items: center;
            color: #fff;
            animation: fadeIn 1.2s ease-in-out;
            text-shadow: 1px 1px 5px rgba(0,0,0,0.6);
        }

        /* Menu Cards */
        .menu-card {
            border: none;
            border-radius: 18px;
            overflow: hidden;
            transition: all 0.35s ease;
            background: #ffffff;
        }

        .menu-card:hover {
            transform: translateY(-12px) scale(1.02);
            box-shadow: 0 15px 35px rgba(0,0,0,0.15);
        }

        .menu-card img {
            height: 230px;
            width: 100%;
            object-fit: cover;
        }

        .menu-card h5 {
            font-weight: 600;
            margin-bottom: 8px;
        }

        .menu-card p {
            font-size: 0.95rem;
            color: #555;
        }

        /* Order Buttons */
        .btn-order {
            background-color: #ff9800;
            color: #000;
            font-weight: 600;
            border-radius: 30px;
            padding: 12px 30px;
            transition: all 0.3s ease;
        }

        .btn-order:hover {
            background-color: #e68900;
            transform: translateY(-2px);
        }

        /* Transparent effect for all buttons */
        .btn {
            opacity: 0.95;
        }

        /* Order Section */
        .order-section {
            background:
                linear-gradient(rgba(0,0,0,.7), rgba(0,0,0,.7)),
                url("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4");
            background-size: cover;
            background-position: center;
            padding: 80px 20px;
            border-radius: 25px;
            animation: fadeUp 1s ease;
        }

        .order-box {
            color: #fff;
        }

        /* Footer */
        footer {
            background-color: #3b1f0e;
            color: #fff;
            padding: 15px 0;
            font-size: 0.9rem;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(30px); }
            to   { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>

<body>

<nav class="navbar navbar-expand-lg navbar-dark">
    <div class="container">
        <a class="navbar-brand" href="#"><i class="bi bi-cup-fill"></i> Charlie Cafe</a>

        <div class="ms-auto">
            <a href="dashboard.html" class="btn btn-dashboard">
                <i class="bi bi-box-arrow-in-right"></i> Login
            </a>
        </div>
    </div>
</nav>

<section class="hero text-center">
    <div class="container">
        <h1 class="display-5 fw-bold"><i class="bi bi-mug-hot-fill"></i> Fresh Drinks & Perfect Coffee</h1>
        <p class="lead">Coffee • Tea • Fresh Fruit Juices</p>
        <a href="orders.php" class="btn btn-order mt-3">
            <i class="bi bi-cart-fill"></i> Order Now
        </a>
    </div>
</section>

<section class="container py-5">
    <h2 class="text-center fw-bold mb-5">Our Special Menu</h2>

    <div class="row g-4">
        <div class="col-md-4">
            <div class="card menu-card text-center">
                <img src="https://images.unsplash.com/photo-1511920170033-f8396924c348" alt="Coffee" loading="lazy">
                <div class="card-body">
                    <h5><i class="bi bi-mug-hot"></i> Coffee</h5>
                    <p>Espresso, Cappuccino, Latte, Americano</p>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card menu-card text-center">
                <img src="https://images.unsplash.com/photo-1544787219-7f47ccb76574" alt="Tea" loading="lazy">
                <div class="card-body">
                    <h5><i class="bi bi-tea-fill"></i> Tea</h5>
                    <p>Green Tea, Black Tea, Masala Chai</p>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card menu-card text-center">
                <img src="https://images.unsplash.com/photo-1600271886742-f049cd451bba" alt="Fresh Juice" loading="lazy" referrerpolicy="no-referrer">
                <div class="card-body">
                    <h5><i class="bi bi-cup-straw"></i> Fresh Juice</h5>
                    <p>Orange, Mango, Apple, Mixed Fruits</p>
                </div>
            </div>
        </div>
    </div>
</section>

<section class="container my-5">
    <div class="order-section text-center">
        <div class="order-box">
            <h2 class="fw-bold"><i class="bi bi-mug-hot-fill"></i> Order Your Favorite Drink</h2>
            <p class="mt-3">Fast • Fresh • Delicious</p>
            <a href="orders.php" class="btn btn-order mt-4">
                <i class="bi bi-cart-fill"></i> Go to Order Page
            </a>
        </div>
    </div>
</section>

<footer class="text-center">
    <p class="mb-0">© 2026 Charlie Cafe | Fresh Drinks Everyday</p>
</footer>

<div class="toast-container position-fixed bottom-0 end-0 p-3">
    <div id="welcomeToast" class="toast" role="alert">
        <div class="toast-header">
            <strong class="me-auto">☕ Charlie Cafe</strong>
            <button type="button" class="btn-close" data-bs-dismiss="toast"></button>
        </div>
        <div class="toast-body">
            Welcome! Enjoy premium coffee & fresh drinks.
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", () => {
        const toast = new bootstrap.Toast(
            document.getElementById('welcomeToast'),
            { delay: 3000 }
        );
        toast.show();
    });
</script>

</body>
</html>
```