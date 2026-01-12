<?php
// config/database.php

$host = 'localhost';
$db_name = 'akademik_db'; // Ganti sesuai nama database di hosting
$username = 'root';         // Ganti sesuai user database di hosting
$password = '';             // Ganti sesuai password database di hosting

try {
    $conn = new PDO("mysql:host=$host;dbname=$db_name", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    echo "Connection failed: " . $e->getMessage();
    die();
}
?>
