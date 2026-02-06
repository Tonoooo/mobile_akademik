import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../repositories/academic_repository.dart';
import '../../../models/academic_models.dart';
import 'student_exam_detail_page.dart';

class StudentExamsPage extends StatefulWidget {
  final ClassSessionModel classSession;

  const StudentExamsPage({super.key, required this.classSession});

  @override
  State<StudentExamsPage> createState() => _StudentExamsPageState();
}

class _StudentExamsPageState extends State<StudentExamsPage> {
  List<MaterialModel> _exams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<AcademicRepository>(context, listen: false);
    // Fetch 'ujian' type
    final materials = await repo.getClassMaterials(widget.classSession.id, type: 'ujian');
    if (mounted) {
      setState(() {
        _exams = materials;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Ujian', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _exams.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('Belum ada ujian', style: GoogleFonts.poppins(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _exams.length,
                  itemBuilder: (context, index) {
                    final exam = _exams[index];
                    return _StudentExamCard(
                      exam: exam,
                      onTap: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentExamDetailPage(exam: exam),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

class _StudentExamCard extends StatelessWidget {
  final MaterialModel exam;
  final VoidCallback onTap;

  const _StudentExamCard({required this.exam, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.quiz, color: Colors.red),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam.title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (exam.deadline != null)
                          Text(
                            'Deadline: ${DateFormat('dd MMM HH:mm').format(exam.deadline!)}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.red[400],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
