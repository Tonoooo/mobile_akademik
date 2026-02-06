<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../../../config/database.php';

$class_id = isset($_GET['class_id']) ? $_GET['class_id'] : '';

if (empty($class_id)) {
    echo json_encode(array("success" => false, "message" => "Class ID required"));
    exit();
}

try {
    $query = "SELECT e.*, c.course_name, c.course_code, s.name as student_name, s.username as student_nim 
              FROM enrollments e
              JOIN classes cs ON e.class_id = cs.id
              JOIN (
                  SELECT cs.id, co.name as course_name, co.code as course_code
                  FROM classes cs
                  JOIN courses co ON cs.course_id = co.id
              ) c ON cs.id = c.id
              JOIN users s ON e.student_id = s.id
              WHERE e.class_id = ?";
              
    $stmt = $conn->prepare($query);
    $stmt->bindParam(1, $class_id);
    $stmt->execute();

    $enrollments = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(array("success" => true, "data" => $enrollments));
} catch(PDOException $e) {
    echo json_encode(array("success" => false, "message" => "Database error: " . $e->getMessage()));
}
?>
