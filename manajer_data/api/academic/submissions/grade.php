<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include_once '../../../config/database.php';

$response = array("success" => false, "message" => "");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $data = json_decode(file_get_contents("php://input"));
    
    if (isset($data->submission_id) && isset($data->grade)) {
        try {
            $query = "UPDATE submissions SET grade = :grade WHERE id = :id";
            $stmt = $conn->prepare($query);
            
            $stmt->bindParam(':grade', $data->grade);
            $stmt->bindParam(':id', $data->submission_id);
            
            if ($stmt->execute()) {
                $response['success'] = true;
                $response['message'] = "Nilai berhasil disimpan.";
            } else {
                $response['message'] = "Gagal menyimpan nilai.";
            }
        } catch(PDOException $e) {
            $response['message'] = "Database error: " . $e->getMessage();
        }
    } else {
        $response['message'] = "Data tidak lengkap.";
    }
}

echo json_encode($response);
?>
