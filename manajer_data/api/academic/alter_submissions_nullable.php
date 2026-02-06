<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include_once '../../config/database.php';

try {
    $sql = "ALTER TABLE submissions MODIFY COLUMN file_url VARCHAR(255) NULL";
    $conn->exec($sql);
    echo "Column 'file_url' in 'submissions' table modified to allow NULL.<br>";
} catch (PDOException $e) {
    echo "Error modifying column: " . $e->getMessage() . "<br>";
}
?>
