<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../../../config/database.php';

$class_id = isset($_GET['class_id']) ? $_GET['class_id'] : '';

if (empty($class_id)) {
    echo json_encode(array("success" => false, "message" => "Class ID required"));
    exit();
}

try {
    // Get list of students and their final grade if set
    $query = "SELECT e.id as enrollment_id, e.student_id, e.grade, u.name as student_name, u.username as student_nim
              FROM enrollments e
              JOIN users u ON e.student_id = u.id
              WHERE e.class_id = ? AND e.status = 'active'
              ORDER BY u.name ASC";

    $stmt = $conn->prepare($query);
    $stmt->bindParam(1, $class_id);
    $stmt->execute();

    $students = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Get total sessions for the class
    $querySessions = "SELECT COUNT(*) as total FROM attendance_sessions WHERE class_id = ?";
    $stmtSess = $conn->prepare($querySessions);
    $stmtSess->bindParam(1, $class_id);
    $stmtSess->execute();
    $totalSessions = $stmtSess->fetch(PDO::FETCH_ASSOC)['total'];

    // Get all tasks and exams for the class to check submissions against
    // Optimization: We could fetch all submissions for the class in one go, but loop is simpler for now.

    // Helper to calc average
    function getAverageScore($conn, $class_id, $student_id, $type) {
         $queryItems = "SELECT id FROM materials WHERE class_id = ? AND type = ?";
         $stmtItems = $conn->prepare($queryItems);
         $stmtItems->bindParam(1, $class_id);
         $stmtItems->bindParam(2, $type);
         $stmtItems->execute();
         $items = $stmtItems->fetchAll(PDO::FETCH_ASSOC);
         
         if (count($items) == 0) return 0;
         
         $totalScore = 0;
         foreach ($items as $item) {
             $querySub = "SELECT grade FROM submissions WHERE material_id = ? AND student_id = ?";
             $stmtSub = $conn->prepare($querySub);
             $stmtSub->bindParam(1, $item['id']);
             $stmtSub->bindParam(2, $student_id);
             $stmtSub->execute();
             $sub = $stmtSub->fetch(PDO::FETCH_ASSOC);
             $totalScore += ($sub ? floatval($sub['grade']) : 0);
         }
         return $totalScore / count($items);
    }

    foreach ($students as &$student) {
        $sid = $student['student_id'];
        
        // 1. Attendance (30%)
        $queryPresence = "SELECT COUNT(*) as present FROM attendance_records r
                          JOIN attendance_sessions s ON r.session_id = s.id
                          WHERE s.class_id = ? AND r.student_id = ? AND r.status = 'H'";
        $stmtPres = $conn->prepare($queryPresence);
        $stmtPres->bindParam(1, $class_id);
        $stmtPres->bindParam(2, $sid);
        $stmtPres->execute();
        $presentCount = $stmtPres->fetch(PDO::FETCH_ASSOC)['present'];
        
        $attendanceScore = ($totalSessions > 0) ? ($presentCount / $totalSessions) * 100 : 0;

        // 2. Tasks (40%) and 3. Exams (30%)
        $avgTaskScore = getAverageScore($conn, $class_id, $sid, 'tugas');
        $avgExamScore = getAverageScore($conn, $class_id, $sid, 'ujian');

        $finalScore = ($attendanceScore * 0.30) + ($avgTaskScore * 0.40) + ($avgExamScore * 0.30);
        
        $student['calculated_score'] = $finalScore;
    }

    echo json_encode(array("success" => true, "data" => $students));

} catch (PDOException $e) {
    echo json_encode(array("success" => false, "message" => $e->getMessage()));
}
?>
