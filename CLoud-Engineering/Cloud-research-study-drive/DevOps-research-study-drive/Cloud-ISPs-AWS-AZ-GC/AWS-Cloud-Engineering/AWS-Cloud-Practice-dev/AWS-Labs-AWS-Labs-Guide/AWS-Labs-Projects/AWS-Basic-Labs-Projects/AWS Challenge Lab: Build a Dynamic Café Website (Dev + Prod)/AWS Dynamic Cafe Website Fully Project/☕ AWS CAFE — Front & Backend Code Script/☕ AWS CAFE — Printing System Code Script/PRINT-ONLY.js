<script>
function printAllOrders() {
  window.print();
}

function printTodaySummary() {

  const rows = document.querySelectorAll("#ordersTable tbody tr");
  let today = new Date().toISOString().split("T")[0];

  let totalOrders = 0;
  let totalAmount = 0;

  rows.forEach(row => {
    const orderDate = row.dataset.date;
    const amount = parseFloat(row.dataset.total);

    if (orderDate === today) {
      totalOrders++;
      totalAmount += amount;
    }
  });

  const summaryHTML = `
    <h3>☕ Cafe Daily Summary</h3>
    <p><strong>Date:</strong> ${today}</p>
    <p><strong>Total Orders:</strong> ${totalOrders}</p>
    <p><strong>Total Sales:</strong> ${totalAmount}</p>
  `;

  const original = document.body.innerHTML;
  document.body.innerHTML = summaryHTML;
  window.print();
  document.body.innerHTML = original;
}
</script>