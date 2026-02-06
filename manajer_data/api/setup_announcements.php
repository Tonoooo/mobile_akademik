<?php
include_once '../config/database.php';

try {
    $sql = "CREATE TABLE IF NOT EXISTS announcements (
        id INT AUTO_INCREMENT PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        content TEXT,
        attachment_url VARCHAR(255),
        created_by INT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
    )";

    $conn->exec($sql);
    echo "Table 'announcements' created successfully.";

} catch(PDOException $e) {
    echo "Error creating table: " . $e->getMessage();
}
?>
