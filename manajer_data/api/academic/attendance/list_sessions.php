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
    $query = "SELECT * FROM attendance_sessions WHERE class_id = ? ORDER BY meeting_number DESC";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(1, $class_id);
    $stmt->execute();

    $sessions = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(array("success" => true, "data" => $sessions));
} catch(PDOException $e) {
    echo json_encode(array("success" => false, "message" => $e->getMessage()));
}
?>
