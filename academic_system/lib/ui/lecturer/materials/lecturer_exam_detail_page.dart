import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../repositories/academic_repository.dart';
import '../../../models/academic_models.dart';

class LecturerExamDetailPage extends StatefulWidget {
  final MaterialModel exam;

  const LecturerExamDetailPage({super.key, required this.exam});

  @override
  State<LecturerExamDetailPage> createState() => _LecturerExamDetailPageState();
}

class _LecturerExamDetailPageState extends State<LecturerExamDetailPage> {
  List<SubmissionModel> _submissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSubmissions();
  }

  Future<void> _fetchSubmissions() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<AcademicRepository>(context, listen: false);
    final submissions = await repo.getAssignmentSubmissions(widget.exam.id); // Reusing generic method
    if (mounted) {
      setState(() {
        _submissions = submissions;
        _isLoading = false;
      });
    }
  }

  void _showGradeDialog(SubmissionModel submission) {
    final gradeController = TextEditingController(text: submission.score?.toString() ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Beri Nilai Ujian'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mahasiswa: ${submission.studentName ?? '-'}'),
            if (submission.answer != null && submission.answer!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Jawaban Teks:', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: Text(submission.answer!),
              ),
            ],
            const SizedBox(height: 12),
            if (submission.fileUrl.isNotEmpty)
              OutlinedButton.icon(
                onPressed: () => launchUrl(Uri.parse(submission.fileUrl), mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.download),
                label: const Text('Download Lembar Jawaban'),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: gradeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nilai (0-100)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final grade = double.tryParse(gradeController.text);
              if (grade != null) {
                final repo = Provider.of<AcademicRepository>(context, listen: false);
                final success = await repo.gradeSubmission(submission.id, grade);
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nilai berhasil disimpan')));
                  _fetchSubmissions();
                }
              }
            },
            child: const Text('Simpan Nilai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Ujian', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card 1: Exam Details
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.exam.title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (widget.exam.deadline != null)
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'Deadline: ${DateFormat('dd MMM yyyy, HH:mm').format(widget.exam.deadline!)}',
                            style: GoogleFonts.poppins(color: Colors.red),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(widget.exam.description, style: GoogleFonts.poppins()),
                    if (widget.exam.fileUrl.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => launchUrl(Uri.parse(widget.exam.fileUrl), mode: LaunchMode.externalApplication),
                        child: const Text('Download Soal Ujian'),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            Text('Lembar Jawaban Masuk', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Card 2: Submissions List
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _submissions.isEmpty
                    ? const Center(child: Text('Belum ada mahasiswa yang mengumpulkan'))
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _submissions.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final submission = _submissions[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(submission.studentName?[0] ?? 'M'),
                              backgroundColor: Colors.red[100],
                              foregroundColor: Colors.red[800],
                            ),
                            title: Text(submission.studentName ?? 'Mahasiswa'),
                            subtitle: Text('Dikirim: ${DateFormat('dd MMM HH:mm').format(submission.submittedAt)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (submission.score != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Nilai: ${submission.score}',
                                      style: GoogleFonts.poppins(color: Colors.green[800], fontWeight: FontWeight.bold),
                                    ),
                                  )
                                else
                                  const Text('Belum dinilai', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                            onTap: () => _showGradeDialog(submission),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
