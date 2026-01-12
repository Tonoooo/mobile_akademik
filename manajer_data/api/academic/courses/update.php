<?php
// api/academic/courses/update.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../../../config/database.php';

$data = json_decode(file_get_contents("php://input"));

if(!empty($data->id) && !empty($data->code) && !empty($data->name) && !empty($data->sks) && !empty($data->semester) && !empty($data->major_id)){
    try {
        // Check if code exists for OTHER course
        $check = $conn->prepare("SELECT id FROM courses WHERE code = ? AND id != ?");
        $check->execute([$data->code, $data->id]);
        
        if($check->rowCount() > 0){
            echo json_encode(["success" => false, "message" => "Kode Mata Kuliah sudah digunakan."]);
            exit();
        }

        $query = "UPDATE courses SET code=:code, name=:name, sks=:sks, semester=:semester, major_id=:major_id WHERE id=:id";
        $stmt = $conn->prepare($query);

        $stmt->bindParam(":code", $data->code);
        $stmt->bindParam(":name", $data->name);
        $stmt->bindParam(":sks", $data->sks);
        $stmt->bindParam(":semester", $data->semester);
        $stmt->bindParam(":major_id", $data->major_id);
        $stmt->bindParam(":id", $data->id);

        if($stmt->execute()){
            echo json_encode(["success" => true, "message" => "Mata Kuliah berhasil diupdate."]);
        } else {
            echo json_encode(["success" => false, "message" => "Gagal update mata kuliah."]);
        }
    } catch(PDOException $e) {
        echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage()]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Data tidak lengkap."]);
}
?>
