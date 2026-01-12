<?php
// api/auth/login.php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $raw_input = file_get_contents("php://input");
    $data = json_decode($raw_input);
    
    // Debug Logging
    $log_entry = date('Y-m-d H:i:s') . " - Input: " . $raw_input . "\n";
    file_put_contents("debug_log.txt", $log_entry, FILE_APPEND);

    if (!empty($data->username) && !empty($data->password)) {
        $query = "SELECT u.*, m.name as major_name 
                  FROM users u 
                  LEFT JOIN majors m ON u.major_id = m.id 
                  WHERE u.username = :username LIMIT 1";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(":username", $data->username);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            // Verify password
            if (password_verify($data->password, $user['password'])) {
                file_put_contents("debug_log.txt", " - Login Success for {$data->username}\n", FILE_APPEND);
                // Remove password from response
                unset($user['password']);
                
                echo json_encode([
                    "success" => true,
                    "message" => "Login successful",
                    "data" => $user
                ]);
            } else {
                file_put_contents("debug_log.txt", " - Invalid Password for {$data->username}. Hash in DB: {$user['password']}\n", FILE_APPEND);
                echo json_encode([
                    "success" => false,
                    "message" => "Invalid password"
                ]);
            }
        } else {
            file_put_contents("debug_log.txt", " - User Not Found: {$data->username}\n", FILE_APPEND);
            echo json_encode([
                "success" => false,
                "message" => "User not found"
            ]);
        }
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Incomplete data"
        ]);
    }
} else {
    http_response_code(405);
    echo json_encode(["message" => "Method not allowed"]);
}
?>
