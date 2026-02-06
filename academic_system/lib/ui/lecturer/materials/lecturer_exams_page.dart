import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../../repositories/academic_repository.dart';
import '../../../models/academic_models.dart';
import 'lecturer_exam_detail_page.dart';

class LecturerExamsPage extends StatefulWidget {
  final ClassSessionModel classSession;

  const LecturerExamsPage({super.key, required this.classSession});

  @override
  State<LecturerExamsPage> createState() => _LecturerExamsPageState();
}

class _LecturerExamsPageState extends State<LecturerExamsPage> {
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
    final materials = await repo.getClassMaterials(widget.classSession.id, type: 'ujian');
    if (mounted) {
      setState(() {
        _exams = materials;
        _isLoading = false;
      });
    }
  }

  void _showAddExamDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDeadline;
    PlatformFile? selectedFile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Buat Ujian Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Judul Ujian'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Deskripsi / Petunjuk'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(selectedDeadline == null ? 'Pilih Deadline' : DateFormat('dd MMM yyyy HH:mm').format(selectedDeadline!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (time != null) {
                        setDialogState(() {
                          selectedDeadline = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                        });
                      }
                    }
                  },
                ),
                ListTile(
                  title: Text(selectedFile == null ? 'Upload Soal (Opsional)' : selectedFile!.name),
                  trailing: const Icon(Icons.attach_file),
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles();
                    if (result != null) {
                      setDialogState(() => selectedFile = result.files.single);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && selectedDeadline != null) {
                  final repo = Provider.of<AcademicRepository>(context, listen: false);
                  final success = await repo.uploadMaterial(
                    classSessionId: widget.classSession.id,
                    title: titleController.text,
                    description: descriptionController.text,
                    type: 'ujian',
                    deadline: selectedDeadline,
                    fileBytes: selectedFile?.bytes,
                    filename: selectedFile?.name ?? '',
                    filePath: selectedFile?.path,
                  );
                  if (success && mounted) {
                    Navigator.pop(context);
                    _fetchExams();
                  }
                }
              },
              child: const Text('Buat'),
            ),
          ],
        ),
      ),
    );
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
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.quiz, color: Colors.red),
                        ),
                        title: Text(exam.title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(exam.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                            if (exam.deadline != null)
                              Text(
                                'Deadline: ${DateFormat('dd MMM HH:mm').format(exam.deadline!)}',
                                style: TextStyle(color: Colors.red[700], fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LecturerExamDetailPage(exam: exam),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExamDialog,
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }
}
