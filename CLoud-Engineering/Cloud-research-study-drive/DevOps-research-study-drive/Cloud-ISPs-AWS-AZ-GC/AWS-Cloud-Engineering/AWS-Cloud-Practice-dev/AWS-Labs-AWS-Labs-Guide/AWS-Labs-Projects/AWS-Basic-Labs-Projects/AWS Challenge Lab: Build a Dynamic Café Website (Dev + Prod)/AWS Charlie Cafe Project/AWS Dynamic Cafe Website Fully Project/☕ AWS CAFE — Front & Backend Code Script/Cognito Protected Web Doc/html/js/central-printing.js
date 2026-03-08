/* =========================================================
   CHARLIE CAFE — PRINTING MODULE
   ---------------------------------------------------------
   ✔ Print All Orders
   ✔ Print Daily Summary
========================================================= */

window.CHARLIE_PRINT = (() => {

    function printAllOrders() {
        console.log("🖨️ Printing all orders...");
        window.print();
    }

    function printTodaySummary() {

        const table = document.querySelector("#ordersTable tbody");
        if (!table) return alert("❌ Orders table not found");

        const rows = table.querySelectorAll("tr");
        const today = new Date().toISOString().split("T")[0];

        let totalOrders = 0;
        let totalAmount = 0;

        rows.forEach(row => {
            const orderDate = row.dataset.date;
            const amount = parseFloat(row.dataset.total || 0);

            if (orderDate === today) {
                totalOrders++;
                totalAmount += amount;
            }
        });

        const summaryHTML = `
            <div style="padding:20px">
                <h3 style="text-align:center">☕ Charlie Cafe — Daily Summary</h3>
                <hr>
                <p><strong>Date:</strong> ${today}</p>
                <p><strong>Total Orders:</strong> ${totalOrders}</p>
                <p><strong>Total Sales:</strong> $${totalAmount.toFixed(2)}</p>
            </div>
        `;

        const originalContent = document.body.innerHTML;
        document.body.innerHTML = summaryHTML;

        window.print();

        document.body.innerHTML = originalContent;
        location.reload();
    }

    return {
        printAllOrders,
        printTodaySummary
    };

})();
