

# AWS Cafe Development Code

## PHASE 1 - Frontend Development Code

### 1️⃣  — Create index.php (Landing Page)

```
sudo nano /var/www/html/index.php
```

#### 💻 Paste this clean landing page code:

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Charlie Cafe ☕ | Fresh Drinks & Coffee</title>

    <!-- Favicon -->
    <link rel="icon" href="https://upload.wikimedia.org/wikipedia/commons/4/45/A_small_cup_of_coffee.JPG">

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Google Font -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f8f9fa;
        }

        .navbar {
            background-color: #3b1f0e;
        }

        .navbar-brand {
            color: #fff !important;
            font-weight: 600;
        }

        /* Hero */
        .hero {
            background: linear-gradient(rgba(0,0,0,.6), rgba(0,0,0,.6)),
            url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
            background-size: cover;
            background-position: center;
            height: 90vh;
            display: flex;
            align-items: center;
            color: white;
        }

        /* Cards */
        .menu-card {
            border: none;
            border-radius: 15px;
            overflow: hidden;
            transition: transform 0.3s ease;
        }

        .menu-card:hover {
            transform: translateY(-8px);
        }

        .menu-card img {
            height: 220px;
            object-fit: cover;
            width: 100%;
        }

        .btn-order {
            background-color: #ff9800;
            font-weight: 600;
            border-radius: 30px;
            padding: 12px 25px;
            color: #000;
        }

        .btn-order:hover {
            background-color: #e68900;
        }

        .order-box {
            background: #3b1f0e;
            color: #fff;
            padding: 40px;
            border-radius: 20px;
        }

        footer {
            background: #3b1f0e;
            color: white;
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
        <h1>Fresh Drinks & Perfect Coffee</h1>
        <p>Premium coffee, tea & fresh fruit juices</p>
        <a href="orders.php" class="btn btn-order">Order Now</a>
    </div>
</section>

<!-- Menu -->
<section class="container py-5">
    <h2 class="text-center fw-bold mb-4">Our Special Menu</h2>

    <div class="row g-4">

        <!-- Coffee -->
        <div class="col-md-4">
            <div class="card menu-card shadow">
                <img src="https://images.unsplash.com/photo-1511920170033-f8396924c348"
                     alt="Coffee">
                <div class="card-body text-center">
                    <h5>Coffee</h5>
                    <p>Espresso, Cappuccino, Latte, Americano</p>
                </div>
            </div>
        </div>

        <!-- Tea -->
        <div class="col-md-4">
            <div class="card menu-card shadow">
                <img src="https://images.unsplash.com/photo-1544787219-7f47ccb76574"
                     alt="Tea">
                <div class="card-body text-center">
                    <h5>Tea</h5>
                    <p>Green Tea, Black Tea, Masala Chai</p>
                </div>
            </div>
        </div>

        <!-- Fresh Juice (FIXED IMAGE) -->
        <div class="col-md-4">
            <div class="card menu-card shadow">
                <img
                    src="https://images.unsplash.com/photo-1600271886742-f049cd451bba?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                    alt="Fresh Fruit Juice"
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

<!-- Order Box -->
<section class="container my-5">
    <div class="order-box text-center">
        <h2>Order Your Favorite Drink ☕🥤</h2>
        <p class="mt-3">Fast • Fresh • Delicious</p>
        <a href="orders.php" class="btn btn-order mt-3">Go to Order Page</a>
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

### ✅ FULL REWRITTEN index.html (With Order Section Background Image)

A background image on the “Order Box” section will make the landing page look premium and cafe-style.

Below is a complete rewrite of the full index.html with:

✅ Cafe-suitable background image on the Order section

✅ Dark overlay so text stays readable

✅ Fully responsive Bootstrap 5

✅ Clean, production-ready code

✅ Fixed Fresh Juice image

✅ Smooth, modern cafe look

You can copy-paste this as your final index.html.

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

✅ Why this looks professional

✔ Cafe-themed background image

✔ Dark overlay for readability

✔ Rounded container for premium feel

✔ Mobile + desktop optimized

✔ Perfect for AWS S3 static hosting

**⚠️ Replace S3_IMAGE_URL_HERE later (next phase)**




### 2️⃣ Update EC2 PHP App to Use API Gateway

```
sudo nano /var/www/html/orders.php
```

#### In your `orders.php`:

You can copy-paste this entire file safely 👇

```php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $data = json_encode([
        "name" => $_POST['name'],
        "item" => $_POST['item'],
        "quantity" => $_POST['quantity']
    ]);

    $ch = curl_init("https://abcdef123.execute-api.us-east-1.amazonaws.com/dev/orders");
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $data);

    $response = curl_exec($ch);
    curl_close($ch);

    echo "<p>✅ Order sent to serverless backend!</p>";
}
```


#### ✅ MODERN CAFE-STYLE orders.php (Frontend Only Modified)

✅ Cafe-style background image + dark overlay

✅ Same Poppins font + color theme as index

✅ Clean, modern order card

✅ Mobile-responsive

✅ Backend PHP code 100% untouched

#### ✅ What Changed (Frontend Only)

✔ Cafe-vibe background image

✔ Same color palette as landing page

✔ Modern rounded order card

✔ Mobile + desktop responsive

✔ Backend logic untouched & safe

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Charlie Cafe ☕ | Place Order</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Google Font -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            margin: 0;
            min-height: 100vh;
            background: linear-gradient(rgba(0,0,0,0.65), rgba(0,0,0,0.65)),
                        url("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4");
            background-size: cover;
            background-position: center;
        }

        /* Navbar */
        .navbar {
            background-color: #3b1f0e;
        }

        .navbar-brand {
            color: #fff !important;
            font-weight: 600;
        }

        /* Order Card */
        .order-card {
            background: #ffffff;
            border-radius: 20px;
            padding: 35px;
            box-shadow: 0 15px 30px rgba(0,0,0,0.3);
        }

        .order-card h2 {
            font-weight: 600;
            margin-bottom: 20px;
        }

        label {
            font-weight: 500;
            margin-top: 15px;
        }

        input, select {
            border-radius: 10px;
            padding: 10px;
        }

        /* Button */
        .btn-order {
            background-color: #ff9800;
            color: #000;
            font-weight: 600;
            border-radius: 30px;
            padding: 12px;
            border: none;
            transition: 0.3s;
        }

        .btn-order:hover {
            background-color: #e68900;
        }

        /* Footer */
        footer {
            color: #fff;
            text-align: center;
            padding: 15px;
            margin-top: 40px;
            font-size: 14px;
        }

        .response-box {
            margin-top: 20px;
            font-size: 14px;
        }
    </style>
</head>

<body>

<!-- Navbar -->
<nav class="navbar navbar-dark">
    <div class="container">
        <a class="navbar-brand" href="index.html">☕ Charlie Cafe</a>
    </div>
</nav>

<!-- Order Section -->
<div class="container d-flex justify-content-center align-items-center" style="min-height: 85vh;">
    <div class="col-md-6">
        <div class="order-card">

            <h2 class="text-center">Place Your Order</h2>
            <p class="text-center text-muted">Fresh • Hot • Made with Love</p>

            <form method="POST">

                <label>Customer Name</label>
                <input type="text" name="name" class="form-control" required>

                <label>Select Item</label>
                <select name="item" class="form-select">
                    <option value="Coffee">Coffee</option>
                    <option value="Tea">Tea</option>
                    <option value="Latte">Latte</option>
                    <option value="Cappuccino">Cappuccino</option>
                    <option value="Fresh Juice">Fresh Juice</option>
                </select>

                <label>Quantity</label>
                <input type="number" name="quantity" min="1" value="1" class="form-control">

                <button type="submit" class="btn btn-order w-100 mt-4">
                    ☕ Place Order
                </button>
            </form>

            <!-- Backend Response (UNCHANGED) -->
            <div class="response-box">
                <?php
                if ($_SERVER["REQUEST_METHOD"] === "POST") {

                    $apiUrl = "https://svirhyw5a3.execute-api.us-east-1.amazonaws.com/dev/orders";

                    $payload = json_encode([
                        "customer_name" => $_POST['name'],
                        "item" => $_POST['item'],
                        "quantity" => (int)$_POST['quantity']
                    ]);

                    $ch = curl_init($apiUrl);
                    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                    curl_setopt($ch, CURLOPT_POST, true);
                    curl_setopt($ch, CURLOPT_HTTPHEADER, [
                        "Content-Type: application/json"
                    ]);
                    curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);

                    $response = curl_exec($ch);

                    if ($response === false) {
                        echo "<p class='text-danger'>❌ CURL Error: " . curl_error($ch) . "</p>";
                    } else {
                        echo "<p class='text-success fw-bold'>✅ Order sent successfully</p>";
                        echo "<pre class='bg-light p-2 rounded'>$response</pre>";
                    }

                    curl_close($ch);
                }
                ?>
            </div>

        </div>
    </div>
</div>

<!-- Footer -->
<footer>
    © 2026 Charlie Cafe | Serverless Orders ☁️
</footer>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
```





#### FULL UPDATED orders.php (FINAL VERSION)

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>AWS Café</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f6f8;
            margin: 0;
            padding: 0;
        }
        header {
            background-color: #2c3e50;
            color: white;
            padding: 20px;
            text-align: center;
        }
        .container {
            width: 90%;
            max-width: 600px;
            margin: 30px auto;
            background-color: white;
            padding: 25px;
            border-radius: 6px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h2 {
            text-align: center;
            color: #333;
        }
        label {
            display: block;
            margin-top: 15px;
            font-weight: bold;
        }
        input, select, button {
            width: 100%;
            padding: 10px;
            margin-top: 5px;
            font-size: 16px;
        }
        button {
            background-color: #27ae60;
            color: white;
            border: none;
            margin-top: 20px;
            cursor: pointer;
        }
        button:hover {
            background-color: #219150;
        }
        footer {
            text-align: center;
            padding: 15px;
            margin-top: 30px;
            background-color: #ecf0f1;
            color: #555;
        }
    </style>
</head>
<body>

<header>
    <h1>☕ AWS Café</h1>
    <p>Welcome to our cloud-powered café</p>
</header>

<div class="container">
    <h2>Place Your Order</h2>

    <form method="POST">
        <label>Customer Name</label>
        <input type="text" name="name" required>

        <label>Select Item</label>
        <select name="item">
            <option value="Coffee">Coffee</option>
            <option value="Tea">Tea</option>
            <option value="Latte">Latte</option>
            <option value="Cappuccino">Cappuccino</option>
        </select>

        <label>Quantity</label>
        <input type="number" name="quantity" min="1" value="1">

        <button type="submit">Place Order</button>
    </form>

    <?php
if ($_SERVER["REQUEST_METHOD"] === "POST") {

    $apiUrl = "https://svirhyw5a3.execute-api.us-east-1.amazonaws.com/dev/orders";

    $payload = json_encode([
        "customer_name" => $_POST['name'],
        "item" => $_POST['item'],
        "quantity" => (int)$_POST['quantity']
    ]);

    $ch = curl_init($apiUrl);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        "Content-Type: application/json"
    ]);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);

    $response = curl_exec($ch);

    if ($response === false) {
        echo "<p style='color:red'>❌ CURL Error: " . curl_error($ch) . "</p>";
    } else {
        echo "<p style='color:green'>✅ Order sent successfully</p>";
        echo "<pre>$response</pre>";
    }

    curl_close($ch);
}
?>

</div>

<footer>
    <p>© 2025 AWS Café | Serverless Backend</p>
</footer>

</body>
</html>
```

#### ❌ (Do not use this in production; it is for research and study purposes only.)


```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>AWS Café</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f6f8;
            margin: 0;
            padding: 0;
        }
        header {
            background-color: #2c3e50;
            color: white;
            padding: 20px;
            text-align: center;
        }
        .container {
            width: 90%;
            max-width: 600px;
            margin: 30px auto;
            background-color: white;
            padding: 25px;
            border-radius: 6px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h2 {
            text-align: center;
            color: #333;
        }
        label {
            display: block;
            margin-top: 15px;
            font-weight: bold;
        }
        input, select, button {
            width: 100%;
            padding: 10px;
            margin-top: 5px;
            font-size: 16px;
        }
        button {
            background-color: #27ae60;
            color: white;
            border: none;
            margin-top: 20px;
            cursor: pointer;
        }
        button:hover {
            background-color: #219150;
        }
        footer {
            text-align: center;
            padding: 15px;
            margin-top: 30px;
            background-color: #ecf0f1;
            color: #555;
        }
    </style>
</head>
<body>

<header>
    <h1>☕ AWS Café</h1>
    <p>Welcome to our cloud-powered café</p>
</header>

<div class="container">
    <h2>Place Your Order</h2>

    <form method="POST">
        <label>Customer Name</label>
        <input type="text" name="name" required>

        <label>Select Item</label>
        <select name="item">
            <option value="Coffee">Coffee</option>
            <option value="Tea">Tea</option>
            <option value="Latte">Latte</option>
            <option value="Cappuccino">Cappuccino</option>
        </select>

        <label>Quantity</label>
        <input type="number" name="quantity" min="1" value="1">

        <button type="submit">Place Order</button>
    </form>

    <?php
    if ($_SERVER["REQUEST_METHOD"] === "POST") {

        $payload = [
            "customer_name" => $_POST["name"],
            "item"          => $_POST["item"],
            "quantity"      => (int) $_POST["quantity"]
        ];

        $apiUrl = "https://svirhyw5a3.execute-api.us-east-1.amazonaws.com/dev/orders";

        $ch = curl_init($apiUrl);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, ["Content-Type: application/json"]);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($httpCode === 200) {
            echo "<p>✅ Order sent successfully!</p>";
        } else {
            echo "<p>❌ Error sending order</p>";
            echo "<pre>$response</pre>";
        }
    }
    ?>
</div>

<footer>
    <p>© 2025 AWS Café | Serverless Backend</p>
</footer>

</body>
</html>
```
### 🟢 UPDATED orders.php (FULL FILE – COPY/PASTE)

✅ This version is 100% compatible with your new RDS schema

✅ Styling preserved

✅ Backend untouched


```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Charlie Cafe ☕ | Place Order</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Google Font -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            margin: 0;
            min-height: 100vh;
            background: linear-gradient(rgba(0,0,0,0.65), rgba(0,0,0,0.65)),
                        url("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4");
            background-size: cover;
            background-position: center;
        }

        .navbar {
            background-color: #3b1f0e;
        }

        .navbar-brand {
            color: #fff !important;
            font-weight: 600;
        }

        .order-card {
            background: #ffffff;
            border-radius: 20px;
            padding: 35px;
            box-shadow: 0 15px 30px rgba(0,0,0,0.3);
        }

        .order-card h2 {
            font-weight: 600;
            margin-bottom: 20px;
        }

        label {
            font-weight: 500;
            margin-top: 15px;
        }

        input, select {
            border-radius: 10px;
            padding: 10px;
        }

        .btn-order {
            background-color: #ff9800;
            color: #000;
            font-weight: 600;
            border-radius: 30px;
            padding: 12px;
            border: none;
            transition: 0.3s;
        }

        .btn-order:hover {
            background-color: #e68900;
        }

        footer {
            color: #fff;
            text-align: center;
            padding: 15px;
            margin-top: 40px;
            font-size: 14px;
        }

        .response-box {
            margin-top: 20px;
            font-size: 14px;
        }
    </style>
</head>

<body>

<!-- Navbar -->
<nav class="navbar navbar-dark">
    <div class="container">
        <a class="navbar-brand" href="index.html">☕ Charlie Cafe</a>
    </div>
</nav>

<!-- Order Section -->
<div class="container d-flex justify-content-center align-items-center" style="min-height: 85vh;">
    <div class="col-md-6">
        <div class="order-card">

            <h2 class="text-center">Place Your Order</h2>
            <p class="text-center text-muted">Fresh • Hot • Made with Love</p>

            <form method="POST">

                <!-- NEW: TABLE NUMBER -->
                <label>Table Number</label>
                <input type="number" name="table_number" min="1" class="form-control" required>

                <label>Customer Name</label>
                <input type="text" name="name" class="form-control">

                <label>Select Item</label>
                <select name="item" class="form-select">
                    <option value="Coffee">Coffee</option>
                    <option value="Tea">Tea</option>
                    <option value="Latte">Latte</option>
                    <option value="Cappuccino">Cappuccino</option>
                    <option value="Fresh Juice">Fresh Juice</option>
                </select>

                <label>Quantity</label>
                <input type="number" name="quantity" min="1" value="1" class="form-control">

                <button type="submit" class="btn btn-order w-100 mt-4">
                    ☕ Place Order
                </button>
            </form>

            <!-- Backend Response (UNCHANGED FLOW) -->
            <div class="response-box">
                <?php
                if ($_SERVER["REQUEST_METHOD"] === "POST") {

                    $apiUrl = "https://svirhyw5a3.execute-api.us-east-1.amazonaws.com/dev/orders";

                    $payload = json_encode([
                        "table_number"  => (int)$_POST['table_number'],
                        "customer_name" => $_POST['name'],
                        "item"          => $_POST['item'],
                        "quantity"      => (int)$_POST['quantity']
                    ]);

                    $ch = curl_init($apiUrl);
                    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                    curl_setopt($ch, CURLOPT_POST, true);
                    curl_setopt($ch, CURLOPT_HTTPHEADER, [
                        "Content-Type: application/json"
                    ]);
                    curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);

                    $response = curl_exec($ch);

                    if ($response === false) {
                        echo "<p class='text-danger'>❌ CURL Error: " . curl_error($ch) . "</p>";
                    } else {
                        echo "<p class='text-success fw-bold'>✅ Order sent successfully</p>";
                        echo "<pre class='bg-light p-2 rounded'>$response</pre>";
                    }

                    curl_close($ch);
                }
                ?>
            </div>

        </div>
    </div>
</div>

<!-- Footer -->
<footer>
    © 2026 Charlie Cafe | Serverless Orders ☁️
</footer>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
```



---

## PHASE 2 - Backend Development Code

### 1️⃣ Lambda Code — AUTOMATION Lambda Cafe-Order (SERVERLESS)

#### ❌ (Do not use this in production; it is for research and study purposes only.)

##### Your Lambda must expect proxy format:

```
import json

def lambda_handler(event, context):
    body = json.loads(event["body"])

    customer_name = body["customer_name"]
    item = body["item"]
    quantity = body["quantity"]

    return {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps({"message": "Order saved"})
    }
```

### Lambda Payload Code (INSERT INTO MariaDB)
Paste THIS EXACT CODE ⬇️

```
import json
import pymysql
import boto3

def get_db_secret():
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId='CafeDevDBSM')
    return json.loads(response['SecretString'])

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])

        customer_name = body['customer_name']
        item = body['item']
        quantity = int(body['quantity'])

        secret = get_db_secret()

        connection = pymysql.connect(
            host=secret['host'],
            user=secret['username'],
            password=secret['password'],
            database=secret['dbname'],
            connect_timeout=5
        )

        with connection.cursor() as cursor:
            sql = """
                INSERT INTO orders (customer_name, item, quantity)
                VALUES (%s, %s, %s)
            """
            cursor.execute(sql, (customer_name, item, quantity))
            connection.commit()

        connection.close()

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({"message": "Order saved successfully"})
        }

    except Exception as e:
        print("ERROR:", str(e))
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({"error": str(e)})
        }
```

### 🟢 UPDATED LAMBDA CODE (SAFE & FINAL)

✅ Copy-paste this entire file

✅ Compatible with your new orders.php

✅ Compatible with new RDS schema

```
import json
import pymysql
import boto3

# ---------- GET DB SECRET ----------
def get_db_secret():
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId='CafeDevDBSM')
    return json.loads(response['SecretString'])

# ---------- LAMBDA HANDLER ----------
def lambda_handler(event, context):
    try:
        # Parse API Gateway body
        body = json.loads(event['body'])

        # NEW: Table Number
        table_number = int(body['table_number'])

        customer_name = body.get('customer_name', None)
        item = body['item']
        quantity = int(body['quantity'])

        # Fetch DB credentials
        secret = get_db_secret()

        # Connect to RDS
        connection = pymysql.connect(
            host=secret['host'],
            user=secret['username'],
            password=secret['password'],
            database=secret['dbname'],
            connect_timeout=5
        )

        # Insert order
        with connection.cursor() as cursor:
            sql = """
                INSERT INTO orders (table_number, customer_name, item, quantity)
                VALUES (%s, %s, %s, %s)
            """
            cursor.execute(
                sql,
                (table_number, customer_name, item, quantity)
            )
            connection.commit()

        connection.close()

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "message": "Order saved successfully",
                "table_number": table_number
            })
        }

    except Exception as e:
        print("❌ ERROR:", str(e))
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({"error": str(e)})
        }
```




---

### 2️⃣ Lambda Code — Read Menu from DynamoDB (Python)

Now we implement the logic.

Use boto3 to fetch menu/prices before processing orders.

```
import boto3
import json
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('CafeMenu')

def decimal_to_native(obj):
    if isinstance(obj, Decimal):
        # Convert Decimal to int if whole number, else float
        if obj % 1 == 0:
            return int(obj)
        return float(obj)
    raise TypeError

def lambda_handler(event, context):
    response = table.scan()
    items = response.get('Items', [])

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(items, default=decimal_to_native)
    }
```


---

### 3️⃣ Lambda Code — AUTOMATION SQS (Async Order Processing)

#### 📣 CafeOrderApiLambda — Code Evolution & Purpose

In this lab, the CafeOrderApiLambda is responsible for:

✅ Receiving orders from API Gateway

✅ Validating input

✅ Sending orders to Amazon SQS

❌ NOT interacting with RDS directly

> **This section documents all versions of the Lambda code used during learning, including their purpose, limitations, and why improvements were needed.**

#### 🧪 Version 1 — Strict Input Validation (Initial Learning Version)

#### 📌 Purpose

- Learn basic API → Lambda → SQS flow

- Enforce strict input requirements

- Understand how missing fields cause failures

#### 🧠 Key Behavior

- Requires customer_name, item, and quantity

- Fails if any field is missing

- Explicitly converts quantity to integer

- Returns HTTP 400 for client errors

#### ⚠️ Limitation

- No default values

- No CORS header on error

- Not user-friendly for real APIs

#### 💻 Code

```
import json
import boto3
import os

sqs = boto3.client('sqs')
QUEUE_URL = os.environ['SQS_QUEUE_URL']

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])

        message = {
            "customer_name": body["customer_name"],
            "item": body["item"],
            "quantity": int(body["quantity"])
        }

        sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(message)
        )

        return {
            "statusCode": 202,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({"message": "Order accepted"})
        }

    except Exception as e:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": str(e)})
        }
```        

#### 🧪 Version 2 — Safer Defaults (Improved Usability Version)

#### 📌 Purpose

- Allow optional customer_name

- Avoid breaking API if field is missing

- Improve user experience

#### 🧠 Key Behavior

- Defaults customer_name to "Guest"

- Keeps API functional even if field missing

- Always returns CORS headers

#### ⚠️ Limitation

- Does NOT convert quantity to integer

- Incorrect use of HTTP 500 for client errors

- Still lacks full validation

#### 💻 Code

```
import json
import boto3
import os

sqs = boto3.client('sqs')
QUEUE_URL = os.environ['SQS_QUEUE_URL']

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])

        order = {
            "customer_name": body.get("customer_name", "Guest"),
            "item": body["item"],
            "quantity": body["quantity"]
        }

        sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(order)
        )

        return {
            "statusCode": 202,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"message": "Order accepted"})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }
```

#### ✅ Version 3 — Final Merged & Production-Ready (Recommended)

#### 📌 Purpose

- Combine strict validation + safe defaults

- Follow real-world serverless best practices

- Clean separation between API Lambda and Worker Lambda

- Suitable for interviews, demos, and production labs

#### 🧠 Key Improvements

✔ Input validation

✔ Default values

✔ Type safety

✔ Correct HTTP status codes

✔ Proper CORS handling

✔ Clean SQS message format

#### 💻 Final Code (Recommended for This Lab)

```
import json
import boto3
import os

sqs = boto3.client('sqs')
QUEUE_URL = os.environ['SQS_QUEUE_URL']

def lambda_handler(event, context):
    try:
        # Parse request body
        body = json.loads(event.get('body', '{}'))

        # Validate required fields
        if "item" not in body or "quantity" not in body:
            return {
                "statusCode": 400,
                "headers": {"Access-Control-Allow-Origin": "*"},
                "body": json.dumps({"error": "Missing required fields: item, quantity"})
            }

        order = {
            "customer_name": body.get("customer_name", "Guest"),
            "item": body["item"],
            "quantity": int(body["quantity"])
        }

        # Send message to SQS
        sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(order)
        )

        return {
            "statusCode": 202,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({
                "message": "Order accepted",
                "order": order
            })
        }

    except ValueError:
        return {
            "statusCode": 400,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": "Quantity must be a number"})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }
```
#### 🧠 Learning Summary (Why This Matters)

| Version | What You Learned             |
| ------- | ---------------------------- |
| v1      | Strict validation & failures |
| v2      | Defaults & API safety        |
| v3      | Real-world production design |


> **API Lambda validates and enqueues.**
> **Worker Lambda processes and writes to RDS.**

**✅ This separation is core serverless architecture.**

---

### 4️⃣ Lambda Code — AUTOMATION SQS (Async Order Processing) Worker Lambda (Consumer)

#### 📄 CafeOrderWorker Lambda Codes

> **We have two versions of the Worker Lambda. Both process orders from SQS and insert them into RDS + DynamoDB, but there are subtle differences in production safety and error handling.**

#### 1️⃣ Worker Lambda — Full Example (Original)

#### Purpose:

This is the first full example of a Lambda function that consumes messages from SQS, inserts them into RDS, and updates DynamoDB. Good for learning and initial testing, but not fully safe for production.

#### Pros:

- Simple, clear structure

- Easy to understand for beginners

- Works for initial testing

#### Cons / Risks:

- Does not raise errors to SQS on failure → messages may be lost silently

- No extra logging for debugging production issues

- Short DB timeout (5s) may fail in real-life high-latency situations

#### 💻 Code:

```
import json
import boto3
import pymysql
from decimal import Decimal

# ---------- AWS CLIENTS ----------
secrets_client = boto3.client('secretsmanager')
dynamodb = boto3.resource('dynamodb')

# ---------- CONSTANTS ----------
SECRET_NAME = "CafeDevDBSM"
DYNAMODB_TABLE = "CafeMenu"

# ---------- GET DB CREDS ----------
def get_db_secret():
    response = secrets_client.get_secret_value(
        SecretId=SECRET_NAME
    )
    return json.loads(response["SecretString"])

# ---------- LAMBDA HANDLER ----------
def lambda_handler(event, context):

    secret = get_db_secret()

    connection = pymysql.connect(
        host=secret["host"],
        user=secret["username"],
        password=secret["password"],
        database=secret["dbname"],
        connect_timeout=5
    )

    table = dynamodb.Table(DYNAMODB_TABLE)

    try:
        with connection.cursor() as cursor:

            for record in event["Records"]:

                order = json.loads(record["body"])

                customer_name = order["customer_name"]
                item = order["item"]
                quantity = int(order["quantity"])

                # ---------- INSERT INTO RDS ----------
                sql = """
                    INSERT INTO orders (customer_name, item, quantity)
                    VALUES (%s, %s, %s)
                """
                cursor.execute(sql, (customer_name, item, quantity))
                connection.commit()

                # ---------- UPDATE DYNAMODB CACHE ----------
                table.update_item(
                    Key={"item": item},
                    UpdateExpression="ADD orders :inc",
                    ExpressionAttributeValues={
                        ":inc": Decimal(quantity)
                    }
                )

                print(f"✅ Order processed: {order}")

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Orders processed successfully"})
        }

    except Exception as e:
        print("❌ ERROR:", str(e))
```

#### 2️⃣ Worker Lambda — Fixed / Production Safe (Recommended)

#### Purpose:

This is the improved “production-safe” version. Handles errors properly, has better debug logging, and uses a slightly longer DB timeout. Recommended for real SQS-triggered environments.

#### Pros:

- Production-ready: raises exception to SQS → prevents message loss

- Better logging for troubleshooting

- Slightly longer DB timeout (10s) → more reliable

- Safe for automatic SQS polling

#### Cons:

- Slightly more verbose (prints, exception raising)

- Beginners may find it slightly harder to read

#### 💻 Code:

```
import json
import boto3
import pymysql
from decimal import Decimal

# ---------- AWS CLIENTS ----------
secrets_client = boto3.client('secretsmanager')
dynamodb = boto3.resource('dynamodb')

# ---------- CONSTANTS ----------
SECRET_NAME = "CafeDevDBSM"
DYNAMODB_TABLE = "CafeMenu"

# ---------- GET DB CREDS ----------
def get_db_secret():
    print("Fetching DB secret...")
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ---------- LAMBDA HANDLER ----------
def lambda_handler(event, context):

    print("Lambda triggered by SQS")
    print("Event:", event)

    secret = get_db_secret()

    connection = pymysql.connect(
        host=secret["host"],
        user=secret["username"],
        password=secret["password"],
        database=secret["dbname"],
        connect_timeout=10
    )

    table = dynamodb.Table(DYNAMODB_TABLE)

    try:
        with connection.cursor() as cursor:
            for record in event["Records"]:
                order = json.loads(record["body"])

                customer_name = order["customer_name"]
                item = order["item"]
                quantity = int(order["quantity"])

                # ---------- INSERT INTO RDS ----------
                cursor.execute(
                    "INSERT INTO orders (customer_name, item, quantity) VALUES (%s, %s, %s)",
                    (customer_name, item, quantity)
                )
                connection.commit()

                # ---------- UPDATE DYNAMODB ----------
                table.update_item(
                    Key={"item": item},
                    UpdateExpression="ADD orders :inc",
                    ExpressionAttributeValues={":inc": Decimal(quantity)}
                )

                print("✅ Order processed:", order)

        return {"statusCode": 200}

    except Exception as e:
        print("❌ FATAL ERROR:", str(e))
        raise e   # 🚨 REQUIRED FOR SQS RETRY
```

#### 🔑 Key Differences Between Both Versions

| Feature                     | Original Full Example                                 | Fixed / Production Safe                           |
| --------------------------- | ----------------------------------------------------- | ------------------------------------------------- |
| Error Handling              | Prints error only, returns 200 → messages may be lost | Raises exception → SQS will retry failed messages |
| Logging                     | Basic                                                 | Extensive, shows SQS event, debug messages        |
| DB Timeout                  | 5 seconds                                             | 10 seconds (safer in production)                  |
| Recommended for Production? | ❌ Only for testing                                    | ✅ Best practice                                   |
| Safety with SQS             | Not safe                                              | Safe, retries on failure                          |
| Developer Understanding     | Easy to read                                          | Slightly more complex but safer                   |

#### 💡 Recommendation for this Lab

- Use the Fixed / Production Safe Lambda for CafeOrderWorker.

- Keep the Original version only as a learning reference.

#### Reason:

- Automatic retries from SQS prevent data loss

- Full visibility in CloudWatch logs for debugging

- Matches real-world serverless architecture patterns

❌ If even ONE key name differs → connection fails silently

#### 6️⃣ Add DEBUG LOGS (TEMPORARY)

Update your Lambda code temporarily:

```
print("DEBUG: Lambda invoked")
print("DEBUG: Event =", event)

secret = get_db_secret()
print("DEBUG: Secret fetched")

connection = pymysql.connect(
    host=secret["host"],
    user=secret["username"],
    password=secret["password"],
    database=secret["dbname"],
    connect_timeout=5
)

print("DEBUG: RDS connected")
```

This lets us see exactly where it stops.

---

### 5️⃣ Lambda code - ORDER STATUS DASHBOARD 

#### Below is the FINAL, READY-TO-DEPLOY Worker Lambda code with:

✅ Your existing logic untouched

✅ Order metrics added safely

✅ Correct placement (TOP + AFTER DB insert)

✅ SQS-safe error handling

#### ✅ FINAL WORKER LAMBDA CODE (COPY–PASTE FULL)

```
import json
import boto3
import pymysql
from decimal import Decimal

# ---------- AWS CLIENTS ----------
secrets_client = boto3.client('secretsmanager')
dynamodb = boto3.resource('dynamodb')

# ---------- CONSTANTS ----------
SECRET_NAME = "CafeDevDBSM"
DYNAMODB_TABLE = "CafeMenu"
METRICS_TABLE = "CafeOrderMetrics"

# ---------- DYNAMODB TABLES ----------
menu_table = dynamodb.Table(DYNAMODB_TABLE)
metrics_table = dynamodb.Table(METRICS_TABLE)   # 👈 (STEP 3.2 — TOP ADDITION)

# ---------- GET DB CREDS ----------
def get_db_secret():
    print("Fetching DB secret...")
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ---------- LAMBDA HANDLER ----------
def lambda_handler(event, context):

    print("Lambda triggered by SQS")
    print("Event:", event)

    secret = get_db_secret()

    connection = pymysql.connect(
        host=secret["host"],
        user=secret["username"],
        password=secret["password"],
        database=secret["dbname"],
        connect_timeout=10
    )

    try:
        with connection.cursor() as cursor:
            for record in event["Records"]:

                # ---------- PARSE SQS MESSAGE ----------
                order = json.loads(record["body"])
                customer_name = order["customer_name"]
                item = order["item"]
                quantity = int(order["quantity"])

                # ---------- INSERT INTO RDS ----------
                cursor.execute(
                    "INSERT INTO orders (customer_name, item, quantity) VALUES (%s, %s, %s)",
                    (customer_name, item, quantity)
                )
                connection.commit()

                # ---------- UPDATE DYNAMODB MENU ----------
                menu_table.update_item(
                    Key={"item": item},
                    UpdateExpression="ADD orders :inc",
                    ExpressionAttributeValues={":inc": Decimal(quantity)}
                )

                # ---------- UPDATE ORDER METRICS ----------
                metrics_table.update_item(
                    Key={"metric": "TOTAL_ORDERS"},
                    UpdateExpression="ADD #c :inc",
                    ExpressionAttributeNames={"#c": "count"},
                    ExpressionAttributeValues={":inc": Decimal(1)}
                )

                print("✅ Order processed successfully:", order)

        return {"statusCode": 200}

    except Exception as e:
        print("❌ FATAL ERROR:", str(e))
        raise e   # 🚨 REQUIRED so SQS retries on failure
```

#### 🧠 WHAT WAS ADDED (SO YOU REMEMBER LATER)

#### 1️⃣ At the TOP (Global scope)

```
metrics_table = dynamodb.Table("CafeOrderMetrics")
```

Purpose

Creates a reusable DynamoDB connection

Avoids re-creating client inside loop

Best practice for Lambda performance

#### 2️⃣ AFTER successful RDS insert

```
metrics_table.update_item(
    Key={"metric": "TOTAL_ORDERS"},
    UpdateExpression="ADD #c :inc",
    ExpressionAttributeNames={"#c": "count"},
    ExpressionAttributeValues={":inc": Decimal(1)}
)
```

Purpose

Increments total orders only after DB success

Keeps RDS as source of truth

DynamoDB used for fast counters

✅ VERIFICATION CHECKLIST (DO THIS NOW)
1️⃣ Send order from frontend / API

✔ Order placed

2️⃣ Check SQS

✔ Message disappears (consumed)

3️⃣ Check RDS

```
SELECT * FROM orders ORDER BY created_at DESC;
```
✔ New row present

4️⃣ Check DynamoDB → CafeMenu

✔ orders increased for item

5️⃣ Check DynamoDB → CafeOrderMetrics

✔ TOTAL_ORDERS increased by 1

6️⃣ Check CloudWatch Logs

✔ "Order processed successfully"

🏆 RESULT

You now have:

✅ Event-driven backend

✅ Reliable order processing

✅ Real-time metrics

✅ Production-safe SQS worker

✅ Zero backend breakage

---

### 6️⃣ Lambda code - ORDER STATUS DASHBOARD 

