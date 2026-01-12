<?php
// api/users/count_role.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once '../../config/database.php';

try {
    $query = "SELECT role, COUNT(*) as total FROM users GROUP BY role";
    $stmt = $conn->prepare($query);
    $stmt->execute();
    
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Format result as key-value pair for easier frontend consumption
    $counts = [
        'mahasiswa' => 0,
        'dosen' => 0,
        'admin' => 0,
        'keuangan' => 0,
        'superadmin' => 0
    ];

    foreach ($results as $row) {
        $counts[$row['role']] = (int)$row['total'];
    }

    echo json_encode([
        "success" => true,
        "data" => $counts
    ]);

} catch(PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}
?>
