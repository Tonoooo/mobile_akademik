<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../../../config/database.php';

$session_id = isset($_GET['session_id']) ? $_GET['session_id'] : '';

if (empty($session_id)) {
    echo json_encode(array("success" => false, "message" => "Session ID required"));
    exit();
}

try {
    // Get Session Info
    $querySession = "SELECT * FROM attendance_sessions WHERE id = ?";
    $stmtSession = $conn->prepare($querySession);
    $stmtSession->bindParam(1, $session_id);
    $stmtSession->execute();
    $session = $stmtSession->fetch(PDO::FETCH_ASSOC);

    if (!$session) {
        echo json_encode(array("success" => false, "message" => "Session not found"));
        exit();
    }

    // Get Records with Student Info
    $queryRecords = "SELECT r.*, u.name as student_name, u.username as student_nim 
                     FROM attendance_records r
                     JOIN users u ON r.student_id = u.id
                     WHERE r.session_id = ?
                     ORDER BY u.name ASC";
    $stmtRecords = $conn->prepare($queryRecords);
    $stmtRecords->bindParam(1, $session_id);
    $stmtRecords->execute();
    $records = $stmtRecords->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(array("success" => true, "data" => array(
        "session" => $session,
        "records" => $records
    )));
} catch(PDOException $e) {
    echo json_encode(array("success" => false, "message" => $e->getMessage()));
}
?>
