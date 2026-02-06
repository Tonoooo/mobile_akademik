<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../../../config/database.php';

$student_id = isset($_GET['student_id']) ? $_GET['student_id'] : '';

if (empty($student_id)) {
    echo json_encode(array("success" => false, "message" => "Student ID required"));
    exit();
}

try {
    // Aggregate status counts per class
    $query = "SELECT 
                c.id as class_id, 
                c.course_name, 
                c.course_code,
                COUNT(r.id) as total_meetings,
                SUM(CASE WHEN r.status = 'H' THEN 1 ELSE 0 END) as total_hadir,
                SUM(CASE WHEN r.status = 'S' THEN 1 ELSE 0 END) as total_sakit,
                SUM(CASE WHEN r.status = 'I' THEN 1 ELSE 0 END) as total_izin,
                SUM(CASE WHEN r.status = 'A' THEN 1 ELSE 0 END) as total_alpha
              FROM enrollments e
              JOIN class_sessions cs ON e.class_id = cs.id
              LEFT JOIN attendance_sessions s ON s.class_id = cs.id
              LEFT JOIN attendance_records r ON r.session_id = s.id AND r.student_id = e.student_id
              JOIN (
                  SELECT cs.id, co.name as course_name, co.code as course_code
                  FROM class_sessions cs
                  JOIN courses co ON cs.course_id = co.id
              ) c ON e.class_id = c.id
              WHERE e.student_id = ?
              GROUP BY c.id, c.course_name, c.course_code";
              
    $stmt = $conn->prepare($query);
    $stmt->bindParam(1, $student_id);
    $stmt->execute();

    $summary = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(array("success" => true, "data" => $summary));
} catch(PDOException $e) {
    echo json_encode(array("success" => false, "message" => $e->getMessage()));
}
?>
