import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../repositories/academic_repository.dart';
import '../../../models/academic_models.dart';

class LecturerAddAttendancePage extends StatefulWidget {
  final ClassSessionModel classSession;

  const LecturerAddAttendancePage({super.key, required this.classSession});

  @override
  State<LecturerAddAttendancePage> createState() => _LecturerAddAttendancePageState();
}

class _LecturerAddAttendancePageState extends State<LecturerAddAttendancePage> {
  final _titleController = TextEditingController();
  final _meetingNumberController = TextEditingController();
  bool _isLoading = false;
  
  // List of students with their attendance status
  List<Map<String, dynamic>> _students = [];
  bool _isLoadingStudents = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() => _isLoadingStudents = true);
    final repo = Provider.of<AcademicRepository>(context, listen: false);
    // Reuse existing method to get enrollments (students in class)
    // Note: We might need a specific method if not available, but usually we can get enrollments
    // For now, I'll assume we can reuse or I'll implement a simple fetch from enrollments
    // Wait, the previous task implemented getLecturerClasses, but not specifically getStudentsInClass
    // Let's check repository. Ah, we don't have a direct method to get students list for a class yet?
    // Looking at previous work, `getClassEnrollments` or similar might be needed.
    // I will mock it first or implement it. 
    // Actually, `manajer_data/api/academic/enrollments/list_by_class.php` likely exists or I can fetch generic list.
    // Let's implement `getClassStudents` in repository first or here locally if needed.
    // Wait, I can use `getClassMaterials` logic but for students.
    // Let's implement `getClassStudents` in repository to be clean.
    
    // TEMPORARY: I will implement fetch directly here via HTTP or add to repository. 
    // Adding to repository is better. I will add `getClassStudents` to repository in next step.
    // For now I will assume it exists or call a placeholder.
    
    // Checking `AcademicRepository`... It doesn't have `getClassStudents`.
    // I will add it.
  }

  // REVISITING: I will implementing the student fetching inside the page for now using direct HTTP if needed OR (better)
  // I will add the method to repository in a separate step. 
  // For this step I will write the UI code assuming `getStudents` exists, and then I will fix the repository.
  
}
// RETRYING with correct approach:
// I'll create the file but with a TODO for fetching students, 
// OR I can use the existing `list_by_class.php` if available.
// Let's check if `getClassStudents` exists. I suspect I need to create it.
// I will pause this file creation to create the repository method first? 
// No, I can write the file and then update repository.

// Let's write the full file.
