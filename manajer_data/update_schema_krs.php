<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include 'config/database.php';

try {
    // $conn is already defined in config/database.php
    $db = $conn;

    // Add dosen_wali_id column
    $check = $db->query("SHOW COLUMNS FROM users LIKE 'dosen_wali_id'");
    if ($check->rowCount() == 0) {
        $sql = "ALTER TABLE users ADD COLUMN dosen_wali_id INT NULL DEFAULT NULL AFTER major_id";
        $db->exec($sql);
        echo "Column 'dosen_wali_id' added successfully.<br>";
    } else {
        echo "Column 'dosen_wali_id' already exists.<br>";
    }

    // Add krs_status column
    $check = $db->query("SHOW COLUMNS FROM users LIKE 'krs_status'");
    if ($check->rowCount() == 0) {
        $sql = "ALTER TABLE users ADD COLUMN krs_status ENUM('draft', 'submitted', 'approved', 'rejected') DEFAULT 'draft' AFTER payment_status";
        $db->exec($sql);
        echo "Column 'krs_status' added successfully.<br>";
    } else {
        echo "Column 'krs_status' already exists.<br>";
    }

    echo "Schema update completed.";

} catch(PDOException $e) {
    echo "Error: " . $e->getMessage();
}
?>
