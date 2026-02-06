<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include_once '../../../config/database.php';

$material_id = isset($_GET['material_id']) ? $_GET['material_id'] : die();

try {
    $query = "SELECT s.*, u.name as student_name, u.username as student_nim 
              FROM submissions s
              JOIN users u ON s.student_id = u.id
              WHERE s.material_id = ?
              ORDER BY s.submitted_at DESC";
              
    $stmt = $conn->prepare($query);
    $stmt->bindParam(1, $material_id);
    $stmt->execute();

    $submissions = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(array("success" => true, "data" => $submissions));
} catch(PDOException $e) {
    echo json_encode(array("success" => false, "message" => $e->getMessage()));
}
?>
