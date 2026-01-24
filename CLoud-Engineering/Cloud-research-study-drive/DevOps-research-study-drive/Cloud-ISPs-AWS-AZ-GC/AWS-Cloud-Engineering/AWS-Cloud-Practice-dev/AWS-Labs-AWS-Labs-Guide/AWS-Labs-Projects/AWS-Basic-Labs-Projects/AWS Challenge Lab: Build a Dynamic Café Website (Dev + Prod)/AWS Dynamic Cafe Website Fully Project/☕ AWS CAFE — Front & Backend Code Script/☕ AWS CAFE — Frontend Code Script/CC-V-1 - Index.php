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