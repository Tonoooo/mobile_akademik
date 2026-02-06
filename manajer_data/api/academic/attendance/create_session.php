<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

include_once '../../../config/database.php';

$data = json_decode(file_get_contents("php://input"));

if (isset($data->class_id) && isset($data->title) && isset($data->meeting_number) && isset($data->students)) {
    try {
        $conn->beginTransaction();

        // 1. Create Session
        $querySession = "INSERT INTO attendance_sessions (class_id, title, meeting_number, created_at) VALUES (:class_id, :title, :meeting_number, NOW())";
        $stmtSession = $conn->prepare($querySession);
        $stmtSession->bindParam(':class_id', $data->class_id);
        $stmtSession->bindParam(':title', $data->title);
        $stmtSession->bindParam(':meeting_number', $data->meeting_number);
        $stmtSession->execute();
        $session_id = $conn->lastInsertId();

        // 2. Create Records
        $queryRecord = "INSERT INTO attendance_records (session_id, student_id, status, created_at) VALUES (:session_id, :student_id, :status, NOW())";
        $stmtRecord = $conn->prepare($queryRecord);

        foreach ($data->students as $student) {
            $stmtRecord->bindParam(':session_id', $session_id);
            $stmtRecord->bindParam(':student_id', $student->student_id);
            $stmtRecord->bindParam(':status', $student->status); // H, S, I, A
            $stmtRecord->execute();
        }

        $conn->commit();
        echo json_encode(array("success" => true, "message" => "Absensi berhasil dibuat."));
    } catch (Exception $e) {
        $conn->rollBack();
        echo json_encode(array("success" => false, "message" => "Error: " . $e->getMessage()));
    }
} else {
    echo json_encode(array("success" => false, "message" => "Data tidak lengkap."));
}
?>
