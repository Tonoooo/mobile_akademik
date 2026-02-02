<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../../config/database.php';

$class_session_id = isset($_GET['class_session_id']) ? $_GET['class_session_id'] : die();

try {
    $query = "SELECT * FROM materials WHERE class_id = ? ORDER BY created_at DESC";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(1, $class_session_id);
    $stmt->execute();

    $materials = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(array("success" => true, "data" => $materials));
} catch(PDOException $e) {
    echo json_encode(array("success" => false, "message" => $e->getMessage()));
}
?>
