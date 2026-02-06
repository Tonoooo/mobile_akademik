import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/academic_models.dart';
import '../../../repositories/academic_repository.dart';
import 'student_grade_detail_page.dart';

class StudentGradeListPage extends StatefulWidget {
  final String studentId;

  const StudentGradeListPage({super.key, required this.studentId});

  @override
  State<StudentGradeListPage> createState() => _StudentGradeListPageState();
}

class _StudentGradeListPageState extends State<StudentGradeListPage> {
  List<EnrollmentModel> _grades = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGrades();
  }

  Future<void> _fetchGrades() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<AcademicRepository>(context, listen: false);
    final grades = await repo.getStudentAllGrades(widget.studentId);
    if (mounted) {
      setState(() {
        _grades = grades;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Nilai', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _grades.isEmpty
              ? Center(child: Text('Belum ada data nilai', style: GoogleFonts.poppins()))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _grades.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _grades[index];
                    final course = item.classSession?.course;
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: InkWell(
                        onTap: () {
                           Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentGradeDetailPage(
                                classSessionId: item.classId,
                                studentId: widget.studentId,
                                courseName: course?.name ?? 'Matakuliah',
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 50, height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    course?.code.substring(0, 1) ?? 'M',
                                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      course?.name ?? 'Matakuliah',
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Text(
                                      '${course?.code} • ${course?.sks} SKS',
                                      style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: item.grade != null ? Colors.green[50] : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: item.grade != null ? Colors.green : Colors.grey[300]!),
                                ),
                                child: Text(
                                  item.grade ?? 'N/A',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold, 
                                    color: item.grade != null ? Colors.green[700] : Colors.grey[600]
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
