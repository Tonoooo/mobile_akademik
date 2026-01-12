<?php
// update_schema_majors.php
require_once 'config/database.php';

try {
    // 1. Create 'majors' table
    $createMajors = "CREATE TABLE IF NOT EXISTS majors (
        id INT AUTO_INCREMENT PRIMARY KEY,
        code VARCHAR(10) NOT NULL UNIQUE,
        name VARCHAR(100) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    $conn->exec($createMajors);
    echo "✅ Tabel 'majors' berhasil dibuat/diperiksa.<br>";

    // 2. Add 'major_id' to 'courses' table
    // Check if column exists first to avoid error
    $checkCol = $conn->query("SHOW COLUMNS FROM courses LIKE 'major_id'");
    if ($checkCol->rowCount() == 0) {
        $alterCourses = "ALTER TABLE courses ADD COLUMN major_id INT NULL AFTER id";
        $conn->exec($alterCourses);
        
        // Add Foreign Key
        $fkCourses = "ALTER TABLE courses ADD CONSTRAINT fk_courses_major FOREIGN KEY (major_id) REFERENCES majors(id) ON DELETE SET NULL";
        $conn->exec($fkCourses);
        echo "✅ Kolom 'major_id' berhasil ditambahkan ke tabel 'courses'.<br>";
    } else {
        echo "ℹ️ Kolom 'major_id' sudah ada di tabel 'courses'.<br>";
    }

    // 3. Add 'major_id' to 'users' table (for Students/Lecturers)
    $checkColUser = $conn->query("SHOW COLUMNS FROM users LIKE 'major_id'");
    if ($checkColUser->rowCount() == 0) {
        $alterUsers = "ALTER TABLE users ADD COLUMN major_id INT NULL AFTER role";
        $conn->exec($alterUsers);

        // Add Foreign Key
        $fkUsers = "ALTER TABLE users ADD CONSTRAINT fk_users_major FOREIGN KEY (major_id) REFERENCES majors(id) ON DELETE SET NULL";
        $conn->exec($fkUsers);
        echo "✅ Kolom 'major_id' berhasil ditambahkan ke tabel 'users'.<br>";
    } else {
        echo "ℹ️ Kolom 'major_id' sudah ada di tabel 'users'.<br>";
    }

    // 4. Insert Dummy Majors
    $checkData = $conn->query("SELECT COUNT(*) FROM majors");
    if ($checkData->fetchColumn() == 0) {
        $insert = "INSERT INTO majors (code, name) VALUES 
            ('IF', 'Teknik Informatika'),
            ('SI', 'Sistem Informasi'),
            ('TE', 'Teknik Elektro')";
        $conn->exec($insert);
        echo "✅ Data dummy Jurusan berhasil ditambahkan.<br>";
    }

} catch(PDOException $e) {
    echo "❌ Error: " . $e->getMessage();
}
?>
