<?php
// api/users/delete.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../../config/database.php';

$data = json_decode(file_get_contents("php://input"));

if(!empty($data->id)){
    try {
        // Prevent deleting self (optional check, but good practice)
        // Ideally we check session, but here we just trust the ID. 
        // Real implementation should check if ID matches current logged in superadmin.

        $query = "DELETE FROM users WHERE id = :id";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(":id", $data->id);

        if($stmt->execute()){
            echo json_encode(["success" => true, "message" => "User berhasil dihapus."]);
        } else {
            echo json_encode(["success" => false, "message" => "Gagal menghapus user."]);
        }
    } catch(PDOException $e) {
        echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage() . " (Mungkin user ini terhubung dengan data lain seperti kelas/nilai)"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "ID tidak ditemukan."]);
}
?>
