<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include_once '../../../config/database.php';

$dosen_id = isset($_GET['dosen_id']) ? $_GET['dosen_id'] : die("Missing dosen_id");

if (!isset($conn)) {
    die("Database connection failed: \$conn is not set.");
}

try {
    $query = "SELECT cs.id, cs.course_id, cs.dosen_id, u.name as dosen_name,
                     c.name as course_name, c.code as course_code, c.sks, 
                     cs.section, cs.day, cs.time_start, cs.time_end, cs.room, cs.quota,
                     (SELECT COUNT(*) FROM enrollments e WHERE e.class_id = cs.id) as enrolled_count
              FROM classes cs
              JOIN courses c ON cs.course_id = c.id
              JOIN users u ON cs.dosen_id = u.id
              WHERE cs.dosen_id = ?
              ORDER BY cs.day, cs.time_start ASC";

    $stmt = $conn->prepare($query);
    $stmt->bindParam(1, $dosen_id);
    $stmt->execute();

    $classes = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(array("success" => true, "data" => $classes));
} catch(Throwable $e) {
    http_response_code(500);
    echo json_encode(array("success" => false, "message" => $e->getMessage(), "trace" => $e->getTraceAsString()));
}
?>
