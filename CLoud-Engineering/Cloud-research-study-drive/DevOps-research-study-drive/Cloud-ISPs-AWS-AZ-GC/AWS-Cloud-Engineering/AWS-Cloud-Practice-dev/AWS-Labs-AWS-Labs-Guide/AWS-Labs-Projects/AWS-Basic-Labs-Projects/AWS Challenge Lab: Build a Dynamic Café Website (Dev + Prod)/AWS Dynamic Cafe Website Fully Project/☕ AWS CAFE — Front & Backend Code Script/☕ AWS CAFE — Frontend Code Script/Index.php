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
