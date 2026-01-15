<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../../config/database.php';

// $conn is defined in database.php
$db = $conn;

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$dosen_id = isset($_GET['dosen_id']) ? $_GET['dosen_id'] : die("Missing dosen_id");

if (!isset($db)) {
    die("Database connection failed: \$db is not set.");
}

try {
    // Simplified query for debugging
    $query = "SELECT u.id, u.username, u.name, u.major_id, u.krs_status, u.role, u.payment_status, m.name as major_name
              FROM users u
              LEFT JOIN majors m ON u.major_id = m.id
              WHERE u.dosen_wali_id = ? AND u.role = 'mahasiswa'
              ORDER BY u.name ASC";

    $stmt = $db->prepare($query);
    $stmt->bindParam(1, $dosen_id);
    $stmt->execute();

    $students = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(array(
        "success" => true, 
        "data" => $students,
        "debug_dosen_id" => $dosen_id,
        "count" => count($students)
    ));
} catch(Throwable $e) {
    http_response_code(500);
    echo json_encode(array("success" => false, "message" => $e->getMessage(), "trace" => $e->getTraceAsString()));
}
?>
