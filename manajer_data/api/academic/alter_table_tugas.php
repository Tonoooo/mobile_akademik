<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include_once '../../config/database.php';

try {
    // Add deadline to materials
    $sql1 = "ALTER TABLE materials ADD COLUMN deadline DATETIME NULL AFTER type";
    $conn->exec($sql1);
    echo "Column 'deadline' added to 'materials' table.<br>";
} catch (PDOException $e) {
    echo "Error adding deadline: " . $e->getMessage() . "<br>";
}

try {
    // Add answer to submissions
    $sql2 = "ALTER TABLE submissions ADD COLUMN answer TEXT NULL AFTER file_url";
    $conn->exec($sql2);
    echo "Column 'answer' added to 'submissions' table.<br>";
} catch (PDOException $e) {
    echo "Error adding answer: " . $e->getMessage() . "<br>";
}

echo "Database alteration completed.";
?>
