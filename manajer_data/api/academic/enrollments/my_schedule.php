<?php
// api/academic/enrollments/my_schedule.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once '../../../config/database.php';

$student_id = isset($_GET['student_id']) ? $_GET['student_id'] : null;

if($student_id){
    try {
        $query = "SELECT 
                    e.id as enrollment_id,
                    e.status,
                    e.grade,
                    c.id as class_id,
                    c.section,
                    c.day,
                    c.time_start,
                    c.time_end,
                    c.room,
                    co.name as course_name,
                    co.code as course_code,
                    co.sks as course_sks,
                    co.semester as course_semester,
                    u.name as dosen_name
                  FROM enrollments e
                  JOIN classes c ON e.class_id = c.id
                  JOIN courses co ON c.course_id = co.id
                  JOIN users u ON c.dosen_id = u.id
                  WHERE e.student_id = :student_id AND e.status = 'active'
                  ORDER BY c.day, c.time_start ASC";

        $stmt = $conn->prepare($query);
        $stmt->bindParam(":student_id", $student_id);
        $stmt->execute();
        
        $schedule = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            "success" => true,
            "data" => $schedule
        ]);

    } catch(PDOException $e) {
        echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage()]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Student ID required."]);
}
?>
