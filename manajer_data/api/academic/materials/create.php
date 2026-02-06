<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include_once '../../../config/database.php';

$response = array("success" => false, "message" => "");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    // Validate required fields
    if (isset($_POST['class_session_id']) && isset($_POST['title']) && isset($_POST['type'])) {
        
        $class_session_id = $_POST['class_session_id'];
        $title = $_POST['title'];
        $type = $_POST['type'];
        $description = isset($_POST['description']) ? $_POST['description'] : '';
        $deadline = (isset($_POST['deadline']) && $_POST['deadline'] !== '') ? $_POST['deadline'] : null;
        
        $file_url = '';

        // Handle File Upload
        if (isset($_FILES['file']) && $_FILES['file']['error'] === UPLOAD_ERR_OK) {
            $target_dir = "../../../uploads/materials/";
            if (!file_exists($target_dir)) {
                mkdir($target_dir, 0777, true);
            }
            
            $file_extension = strtolower(pathinfo($_FILES["file"]["name"], PATHINFO_EXTENSION));
            $allowed_types = array('pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'jpg', 'jpeg', 'png', 'zip', 'rar');
            
            if (!in_array($file_extension, $allowed_types)) {
                echo json_encode(array("success" => false, "message" => "Format file tidak diizinkan."));
                exit();
            }

            $new_filename = uniqid() . '_' . time() . '.' . $file_extension;
            $target_file = $target_dir . $new_filename;

            if (move_uploaded_file($_FILES["file"]["tmp_name"], $target_file)) {
                $file_url = "https://sitono.online/manajer_data/uploads/materials/" . $new_filename;
            } else {
                echo json_encode(array("success" => false, "message" => "Gagal upload file ke server."));
                exit();
            }
        }

        try {
            // Include deadline in INSERT
            $query = "INSERT INTO materials (class_id, title, description, type, file_url, deadline, created_at) 
                      VALUES (:class_id, :title, :description, :type, :file_url, :deadline, NOW())";
            
            $stmt = $conn->prepare($query);
            $stmt->bindParam(':class_id', $class_session_id);
            $stmt->bindParam(':title', $title);
            $stmt->bindParam(':description', $description);
            $stmt->bindParam(':type', $type);
            $stmt->bindParam(':file_url', $file_url);
            $stmt->bindParam(':deadline', $deadline);
            
            if ($stmt->execute()) {
                $response['success'] = true;
                $response['message'] = "Data berhasil disimpan.";
            } else {
                $response['message'] = "Gagal menyimpan data ke database.";
            }
        } catch(PDOException $e) {
            $response['message'] = "Database error: " . $e->getMessage();
        }
        
    } else {
        $response['message'] = "Data tidak lengkap (class_session_id, title, type required).";
    }
} else {
    $response['message'] = "Invalid request method.";
}

echo json_encode($response);
?>
