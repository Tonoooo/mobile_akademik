<?php
// api/users/read.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once '../../config/database.php';

$role = isset($_GET['role']) ? $_GET['role'] : '';

try {
    $id = isset($_GET['id']) ? $_GET['id'] : null;
    $role = isset($_GET['role']) ? $_GET['role'] : null;

    $query = "SELECT u.id, u.username, u.name, u.role, u.created_at, u.major_id, u.payment_status, u.dosen_wali_id, u.krs_status, 
              m.name as major_name, d.name as dosen_wali_name
              FROM users u 
              LEFT JOIN majors m ON u.major_id = m.id
              LEFT JOIN users d ON u.dosen_wali_id = d.id";
    
    $conditions = [];
    $params = [];

    if (!empty($id)) {
        $conditions[] = "u.id = ?";
        $params[] = $id;
    }
    
    if (!empty($role)) {
        $conditions[] = "u.role = ?";
        $params[] = $role;
    }

    if (!empty($conditions)) {
        $query .= " WHERE " . implode(" AND ", $conditions);
    }

    $query .= " ORDER BY u.name ASC";

    $stmt = $conn->prepare($query);
    $stmt->execute($params);

    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "success" => true,
        "data" => $users
    ]);

} catch(PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}
?>
