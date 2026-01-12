<?php
// api/academic/enrollments/enroll.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../../../config/database.php';

$data = json_decode(file_get_contents("php://input"));

if(!empty($data->student_id) && !empty($data->class_id)){
    try {
        $conn->beginTransaction();

        // 1. Check if already enrolled (active)
        $check = $conn->prepare("SELECT id FROM enrollments WHERE student_id = ? AND class_id = ? AND status = 'active'");
        $check->execute([$data->student_id, $data->class_id]);
        
        if($check->rowCount() > 0){
            echo json_encode(["success" => false, "message" => "Anda sudah mengambil kelas ini."]);
            $conn->rollBack();
            exit();
        }

        // 2. Check Quota
        $classQuery = $conn->prepare("SELECT quota, (SELECT COUNT(*) FROM enrollments WHERE class_id = ? AND status = 'active') as enrolled FROM classes WHERE id = ?");
        $classQuery->execute([$data->class_id, $data->class_id]);
        $classInfo = $classQuery->fetch(PDO::FETCH_ASSOC);

        if(!$classInfo){
            echo json_encode(["success" => false, "message" => "Kelas tidak ditemukan."]);
            $conn->rollBack();
            exit();
        }

        if($classInfo['enrolled'] >= $classInfo['quota']){
            echo json_encode(["success" => false, "message" => "Kelas penuh."]);
            $conn->rollBack();
            exit();
        }

        // 3. Insert Enrollment
        $insert = $conn->prepare("INSERT INTO enrollments (student_id, class_id, status) VALUES (:student_id, :class_id, 'active')");
        $insert->bindParam(":student_id", $data->student_id);
        $insert->bindParam(":class_id", $data->class_id);
        
        if($insert->execute()){
            $conn->commit();
            echo json_encode(["success" => true, "message" => "Berhasil mengambil mata kuliah (KRS)."]);
        } else {
            $conn->rollBack();
            echo json_encode(["success" => false, "message" => "Gagal mengambil mata kuliah."]);
        }

    } catch(PDOException $e) {
        $conn->rollBack();
        echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage()]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Data tidak lengkap."]);
}
?>
