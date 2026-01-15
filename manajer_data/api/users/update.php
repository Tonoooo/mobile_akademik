<?php
// api/users/update.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../../config/database.php';

$data = json_decode(file_get_contents("php://input"));

if(!empty($data->id) && !empty($data->username) && !empty($data->name) && !empty($data->role)){
    try {
        // Check if username exists for OTHER user
        $check = $conn->prepare("SELECT id FROM users WHERE username = ? AND id != ?");
        $check->execute([$data->username, $data->id]);
        
        if($check->rowCount() > 0){
            echo json_encode(["success" => false, "message" => "Username/NIM/NIP sudah digunakan user lain."]);
            exit();
        }

        if(!empty($data->password)){
            // Update with password
            $query = "UPDATE users SET username=:username, password=:password, name=:name, role=:role, major_id=:major_id, dosen_wali_id=:dosen_wali_id WHERE id=:id";
            $stmt = $conn->prepare($query);
            $password_hash = password_hash($data->password, PASSWORD_DEFAULT);
            $stmt->bindParam(":password", $password_hash);
        } else {
            // Update without password
            $query = "UPDATE users SET username=:username, name=:name, role=:role, major_id=:major_id, dosen_wali_id=:dosen_wali_id WHERE id=:id";
            $stmt = $conn->prepare($query);
        }

        $stmt->bindParam(":username", $data->username);
        $stmt->bindParam(":name", $data->name);
        $stmt->bindParam(":role", $data->role);
        
        // Handle major_id (can be null)
        $major_id = !empty($data->major_id) ? $data->major_id : null;
        $stmt->bindParam(":major_id", $major_id);

        // Handle dosen_wali_id (can be null)
        $dosen_wali_id = !empty($data->dosen_wali_id) ? $data->dosen_wali_id : null;
        $stmt->bindParam(":dosen_wali_id", $dosen_wali_id);

        $stmt->bindParam(":id", $data->id);

        if($stmt->execute()){
            echo json_encode(["success" => true, "message" => "User berhasil diupdate."]);
        } else {
            echo json_encode(["success" => false, "message" => "Gagal update user."]);
        }
    } catch(PDOException $e) {
        echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage()]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Data tidak lengkap."]);
}
?>
