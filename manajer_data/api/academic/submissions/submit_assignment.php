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
    
    if (isset($_POST['student_id']) && isset($_POST['material_id'])) {
        
        $student_id = $_POST['student_id'];
        $material_id = $_POST['material_id'];
        $answer = isset($_POST['answer']) ? $_POST['answer'] : '';
        
        $file_url = null; // Default null
        
        // Check for existing submission
        $checkQuery = "SELECT id, file_url FROM submissions WHERE student_id = ? AND material_id = ?";
        $checkStmt = $conn->prepare($checkQuery);
        $checkStmt->bindParam(1, $student_id);
        $checkStmt->bindParam(2, $material_id);
        $checkStmt->execute();
        $existing = $checkStmt->fetch(PDO::FETCH_ASSOC);

        // Handle File Upload
        if (isset($_FILES['file']) && $_FILES['file']['error'] === UPLOAD_ERR_OK) {
            $target_dir = "../../../uploads/submissions/";
            if (!file_exists($target_dir)) {
                mkdir($target_dir, 0777, true);
            }
            
            $file_extension = strtolower(pathinfo($_FILES["file"]["name"], PATHINFO_EXTENSION));
            $allowed_types = array('pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'jpg', 'jpeg', 'png', 'zip', 'rar');
            
            if (!in_array($file_extension, $allowed_types)) {
                echo json_encode(array("success" => false, "message" => "Format file tidak diizinkan."));
                exit();
            }

            $new_filename = uniqid() . '_' . $student_id . '_' . time() . '.' . $file_extension;
            $target_file = $target_dir . $new_filename;

            if (move_uploaded_file($_FILES["file"]["tmp_name"], $target_file)) {
                $file_url = "https://sitono.online/manajer_data/uploads/submissions/" . $new_filename;
                
                // If existing has file, maybe delete it/keep it? Let's just overwrite db reference.
            } else {
                echo json_encode(array("success" => false, "message" => "Gagal upload file."));
                exit();
            }
        } else {
            // Keep existing file URL if updating and no new file uploaded
            if ($existing) {
                $file_url = $existing['file_url'];
            }
        }

        try {
            if ($existing) {
                // Update
                $query = "UPDATE submissions SET answer = :answer, submitted_at = NOW()";
                if ($file_url !== null) {
                    $query .= ", file_url = :file_url";
                }
                $query .= " WHERE id = :id";
                
                $stmt = $conn->prepare($query);
                $stmt->bindParam(':answer', $answer);
                $stmt->bindParam(':id', $existing['id']);
                if ($file_url !== null) {
                    $stmt->bindParam(':file_url', $file_url);
                }
            } else {
                // Insert
                $query = "INSERT INTO submissions (student_id, material_id, answer, file_url, submitted_at) VALUES (:student_id, :material_id, :answer, :file_url, NOW())";
                $stmt = $conn->prepare($query);
                $stmt->bindParam(':student_id', $student_id);
                $stmt->bindParam(':material_id', $material_id);
                $stmt->bindParam(':answer', $answer);
                $stmt->bindParam(':file_url', $file_url);
            }

            if ($stmt->execute()) {
                $response['success'] = true;
                $response['message'] = "Tugas berhasil dikumpulkan.";
            } else {
                $response['message'] = "Gagal menyimpan data.";
            }
        } catch(PDOException $e) {
            $response['message'] = "Database error: " . $e->getMessage();
        }
        
    } else {
        $response['message'] = "Data tidak lengkap (student_id, material_id required).";
    }
} else {
    $response['message'] = "Invalid request method.";
}

echo json_encode($response);
?>
