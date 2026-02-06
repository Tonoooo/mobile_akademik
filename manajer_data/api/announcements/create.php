<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $title = $_POST['title'] ?? '';
    $content = $_POST['content'] ?? '';
    $created_by = $_POST['created_by'] ?? null;
    $attachment_url = null;

    if (empty($title)) {
        echo json_encode(array("success" => false, "message" => "Judul harus diisi"));
        exit();
    }

    // Handle File Upload
    if (isset($_FILES['attachment']) && $_FILES['attachment']['error'] == 0) {
        $upload_dir = '../../uploads/announcements/';
        if (!file_exists($upload_dir)) {
            mkdir($upload_dir, 0777, true);
        }

        $file_name = time() . '_' . basename($_FILES['attachment']['name']);
        $target_file = $upload_dir . $file_name;

        if (move_uploaded_file($_FILES['attachment']['tmp_name'], $target_file)) {
            // URL accessible from app
            $base_url = "https://sitono.online/manajer_data/uploads/announcements/";
            // Note: Adjust domain as needed, or return relative path
            // For localhost/testing, we might use relative, but let's store filename or relative path
            $attachment_url = "uploads/announcements/" . $file_name;
        } else {
             echo json_encode(array("success" => false, "message" => "Gagal upload file"));
             exit();
        }
    }

    try {
        $query = "INSERT INTO announcements (title, content, attachment_url, created_by) VALUES (:title, :content, :attachment_url, :created_by)";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(':title', $title);
        $stmt->bindParam(':content', $content);
        $stmt->bindParam(':attachment_url', $attachment_url);
        $stmt->bindParam(':created_by', $created_by);

        if ($stmt->execute()) {
            echo json_encode(array("success" => true, "message" => "Pengumuman berhasil dibuat"));
        } else {
            echo json_encode(array("success" => false, "message" => "Gagal menyimpan pengumuman"));
        }
    } catch (PDOException $e) {
        echo json_encode(array("success" => false, "message" => $e->getMessage()));
    }
}
?>
