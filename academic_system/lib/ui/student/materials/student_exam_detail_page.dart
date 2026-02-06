import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import '../../../repositories/academic_repository.dart';
import '../../../models/academic_models.dart';
import '../../../viewmodels/auth_viewmodel.dart';

class StudentExamDetailPage extends StatefulWidget {
  final MaterialModel exam;

  const StudentExamDetailPage({super.key, required this.exam});

  @override
  State<StudentExamDetailPage> createState() => _StudentExamDetailPageState();
}

class _StudentExamDetailPageState extends State<StudentExamDetailPage> {
  SubmissionModel? _submission;
  bool _isLoading = true;
  bool _isSubmitting = false;

  final _answerController = TextEditingController();
  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    _checkSubmission();
  }

  Future<void> _checkSubmission() async {
    final user = Provider.of<AuthViewModel>(context, listen: false).currentUser;
    if (user == null) return;
    
    setState(() => _isLoading = true);
    final repo = Provider.of<AcademicRepository>(context, listen: false);
    final sub = await repo.getStudentSubmission(widget.exam.id, user.id);
    
    if (mounted) {
      setState(() {
        _submission = sub;
        _isLoading = false;
        if (sub != null) {
          _answerController.text = sub.answer ?? '';
        }
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => _selectedFile = result.files.single);
    }
  }

  Future<void> _submit() async {
    final user = Provider.of<AuthViewModel>(context, listen: false).currentUser;
    if (user == null) return;

    if (_answerController.text.isEmpty && _selectedFile == null && _submission == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi jawaban atau upload file')));
      return;
    }

    setState(() => _isSubmitting = true);
    final repo = Provider.of<AcademicRepository>(context, listen: false);

    final success = await repo.submitAssignment(
      studentId: user.id,
      materialId: widget.exam.id,
      answer: _answerController.text,
      fileBytes: _selectedFile?.bytes,
      filePath: _selectedFile?.path,
      filename: _selectedFile?.name,
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jawaban ujian berhasil dikirim')));
      _checkSubmission();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengirim jawaban')));
    }
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
            // Exam Detail Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      OutlinedButton.icon(
                        onPressed: () => launchUrl(Uri.parse(widget.exam.fileUrl), mode: LaunchMode.externalApplication),
                        icon: const Icon(Icons.download),
                        label: const Text('Download Soal Ujian'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text('Lembar Jawaban', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

             if (_isLoading) 
              const Center(child: CircularProgressIndicator())
             else
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_submission != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.blue),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.blue),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Jawaban berhasil dikirim',
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.blue[800], fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text('Waktu: ${DateFormat('dd MMM yyyy, HH:mm').format(_submission!.submittedAt)}', style: GoogleFonts.poppins(color: Colors.grey[800])),
                              const SizedBox(height: 8),
                              if (_submission!.answer != null && _submission!.answer!.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Jawaban:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(_submission!.answer!),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              if (_submission!.fileUrl.isNotEmpty)
                                InkWell(
                                  onTap: () => launchUrl(Uri.parse(_submission!.fileUrl), mode: LaunchMode.externalApplication),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.description, color: Colors.blue, size: 20),
                                      const SizedBox(width: 4),
                                      const Text('Lihat File Jawaban', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_submission!.score != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Column(
                              children: [
                                Text('Nilai Ujian', style: GoogleFonts.poppins(color: Colors.green[800])),
                                Text('${_submission!.score}', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green[800])),
                              ],
                            ),
                          )
                        ] else 
                           Text('Menunggu penilaian dosen', style: GoogleFonts.poppins(color: Colors.orange, fontStyle: FontStyle.italic)),

                      ] else ...[
                        // FORM
                        TextField(
                          controller: _answerController,
                          maxLines: 10,
                          decoration: const InputDecoration(
                            labelText: 'Jawaban Teks',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickFile,
                                icon: const Icon(Icons.attach_file),
                                label: Text(_selectedFile != null 
                                    ? _selectedFile!.name 
                                    : 'Upload File Jawaban'),
                              ),
                            ),
                          ],
                        ),
                        if (_selectedFile != null)
                           Padding(
                             padding: const EdgeInsets.only(top: 8.0),
                             child: Text('File terpilih: ${_selectedFile!.name}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                           ),
                        
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(_isSubmitting ? 'Mengirim...' : 'Kirim Jawaban'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
