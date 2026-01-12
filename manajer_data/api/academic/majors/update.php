<?php
// api/academic/majors/update.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../../../config/database.php';

$data = json_decode(file_get_contents("php://input"));

if(!empty($data->id) && !empty($data->code) && !empty($data->name)){
    try {
        // Check if code exists for OTHER major
        $check = $conn->prepare("SELECT id FROM majors WHERE code = ? AND id != ?");
        $check->execute([$data->code, $data->id]);
        
        if($check->rowCount() > 0){
            echo json_encode(["success" => false, "message" => "Kode Jurusan sudah digunakan."]);
            exit();
        }

        $query = "UPDATE majors SET code=:code, name=:name WHERE id=:id";
        $stmt = $conn->prepare($query);

        $stmt->bindParam(":code", $data->code);
        $stmt->bindParam(":name", $data->name);
        $stmt->bindParam(":id", $data->id);

        if($stmt->execute()){
            echo json_encode(["success" => true, "message" => "Jurusan berhasil diupdate."]);
        } else {
            echo json_encode(["success" => false, "message" => "Gagal update jurusan."]);
        }
    } catch(PDOException $e) {
        echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage()]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Data tidak lengkap."]);
}
?>
