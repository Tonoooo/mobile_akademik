<?php
// test_write.php
header("Access-Control-Allow-Origin: *");

$file = 'test_log_result.txt';
$content = "Test writing file at " . date('Y-m-d H:i:s');

if (file_put_contents($file, $content)) {
    echo "Write SUCCESS! File '$file' created.";
} else {
    echo "Write FAILED. Check folder permissions (chmod 755 or 777).";
    // Try to print last error
    print_r(error_get_last());
}
?>
