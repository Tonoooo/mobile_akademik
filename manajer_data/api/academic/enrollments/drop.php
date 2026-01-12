<?php
// api/academic/enrollments/drop.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../../../config/database.php';

$data = json_decode(file_get_contents("php://input"));

if(!empty($data->student_id) && !empty($data->class_id)){
    try {
        // Update status to 'dropped' instead of deleting, to keep history
        // Or delete if you prefer clean slate. Let's use delete for simplicity in this iteration unless history is required.
        // Actually, schema has 'dropped' status. Let's use update.
        
        $query = "UPDATE enrollments SET status = 'dropped' WHERE student_id = :student_id AND class_id = :class_id";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(":student_id", $data->student_id);
        $stmt->bindParam(":class_id", $data->class_id);

        if($stmt->execute()){
            echo json_encode(["success" => true, "message" => "Mata kuliah berhasil dibatalkan."]);
        } else {
            echo json_encode(["success" => false, "message" => "Gagal membatalkan mata kuliah."]);
        }
    } catch(PDOException $e) {
        echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage()]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Data tidak lengkap."]);
}
?>
