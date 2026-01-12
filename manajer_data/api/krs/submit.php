<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

include_once '../../config/database.php';

// $conn is defined in database.php
$db = $conn;

$data = json_decode(file_get_contents("php://input"));

if (!isset($data->student_id)) {
    http_response_code(400);
    echo json_encode(array("success" => false, "message" => "Incomplete data."));
    exit();
}

// Update status to 'submitted'
$query = "UPDATE users SET krs_status = 'submitted' WHERE id = :id AND role = 'mahasiswa'";
$stmt = $db->prepare($query);
$stmt->bindParam(":id", $data->student_id);

if ($stmt->execute()) {
    http_response_code(200);
    echo json_encode(array("success" => true, "message" => "KRS submitted successfully."));
} else {
    http_response_code(503);
    echo json_encode(array("success" => false, "message" => "Unable to submit KRS."));
}
?>
