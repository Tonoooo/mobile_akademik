<?php
// create_superadmin.php
require_once 'config/database.php';

try {
    // 1. Alter Table to add 'superadmin' to ENUM
    // Note: We need to be careful not to break existing data. 
    // We re-declare the ENUM with the new value added.
    $alterQuery = "ALTER TABLE users MODIFY COLUMN role ENUM('mahasiswa', 'dosen', 'admin', 'keuangan', 'superadmin') NOT NULL";
    $conn->exec($alterQuery);
    echo "✅ Berhasil update struktur tabel (tambah role superadmin).<br>";

    // 2. Insert Superadmin User
    $username = 'superadmin';
    $password = '123456';
    $hash = password_hash($password, PASSWORD_DEFAULT);
    $name = 'Super Administrator';
    $role = 'superadmin';

    // Check if exists first
    $check = $conn->prepare("SELECT id FROM users WHERE username = ?");
    $check->execute([$username]);

    if ($check->rowCount() > 0) {
        // Update existing
        $update = $conn->prepare("UPDATE users SET password = ?, role = ? WHERE username = ?");
        $update->execute([$hash, $role, $username]);
        echo "✅ User <b>$username</b> sudah ada. Password di-reset ke: <b>$password</b><br>";
    } else {
        // Insert new
        $insert = $conn->prepare("INSERT INTO users (username, password, name, role) VALUES (?, ?, ?, ?)");
        $insert->execute([$username, $hash, $name, $role]);
        echo "✅ Berhasil membuat user baru: <b>$username</b> dengan password: <b>$password</b><br>";
    }

} catch(PDOException $e) {
    echo "❌ Error: " . $e->getMessage();
}
?>
