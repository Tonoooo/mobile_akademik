<?php
// fix_password.php
require_once 'config/database.php';

$username = '2023001';
$new_password = '123456';

// Generate hash using the server's algorithm
$new_hash = password_hash($new_password, PASSWORD_DEFAULT);

try {
    // Update the user's password
    $query = "UPDATE users SET password = :password WHERE username = :username";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(":password", $new_hash);
    $stmt->bindParam(":username", $username);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        echo "<h1>Berhasil!</h1>";
        echo "Password untuk user <b>$username</b> berhasil di-reset menjadi: <b>$new_password</b><br>";
        echo "Hash baru: $new_hash";
    } else {
        echo "<h1>Gagal / Tidak Ada Perubahan</h1>";
        echo "User <b>$username</b> tidak ditemukan atau password sudah sama.";
    }
} catch(PDOException $e) {
    echo "Error: " . $e->getMessage();
}
?>
