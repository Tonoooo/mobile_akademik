<?php
// update_schema_finance.php
require_once 'config/database.php';

try {
    // Add 'payment_status' to 'users' table
    // default: 'unpaid'
    // values: 'unpaid', 'paid'
    
    $checkCol = $conn->query("SHOW COLUMNS FROM users LIKE 'payment_status'");
    if ($checkCol->rowCount() == 0) {
        $alterUsers = "ALTER TABLE users ADD COLUMN payment_status ENUM('unpaid', 'paid') DEFAULT 'unpaid' AFTER major_id";
        $conn->exec($alterUsers);
        echo "✅ Kolom 'payment_status' berhasil ditambahkan ke tabel 'users'.<br>";
    } else {
        echo "ℹ️ Kolom 'payment_status' sudah ada.<br>";
    }

} catch(PDOException $e) {
    echo "❌ Error: " . $e->getMessage();
}
?>
