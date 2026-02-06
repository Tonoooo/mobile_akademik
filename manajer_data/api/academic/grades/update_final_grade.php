<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../../../config/database.php';

$data = json_decode(file_get_contents("php://input"));

if (isset($data->enrollment_id) && isset($data->grade)) {
    try {
        $query = "UPDATE enrollments SET grade = :grade WHERE id = :id";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(':grade', $data->grade);
        $stmt->bindParam(':id', $data->enrollment_id);

        if ($stmt->execute()) {
            echo json_encode(array("success" => true, "message" => "Nilai berhasil disimpan."));
        } else {
            echo json_encode(array("success" => false, "message" => "Gagal menyimpan nilai."));
        }
    } catch (PDOException $e) {
        echo json_encode(array("success" => false, "message" => $e->getMessage()));
    }
} else {
    echo json_encode(array("success" => false, "message" => "Data tidak lengkap."));
}
?>
