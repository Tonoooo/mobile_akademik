<?php
// update_schema_enrollments.php
require_once 'config/database.php';

try {
    // Add 'status' to 'enrollments' table
    $checkStatus = $conn->query("SHOW COLUMNS FROM enrollments LIKE 'status'");
    if ($checkStatus->rowCount() == 0) {
        $alterStatus = "ALTER TABLE enrollments ADD COLUMN status ENUM('active', 'dropped') NOT NULL DEFAULT 'active' AFTER class_id";
        $conn->exec($alterStatus);
        echo "✅ Kolom 'status' berhasil ditambahkan ke tabel 'enrollments'.<br>";
    } else {
        echo "ℹ️ Kolom 'status' sudah ada di tabel 'enrollments'.<br>";
    }

    // Add 'grade' to 'enrollments' table
    $checkGrade = $conn->query("SHOW COLUMNS FROM enrollments LIKE 'grade'");
    if ($checkGrade->rowCount() == 0) {
        $alterGrade = "ALTER TABLE enrollments ADD COLUMN grade VARCHAR(2) NULL AFTER status";
        $conn->exec($alterGrade);
        echo "✅ Kolom 'grade' berhasil ditambahkan ke tabel 'enrollments'.<br>";
    } else {
        echo "ℹ️ Kolom 'grade' sudah ada di tabel 'enrollments'.<br>";
    }

} catch(PDOException $e) {
    echo "❌ Error: " . $e->getMessage();
}
?>
