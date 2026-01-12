<?php
// api/academic/courses/create.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../../../config/database.php';

$data = json_decode(file_get_contents("php://input"));

if(!empty($data->code) && !empty($data->name) && !empty($data->sks) && !empty($data->semester) && !empty($data->major_id)){
    try {
        // Check if code exists
        $check = $conn->prepare("SELECT id FROM courses WHERE code = ?");
        $check->execute([$data->code]);
        
        if($check->rowCount() > 0){
            echo json_encode(["success" => false, "message" => "Kode Mata Kuliah sudah ada."]);
            exit();
        }

        $query = "INSERT INTO courses (code, name, sks, semester, major_id) VALUES (:code, :name, :sks, :semester, :major_id)";
        $stmt = $conn->prepare($query);

        $stmt->bindParam(":code", $data->code);
        $stmt->bindParam(":name", $data->name);
        $stmt->bindParam(":sks", $data->sks);
        $stmt->bindParam(":semester", $data->semester);
        $stmt->bindParam(":major_id", $data->major_id);

        if($stmt->execute()){
            echo json_encode(["success" => true, "message" => "Mata Kuliah berhasil dibuat."]);
        } else {
            echo json_encode(["success" => false, "message" => "Gagal membuat mata kuliah."]);
        }
    } catch(PDOException $e) {
        echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage()]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Data tidak lengkap."]);
}
?>
