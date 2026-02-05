<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include_once '../../../config/database.php';

$class_session_id = isset($_GET['class_session_id']) ? $_GET['class_session_id'] : die();

try {
    $type = isset($_GET['type']) ? $_GET['type'] : '';

    if (!empty($type)) {
        $query = "SELECT * FROM materials WHERE class_id = ? AND type = ? ORDER BY created_at DESC";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(1, $class_session_id);
        $stmt->bindParam(2, $type);
    } else {
        $query = "SELECT * FROM materials WHERE class_id = ? ORDER BY created_at DESC";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(1, $class_session_id);
    }
    
    $stmt->execute();

    $materials = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(array("success" => true, "data" => $materials));
} catch(PDOException $e) {
    echo json_encode(array("success" => false, "message" => $e->getMessage()));
}
?>
