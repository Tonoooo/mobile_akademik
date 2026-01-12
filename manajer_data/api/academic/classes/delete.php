<?php
// api/academic/classes/delete.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../../../config/database.php';

$data = json_decode(file_get_contents("php://input"));

if(!empty($data->id)){
    try {
        $query = "DELETE FROM classes WHERE id = :id";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(":id", $data->id);

        if($stmt->execute()){
            echo json_encode(["success" => true, "message" => "Kelas berhasil dihapus."]);
        } else {
            echo json_encode(["success" => false, "message" => "Gagal menghapus kelas."]);
        }
    } catch(PDOException $e) {
        echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage() . " (Mungkin kelas ini sudah ada mahasiswa yang mengambil/KRS)"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "ID tidak ditemukan."]);
}
?>
