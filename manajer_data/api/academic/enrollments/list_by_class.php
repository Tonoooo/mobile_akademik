<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include_once '../../../config/database.php';

$class_id = isset($_GET['class_id']) ? $_GET['class_id'] : '';

if (empty($class_id)) {
    echo json_encode(array("success" => false, "message" => "Class ID required"));
    exit();
}

try {
    // Simplified query without subquery
    $query = "SELECT 
                e.*, 
                co.name as course_name, 
                co.code as course_code, 
                s.name as student_name, 
                s.username as student_nim 
              FROM enrollments e
              JOIN classes cls ON e.class_id = cls.id
              JOIN courses co ON cls.course_id = co.id
              JOIN users s ON e.student_id = s.id
              WHERE e.class_id = :class_id";
              
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':class_id', $class_id);
    $stmt->execute();

    $enrollments = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(array("success" => true, "data" => $enrollments));
} catch(PDOException $e) {
    echo json_encode(array("success" => false, "message" => "Database error: " . $e->getMessage()));
} catch(Exception $e) {
    echo json_encode(array("success" => false, "message" => "Error: " . $e->getMessage()));
}
?>
