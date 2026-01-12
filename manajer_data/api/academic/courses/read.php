<?php
// api/academic/courses/read.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once '../../../config/database.php';

$major_id = isset($_GET['major_id']) ? $_GET['major_id'] : null;

try {
    if ($major_id) {
        $query = "SELECT * FROM courses WHERE major_id = :major_id ORDER BY semester, name ASC";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(":major_id", $major_id);
    } else {
        $query = "SELECT * FROM courses ORDER BY name ASC";
        $stmt = $conn->prepare($query);
    }
    
    $stmt->execute();
    $courses = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "success" => true,
        "data" => $courses
    ]);

} catch(PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}
?>
