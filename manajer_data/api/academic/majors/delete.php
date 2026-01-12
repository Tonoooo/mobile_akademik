<?php
// api/academic/majors/delete.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../../../config/database.php';

$data = json_decode(file_get_contents("php://input"));

if(!empty($data->id)){
    try {
        $query = "DELETE FROM majors WHERE id = :id";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(":id", $data->id);

        if($stmt->execute()){
            echo json_encode(["success" => true, "message" => "Jurusan berhasil dihapus."]);
        } else {
            echo json_encode(["success" => false, "message" => "Gagal menghapus jurusan."]);
        }
    } catch(PDOException $e) {
        echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage() . " (Mungkin jurusan ini masih memiliki Mata Kuliah/Mahasiswa)"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "ID tidak ditemukan."]);
}
?>
