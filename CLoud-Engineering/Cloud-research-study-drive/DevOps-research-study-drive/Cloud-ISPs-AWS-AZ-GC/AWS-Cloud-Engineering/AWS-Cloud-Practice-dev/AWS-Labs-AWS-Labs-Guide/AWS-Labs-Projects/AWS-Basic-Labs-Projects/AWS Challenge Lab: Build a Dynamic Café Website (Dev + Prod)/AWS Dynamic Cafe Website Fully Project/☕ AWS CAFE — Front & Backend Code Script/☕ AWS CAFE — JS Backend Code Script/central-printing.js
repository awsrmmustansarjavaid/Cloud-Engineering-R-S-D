/* =========================================================
   CENTRAL PRINTING MODULE
   Handles:
   ✔ Browser printing
   ✔ CSV export
   ✔ PDF export
   ✔ Protected downloads
   ✔ Public downloads
========================================================= */

import { protectedFetch, publicFetch } from "./api.js";
import { formatCurrency } from "./utils.js";

/* =====================================================
   1️⃣ BROWSER PRINT FUNCTIONS
===================================================== */

/**
 * Print entire current page
 */
export function printPage() {
    window.print();
}

/**
 * Print daily summary from table
 * Table rows must contain:
 *   data-date
 *   data-total
 */
export function printTodaySummary(tableSelector = "#ordersTable") {

    const table = document.querySelector(`${tableSelector} tbody`);
    if (!table) {
        alert("Orders table not found");
        return;
    }

    const today = new Date().toISOString().split("T")[0];
    let totalOrders = 0;
    let totalSales = 0;

    table.querySelectorAll("tr").forEach(row => {

        const orderDate = row.dataset.date;
        const amount = parseFloat(row.dataset.total || 0);

        if (orderDate === today) {
            totalOrders++;
            totalSales += amount;
        }
    });

    const summaryHTML = `
        <div style="padding:20px">
            <h2>Charlie Cafe — Daily Summary</h2>
            <hr>
            <p><strong>Date:</strong> ${today}</p>
            <p><strong>Total Orders:</strong> ${totalOrders}</p>
            <p><strong>Total Sales:</strong> ${formatCurrency(totalSales)}</p>
        </div>
    `;

    const original = document.body.innerHTML;
    document.body.innerHTML = summaryHTML;
    window.print();
    document.body.innerHTML = original;
    location.reload();
}

/* =====================================================
   2️⃣ FILE DOWNLOAD HELPER
===================================================== */

async function downloadBlob(response, filename) {

    if (!response || !response.ok) {
        alert("Download failed");
        return;
    }

    const blob = await response.blob();

    const link = document.createElement("a");
    link.href = URL.createObjectURL(blob);
    link.download = filename;

    document.body.appendChild(link);
    link.click();

    URL.revokeObjectURL(link.href);
    document.body.removeChild(link);
}

/* =====================================================
   3️⃣ PROTECTED EXPORT (Admin / Employee)
===================================================== */

/**
 * Export protected report (PDF or CSV)
 * Example:
 *   /admin/export?type=pdf
 */
export async function exportProtectedReport(path, filename) {

    const response = await protectedFetch(path, {
        method: "GET"
    });

    await downloadBlob(response, filename);
}

/* =====================================================
   4️⃣ PUBLIC EXPORT (No Cognito)
===================================================== */

/**
 * Export public report
 * Example:
 *   /public/invoice?order_id=123
 */
export async function exportPublicReport(path, filename) {

    const response = await publicFetch(path, {
        method: "GET"
    });

    await downloadBlob(response, filename);
}

/* =====================================================
   5️⃣ CSV FROM TABLE (Client-Side)
===================================================== */

export function exportTableToCSV(tableSelector, filename = "export.csv") {

    const table = document.querySelector(tableSelector);
    if (!table) {
        alert("Table not found");
        return;
    }

    let csv = [];

    const rows = table.querySelectorAll("tr");

    rows.forEach(row => {
        const cols = row.querySelectorAll("th, td");
        const rowData = [];

        cols.forEach(col => {
            rowData.push(`"${col.innerText.replace(/"/g, '""')}"`);
        });

        csv.push(rowData.join(","));
    });

    const blob = new Blob([csv.join("\n")], {
        type: "text/csv"
    });

    const link = document.createElement("a");
    link.href = URL.createObjectURL(blob);
    link.download = filename;

    document.body.appendChild(link);
    link.click();

    document.body.removeChild(link);
}
