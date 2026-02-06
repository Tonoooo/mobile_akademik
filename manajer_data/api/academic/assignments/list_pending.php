<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../../../config/database.php';

$student_id = $_GET['student_id'] ?? '';

if (empty($student_id)) {
    echo json_encode(array("success" => false, "message" => "Student ID required"));
    exit();
}

try {
    // Logic:
    // 1. Get student's enrolled classes.
    // 2. Get materials from those classes where type = 'tugas'.
    // 3. Exclude materials where this student has a submission.
    
    $query = "SELECT 
                m.id, 
                m.class_id, 
                m.title, 
                m.description, 
                m.file_url, 
                m.type, 
                m.created_at, 
                m.deadline,
                c.course_code,
                c.course_name,
                c.course_sks
              FROM materials m
              JOIN enrollments e ON m.class_id = e.class_id
              JOIN classes cls ON m.class_id = cls.id
              JOIN courses c ON cls.course_id = c.id
              LEFT JOIN submissions s ON m.id = s.material_id AND s.student_id = :student_id
              WHERE e.student_id = :student_id2
                AND m.type = 'tugas'
                AND s.id IS NULL
              ORDER BY m.deadline ASC";

    $stmt = $conn->prepare($query);
    $stmt->bindParam(':student_id', $student_id);
    $stmt->bindParam(':student_id2', $student_id);
    $stmt->execute();
    
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(array("success" => true, "data" => $data));

} catch (PDOException $e) {
    echo json_encode(array("success" => false, "message" => $e->getMessage()));
}
?>
