<?php
// update_schema_classes.php
require_once 'config/database.php';

try {
    // Add 'quota' to 'classes' table
    $checkCol = $conn->query("SHOW COLUMNS FROM classes LIKE 'quota'");
    if ($checkCol->rowCount() == 0) {
        $alterClasses = "ALTER TABLE classes ADD COLUMN quota INT NOT NULL DEFAULT 40 AFTER room";
        $conn->exec($alterClasses);
        echo "✅ Kolom 'quota' berhasil ditambahkan ke tabel 'classes'.<br>";
    } else {
        echo "ℹ️ Kolom 'quota' sudah ada di tabel 'classes'.<br>";
    }

} catch(PDOException $e) {
    echo "❌ Error: " . $e->getMessage();
}
?>
