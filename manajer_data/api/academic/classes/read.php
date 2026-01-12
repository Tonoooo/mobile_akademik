<?php
// api/academic/classes/read.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once '../../../config/database.php';

$major_id = isset($_GET['major_id']) ? $_GET['major_id'] : null;

try {
    // Query joins classes with courses and users (dosen)
    // If major_id is provided, filter by course's major_id
    $query = "SELECT 
                c.id, 
                c.course_id, 
                c.dosen_id, 
                c.section, 
                c.day, 
                c.time_start, 
                c.time_end, 
                c.room,
                c.quota,
                (SELECT COUNT(*) FROM enrollments e WHERE e.class_id = c.id) as enrolled_count,
                co.name as course_name,
                co.code as course_code,
                co.sks as course_sks,
                co.semester as course_semester,
                u.name as dosen_name
              FROM classes c
              JOIN courses co ON c.course_id = co.id
              JOIN users u ON c.dosen_id = u.id
              WHERE 1=1";

    if ($major_id) {
        $query .= " AND co.major_id = :major_id";
    }

    $query .= " ORDER BY co.semester, co.name, c.section ASC";

    $stmt = $conn->prepare($query);
    
    if ($major_id) {
        $stmt->bindParam(":major_id", $major_id);
    }

    $stmt->execute();
    $classes = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "success" => true,
        "data" => $classes
    ]);

} catch(PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}
?>
