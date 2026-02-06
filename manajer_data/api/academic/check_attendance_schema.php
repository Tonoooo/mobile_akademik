<?php
include_once '../../config/database.php';

$tables = ['attendance_sessions', 'attendance_records'];
$results = [];

foreach ($tables as $table) {
    try {
        $query = "DESCRIBE $table";
        $stmt = $conn->prepare($query);
        $stmt->execute();
        $results[$table] = $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        $results[$table] = "Table does not exist or error: " . $e->getMessage();
    }
}

echo json_encode($results, JSON_PRETTY_PRINT);
?>
