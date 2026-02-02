<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

include_once '../../config/database.php';

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->id)) {
    try {
        // Get file url first to delete file
        $query = "SELECT file_url FROM materials WHERE id = ?";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(1, $data->id);
        $stmt->execute();
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($row) {
            $file_url = $row['file_url'];
            // Extract filename from URL
            $filename = basename($file_url);
            $file_path = "../../../uploads/materials/" . $filename;
            
            // Delete record
            $deleteQuery = "DELETE FROM materials WHERE id = ?";
            $deleteStmt = $conn->prepare($deleteQuery);
            $deleteStmt->bindParam(1, $data->id);
            
            if ($deleteStmt->execute()) {
                // Delete file if exists
                if (file_exists($file_path)) {
                    unlink($file_path);
                }
                echo json_encode(array("success" => true, "message" => "Materi berhasil dihapus."));
            } else {
                echo json_encode(array("success" => false, "message" => "Gagal menghapus data dari database."));
            }
        } else {
            echo json_encode(array("success" => false, "message" => "Materi tidak ditemukan."));
        }
    } catch(PDOException $e) {
        echo json_encode(array("success" => false, "message" => $e->getMessage()));
    }
} else {
    echo json_encode(array("success" => false, "message" => "ID tidak ditemukan."));
}
?>
