<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../../config/database.php';

// $conn is defined in database.php
$db = $conn;

$dosen_id = isset($_GET['dosen_id']) ? $_GET['dosen_id'] : die();

$query = "SELECT u.id, u.username, u.name, u.major_id, u.krs_status, m.name as major_name,
          (SELECT COUNT(*) FROM enrollments e 
           JOIN class_sessions cs ON e.class_session_id = cs.id 
           WHERE e.student_id = u.id) as total_courses,
          (SELECT SUM(c.sks) FROM enrollments e 
           JOIN class_sessions cs ON e.class_session_id = cs.id 
           JOIN courses c ON cs.course_id = c.id
           WHERE e.student_id = u.id) as total_sks
          FROM users u
          LEFT JOIN majors m ON u.major_id = m.id
          WHERE u.dosen_wali_id = ? AND u.role = 'mahasiswa'
          ORDER BY u.name ASC";

$stmt = $db->prepare($query);
$stmt->bindParam(1, $dosen_id);
$stmt->execute();

$students = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode(array("success" => true, "data" => $students));
?>
