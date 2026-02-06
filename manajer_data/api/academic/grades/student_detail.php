<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../../../config/database.php';

$class_id = isset($_GET['class_id']) ? $_GET['class_id'] : '';
$student_id = isset($_GET['student_id']) ? $_GET['student_id'] : '';

if (empty($class_id) || empty($student_id)) {
    echo json_encode(array("success" => false, "message" => "Parameters required"));
    exit();
}

try {
    // 1. Calculate Attendance (30%)
    // Get total sessions
    $querySessions = "SELECT COUNT(*) as total FROM attendance_sessions WHERE class_id = ?";
    $stmtSess = $conn->prepare($querySessions);
    $stmtSess->bindParam(1, $class_id);
    $stmtSess->execute();
    $totalSessions = $stmtSess->fetch(PDO::FETCH_ASSOC)['total'];

    // Get student presence
    $queryPresence = "SELECT COUNT(*) as present FROM attendance_records r
                      JOIN attendance_sessions s ON r.session_id = s.id
                      WHERE s.class_id = ? AND r.student_id = ? AND r.status = 'H'";
    $stmtPres = $conn->prepare($queryPresence);
    $stmtPres->bindParam(1, $class_id);
    $stmtPres->bindParam(2, $student_id);
    $stmtPres->execute();
    $presentCount = $stmtPres->fetch(PDO::FETCH_ASSOC)['present'];

    $attendanceScore = 0;
    if ($totalSessions > 0) {
        $attendanceScore = ($presentCount / $totalSessions) * 100;
    }

    // 2. Calculate Tasks (40%)
    // Get all tasks
    $queryTasks = "SELECT id, title FROM materials WHERE class_id = ? AND type = 'tugas'";
    $stmtTasks = $conn->prepare($queryTasks);
    $stmtTasks->bindParam(1, $class_id);
    $stmtTasks->execute();
    $tasks = $stmtTasks->fetchAll(PDO::FETCH_ASSOC);

    $totalTaskScore = 0;
    $taskCount = count($tasks);
    $taskDetails = [];

    foreach ($tasks as $task) {
        // Get submission score
        $querySub = "SELECT grade FROM submissions WHERE material_id = ? AND student_id = ?";
        $stmtSub = $conn->prepare($querySub);
        $stmtSub->bindParam(1, $task['id']);
        $stmtSub->bindParam(2, $student_id);
        $stmtSub->execute();
        $sub = $stmtSub->fetch(PDO::FETCH_ASSOC);
        
        $score = $sub ? floatval($sub['grade']) : 0;
        $totalTaskScore += $score;
        $taskDetails[] = [
            'title' => $task['title'],
            'score' => $score
        ];
    }
    
    $avgTaskScore = $taskCount > 0 ? $totalTaskScore / $taskCount : 0;

    // 3. Calculate Exams (30%)
    // Get all exams
    $queryExams = "SELECT id, title FROM materials WHERE class_id = ? AND type = 'ujian'";
    $stmtExams = $conn->prepare($queryExams);
    $stmtExams->bindParam(1, $class_id);
    $stmtExams->execute();
    $exams = $stmtExams->fetchAll(PDO::FETCH_ASSOC);

    $totalExamScore = 0;
    $examCount = count($exams);
    $examDetails = [];

    foreach ($exams as $exam) {
        $querySub = "SELECT grade FROM submissions WHERE material_id = ? AND student_id = ?";
        $stmtSub = $conn->prepare($querySub);
        $stmtSub->bindParam(1, $exam['id']);
        $stmtSub->bindParam(2, $student_id);
        $stmtSub->execute();
        $sub = $stmtSub->fetch(PDO::FETCH_ASSOC);

        $score = $sub ? floatval($sub['grade']) : 0;
        $totalExamScore += $score;
        $examDetails[] = [
            'title' => $exam['title'],
            'score' => $score
        ];
    }

    $avgExamScore = $examCount > 0 ? $totalExamScore / $examCount : 0;

    // 4. Final Calculation
    // Bobot: Absen 30%, Tugas 40%, Ujian 30%
    $finalScore = ($attendanceScore * 0.30) + ($avgTaskScore * 0.40) + ($avgExamScore * 0.30);

    // Get Enrollment ID & Stored Grade
    $queryEnrol = "SELECT id, grade FROM enrollments WHERE class_id = ? AND student_id = ?";
    $stmtEnrol = $conn->prepare($queryEnrol);
    $stmtEnrol->bindParam(1, $class_id);
    $stmtEnrol->bindParam(2, $student_id);
    $stmtEnrol->execute();
    $enrollment = $stmtEnrol->fetch(PDO::FETCH_ASSOC);

    $response = [
        'success' => true,
        'data' => [
            'student_id' => $student_id,
            'enrollment_id' => $enrollment['id'],
            'stored_grade' => $enrollment['grade'],
            'attendance' => [
                'total_sessions' => $totalSessions,
                'present_count' => $presentCount,
                'score' => $attendanceScore
            ],
            'tasks' => [
                'items' => $taskDetails,
                'average' => $avgTaskScore
            ],
            'exams' => [
                'items' => $examDetails,
                'average' => $avgExamScore
            ],
            'final_score_calculated' => $finalScore
        ]
    ];

    echo json_encode($response);

} catch (PDOException $e) {
    echo json_encode(array("success" => false, "message" => $e->getMessage()));
}
?>
