<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include_once '../../../config/database.php';

$material_id = isset($_GET['material_id']) ? $_GET['material_id'] : '';
$student_id = isset($_GET['student_id']) ? $_GET['student_id'] : '';

if (empty($material_id) || empty($student_id)) {
    echo json_encode(array("success" => false, "message" => "Missing parameters"));
    exit();
}

try {
    $query = "SELECT * FROM submissions WHERE material_id = ? AND student_id = ? LIMIT 1";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(1, $material_id);
    $stmt->bindParam(2, $student_id);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        $submission = $stmt->fetch(PDO::FETCH_ASSOC);
        echo json_encode(array("success" => true, "data" => $submission));
    } else {
        echo json_encode(array("success" => true, "data" => null));
    }
} catch(PDOException $e) {
    echo json_encode(array("success" => false, "message" => $e->getMessage()));
}
?>
