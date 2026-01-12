<?php
// api/finance/validate_payment.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../../config/database.php';

$data = json_decode(file_get_contents("php://input"));

if(!empty($data->student_id) && !empty($data->status)){
    try {
        // Status should be 'paid' or 'unpaid'
        $query = "UPDATE users SET payment_status = :status WHERE id = :id AND role = 'mahasiswa'";
        $stmt = $conn->prepare($query);

        $stmt->bindParam(":status", $data->status);
        $stmt->bindParam(":id", $data->student_id);

        if($stmt->execute()){
            if($stmt->rowCount() > 0) {
                echo json_encode(["success" => true, "message" => "Status pembayaran berhasil diupdate."]);
            } else {
                echo json_encode(["success" => false, "message" => "User tidak ditemukan atau bukan mahasiswa."]);
            }
        } else {
            echo json_encode(["success" => false, "message" => "Gagal update status."]);
        }
    } catch(PDOException $e) {
        echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage()]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Data tidak lengkap."]);
}
?>
