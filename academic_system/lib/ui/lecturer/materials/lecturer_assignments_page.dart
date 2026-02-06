import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../../../repositories/academic_repository.dart';
import '../../../models/academic_models.dart';
import 'lecturer_assignment_detail_page.dart';

class LecturerAssignmentsPage extends StatefulWidget {
  final ClassSessionModel classSession;

  const LecturerAssignmentsPage({super.key, required this.classSession});

  @override
  State<LecturerAssignmentsPage> createState() => _LecturerAssignmentsPageState();
}

class _LecturerAssignmentsPageState extends State<LecturerAssignmentsPage> {
  List<MaterialModel> _assignments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAssignments();
  }

  Future<void> _fetchAssignments() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<AcademicRepository>(context, listen: false);
    final materials = await repo.getClassMaterials(widget.classSession.id, type: 'tugas');
    if (mounted) {
      setState(() {
        _assignments = materials;
        _isLoading = false;
      });
    }
  }

  void _showAddAssignmentDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddAssignmentDialog(
        classSessionId: widget.classSession.id,
        onSuccess: _fetchAssignments,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Tugas', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _assignments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('Belum ada tugas', style: GoogleFonts.poppins(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = _assignments[index];
                    return _AssignmentCard(
                      assignment: assignment,
                      onTap: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LecturerAssignmentDetailPage(assignment: assignment),
                          ),
                        ).then((_) => _fetchAssignments());
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAssignmentDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final MaterialModel assignment;
  final VoidCallback onTap;

  const _AssignmentCard({required this.assignment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
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
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.assignment, color: Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (assignment.deadline != null)
                          Text(
                            'Deadline: ${DateFormat('dd MMM HH:mm').format(assignment.deadline!)}',
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
              if (assignment.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  assignment.description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class _AddAssignmentDialog extends StatefulWidget {
  final String classSessionId;
  final VoidCallback onSuccess;

  const _AddAssignmentDialog({required this.classSessionId, required this.onSuccess});

  @override
  State<_AddAssignmentDialog> createState() => _AddAssignmentDialogState();
}

class _AddAssignmentDialogState extends State<_AddAssignmentDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _deadline;
  PlatformFile? _selectedFile; // file_picker type
  bool _isUploading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => _selectedFile = result.files.single);
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul wajib diisi')));
      return;
    }
    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deadline wajib diisi')));
      return;
    }

    setState(() => _isUploading = true);
    final repo = Provider.of<AcademicRepository>(context, listen: false);

    final success = await repo.uploadMaterial(
      classSessionId: widget.classSessionId,
      title: _titleController.text,
      type: 'tugas',
      description: _descController.text,
      deadline: _deadline,
      fileBytes: _selectedFile?.bytes,
      filePath: _selectedFile?.path,
      filename: _selectedFile?.name ?? '',
    );

    setState(() => _isUploading = false);

    if (success && mounted) {
      Navigator.pop(context);
      widget.onSuccess();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tugas berhasil dibuat')));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuat tugas')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Buat Tugas Baru', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul Tugas', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDateTime,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Batas Pengumpulan',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _deadline != null ? DateFormat('dd MMM yyyy HH:mm').format(_deadline!) : 'Pilih Waktu',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: Text(_selectedFile != null ? _selectedFile!.name : 'Upload File (Optional)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          onPressed: _isUploading ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: Text(_isUploading ? 'Menyimpan...' : 'Simpan'),
        ),
      ],
    );
  }
}
