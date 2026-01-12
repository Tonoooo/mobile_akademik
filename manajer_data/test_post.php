<?php
// test_post.php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

$input = file_get_contents("php://input");
$log_msg = "POST Test Received at " . date('Y-m-d H:i:s') . ". Data: " . $input . "\n";
file_put_contents("post_log.txt", $log_msg, FILE_APPEND);

echo json_encode(["message" => "POST Success", "received" => $input]);
?>
