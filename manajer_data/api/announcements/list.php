<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../../config/database.php';

try {
    $query = "SELECT a.*, u.name as author_name 
              FROM announcements a
              LEFT JOIN users u ON a.created_by = u.id
              ORDER BY a.created_at DESC";

    $stmt = $conn->prepare($query);
    $stmt->execute();
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(array("success" => true, "data" => $data));

} catch (PDOException $e) {
    echo json_encode(array("success" => false, "message" => $e->getMessage()));
}
?>
