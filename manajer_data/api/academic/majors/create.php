<?php
// api/academic/majors/create.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../../../config/database.php';

$data = json_decode(file_get_contents("php://input"));

if(!empty($data->code) && !empty($data->name)){
    try {
        // Check if code exists
        $check = $conn->prepare("SELECT id FROM majors WHERE code = ?");
        $check->execute([$data->code]);
        
        if($check->rowCount() > 0){
            echo json_encode(["success" => false, "message" => "Kode Jurusan sudah ada."]);
            exit();
        }

        $query = "INSERT INTO majors (code, name) VALUES (:code, :name)";
        $stmt = $conn->prepare($query);

        $stmt->bindParam(":code", $data->code);
        $stmt->bindParam(":name", $data->name);

        if($stmt->execute()){
            echo json_encode(["success" => true, "message" => "Jurusan berhasil dibuat."]);
        } else {
            echo json_encode(["success" => false, "message" => "Gagal membuat jurusan."]);
        }
    } catch(PDOException $e) {
        echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage()]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Data tidak lengkap."]);
}
?>
