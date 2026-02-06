<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../../../config/database.php';

$student_id = isset($_GET['student_id']) ? $_GET['student_id'] : '';

if (empty($student_id)) {
    echo json_encode(array("success" => false, "message" => "Student ID required"));
    exit();
}

try {
    $query = "SELECT e.class_id, e.grade, c.course_name, c.course_code, c.sks, c.semester
              FROM enrollments e
              JOIN (
                  SELECT cs.id, co.name as course_name, co.code as course_code, co.sks, co.semester
                  FROM classes cs
                  JOIN courses co ON cs.course_id = co.id
              ) c ON e.class_id = c.id
              WHERE e.student_id = ? AND e.status = 'active'
              ORDER BY c.semester DESC, c.course_name ASC";

    $stmt = $conn->prepare($query);
    $stmt->bindParam(1, $student_id);
    $stmt->execute();

    $grades = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(array("success" => true, "data" => $grades));

} catch (PDOException $e) {
    echo json_encode(array("success" => false, "message" => $e->getMessage()));
}
?>
