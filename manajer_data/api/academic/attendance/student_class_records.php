<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../../../config/database.php';

$student_id = isset($_GET['student_id']) ? $_GET['student_id'] : '';
$class_id = isset($_GET['class_id']) ? $_GET['class_id'] : '';

if (empty($student_id) || empty($class_id)) {
    echo json_encode(array("success" => false, "message" => "Parameters required"));
    exit();
}

try {
    $query = "SELECT s.title, s.meeting_number, s.created_at as session_date, r.status
              FROM attendance_records r
              JOIN attendance_sessions s ON r.session_id = s.id
              WHERE r.student_id = ? AND s.class_id = ?
              ORDER BY s.meeting_number ASC";
              
    $stmt = $conn->prepare($query);
    $stmt->bindParam(1, $student_id);
    $stmt->bindParam(2, $class_id);
    $stmt->execute();

    $records = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(array("success" => true, "data" => $records));
} catch(PDOException $e) {
    echo json_encode(array("success" => false, "message" => $e->getMessage()));
}
?>
