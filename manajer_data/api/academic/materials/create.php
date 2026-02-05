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
    
    if (isset($_FILES['file']) && isset($_POST['class_session_id']) && isset($_POST['title']) && isset($_POST['type'])) {
        
        $class_session_id = $_POST['class_session_id'];
        $title = $_POST['title'];
        $description = isset($_POST['description']) ? $_POST['description'] : '';
        $type = $_POST['type']; // 'materi', 'tugas', 'ujian'
        
        $target_dir = "../../../uploads/materials/";
        
        // Create directory if not exists
        if (!file_exists($target_dir)) {
            mkdir($target_dir, 0777, true);
        }
        
        $file_extension = strtolower(pathinfo($_FILES["file"]["name"], PATHINFO_EXTENSION));
        $new_filename = uniqid() . '_' . time() . '.' . $file_extension;
        $target_file = $target_dir . $new_filename;
        
        // Allow certain file formats
        $allowed_types = array('pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'jpg', 'jpeg', 'png', 'zip', 'rar');
        if (!in_array($file_extension, $allowed_types)) {
            $response['message'] = "Format file tidak diizinkan.";
            echo json_encode($response);
            exit();
        }

        if (move_uploaded_file($_FILES["file"]["tmp_name"], $target_file)) {
            
            // File URL (Adjust base URL as needed)
            $file_url = "https://sitono.online/manajer_data/uploads/materials/" . $new_filename;
            
            try {
                $query = "INSERT INTO materials (class_id, title, description, type, file_url, created_at) 
                          VALUES (:class_id, :title, :description, :type, :file_url, NOW())";
                
                $stmt = $conn->prepare($query);
                $stmt->bindParam(':class_id', $class_session_id);
                $stmt->bindParam(':title', $title);
                $stmt->bindParam(':description', $description);
                $stmt->bindParam(':type', $type);
                $stmt->bindParam(':file_url', $file_url);
                
                if ($stmt->execute()) {
                    $response['success'] = true;
                    $response['message'] = "Materi berhasil diupload.";
                } else {
                    $response['message'] = "Gagal menyimpan data ke database.";
                    // Optional: Delete file if DB insert fails
                    unlink($target_file);
                }
            } catch(PDOException $e) {
                $response['message'] = "Database error: " . $e->getMessage();
                unlink($target_file);
            }
            
        } else {
            $response['message'] = "Gagal mengupload file.";
        }
    } else {
        $response['message'] = "Data tidak lengkap (file, class_session_id, title, type required).";
    }
} else {
    $response['message'] = "Invalid request method.";
}

echo json_encode($response);
?>
