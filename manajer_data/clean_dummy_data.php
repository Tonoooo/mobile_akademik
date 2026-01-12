<?php
// clean_dummy_data.php
require_once 'config/database.php';

try {
    $conn->beginTransaction();

    // 1. Identify Dummy Courses (IF101, IF102)
    // We need to delete Enrollments -> Classes -> Courses
    
    // Delete Enrollments for dummy classes
    $sqlEnrollments = "DELETE FROM enrollments WHERE class_id IN (
        SELECT id FROM classes WHERE course_id IN (
            SELECT id FROM courses WHERE code IN ('IF101', 'IF102')
        )
    )";
    $conn->exec($sqlEnrollments);
    echo "✅ Data KRS dummy dihapus.<br>";

    // Delete Classes for dummy courses
    $sqlClasses = "DELETE FROM classes WHERE course_id IN (
        SELECT id FROM courses WHERE code IN ('IF101', 'IF102')
    )";
    $conn->exec($sqlClasses);
    echo "✅ Data Kelas dummy dihapus.<br>";

    // Delete Dummy Courses
    $sqlCourses = "DELETE FROM courses WHERE code IN ('IF101', 'IF102')";
    $conn->exec($sqlCourses);
    echo "✅ Data Mata Kuliah dummy dihapus.<br>";

    $conn->commit();
    echo "<br>🎉 Selesai! Sekarang hanya data buatan Anda yang tersisa.";

} catch(PDOException $e) {
    $conn->rollBack();
    echo "❌ Error: " . $e->getMessage();
}
?>
