import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/academic_models.dart';
import '../../../repositories/academic_repository.dart';
import 'lecturer_grade_detail_page.dart';

class LecturerGradeRecapPage extends StatefulWidget {
  final ClassSessionModel classSession;

  const LecturerGradeRecapPage({super.key, required this.classSession});

  @override
  State<LecturerGradeRecapPage> createState() => _LecturerGradeRecapPageState();
}

class _LecturerGradeRecapPageState extends State<LecturerGradeRecapPage> {
  List<EnrollmentModel> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<AcademicRepository>(context, listen: false);
    final students = await repo.getClassGrades(widget.classSession.id);
    if (mounted) {
      setState(() {
        _students = students;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rekap Nilai', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? Center(child: Text('Belum ada mahasiswa', style: GoogleFonts.poppins()))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _students.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.all(8),
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[50],
                        child: Text(student.studentName?[0] ?? 'M', 
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.blue)),
                      ),
                      title: Text(student.studentName ?? 'Mahasiswa', 
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      subtitle: Text(student.studentNim ?? '-', style: GoogleFonts.poppins(fontSize: 12)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: student.grade != null ? Colors.green[50] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: student.grade != null ? Colors.green : Colors.grey),
                        ),
                        child: Text(
                          student.grade ?? (student.calculatedScore != null ? student.calculatedScore!.toStringAsFixed(1) : 'N/A'),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: student.grade != null ? Colors.green[700] : Colors.orange[700],
                          ),
                        ),
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LecturerGradeDetailPage(
                              classSession: widget.classSession,
                              studentId: student.studentId,
                              studentName: student.studentName ?? '',
                            ),
                          ),
                        );
                        _fetchStudents(); // Refresh after edit
                      },
                    );
                  },
                ),
    );
  }
}
