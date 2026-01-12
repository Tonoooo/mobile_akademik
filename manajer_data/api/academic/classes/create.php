<?php
// api/academic/classes/create.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../../../config/database.php';

$data = json_decode(file_get_contents("php://input"));

if(!empty($data->course_id) && !empty($data->dosen_id) && !empty($data->section) && 
   !empty($data->day) && !empty($data->time_start) && !empty($data->time_end) && !empty($data->room)){
    
    try {
        $query = "INSERT INTO classes (course_id, dosen_id, section, day, time_start, time_end, room, quota) 
                  VALUES (:course_id, :dosen_id, :section, :day, :time_start, :time_end, :room, :quota)";
        
        $stmt = $conn->prepare($query);

        $quota = !empty($data->quota) ? $data->quota : 40; // Default quota 40

        $stmt->bindParam(":course_id", $data->course_id);
        $stmt->bindParam(":dosen_id", $data->dosen_id);
        $stmt->bindParam(":section", $data->section);
        $stmt->bindParam(":day", $data->day);
        $stmt->bindParam(":time_start", $data->time_start);
        $stmt->bindParam(":time_end", $data->time_end);
        $stmt->bindParam(":room", $data->room);
        $stmt->bindParam(":quota", $quota);

        if($stmt->execute()){
            echo json_encode(["success" => true, "message" => "Kelas berhasil dibuat."]);
        } else {
            echo json_encode(["success" => false, "message" => "Gagal membuat kelas."]);
        }
    } catch(PDOException $e) {
        echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage()]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Data tidak lengkap."]);
}
?>
