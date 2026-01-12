<?php
// api/academic/majors/read.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once '../../../config/database.php';

try {
    $query = "SELECT * FROM majors ORDER BY name ASC";
    $stmt = $conn->prepare($query);
    $stmt->execute();
    
    $majors = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "success" => true,
        "data" => $majors
    ]);

} catch(PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}
?>
