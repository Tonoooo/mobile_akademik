<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include_once '../../config/database.php';

try {
    // Table: attendance_sessions
    $sql1 = "CREATE TABLE IF NOT EXISTS attendance_sessions (
        id INT(11) AUTO_INCREMENT PRIMARY KEY,
        class_id INT(11) NOT NULL,
        title VARCHAR(255) NOT NULL,
        meeting_number INT(11) NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        INDEX (class_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
    $conn->exec($sql1);
    echo "Table 'attendance_sessions' created/verified.<br>";

    // Table: attendance_records
    $sql2 = "CREATE TABLE IF NOT EXISTS attendance_records (
        id INT(11) AUTO_INCREMENT PRIMARY KEY,
        session_id INT(11) NOT NULL,
        student_id INT(11) NOT NULL,
        status ENUM('H', 'S', 'I', 'A') NOT NULL DEFAULT 'A',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (session_id) REFERENCES attendance_sessions(id) ON DELETE CASCADE,
        INDEX (session_id),
        INDEX (student_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
    $conn->exec($sql2);
    echo "Table 'attendance_records' created/verified.<br>";

} catch (PDOException $e) {
    echo "Error creating tables: " . $e->getMessage() . "<br>";
}
?>
