import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/student_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/academic_models.dart';
import 'materials/student_materials_page.dart';

class ClassDetailPage extends StatefulWidget {
  final ClassSessionModel classSession;

  const ClassDetailPage({super.key, required this.classSession});

  @override
  State<ClassDetailPage> createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends State<ClassDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<StudentViewModel>(context, listen: false)
          .loadClassMaterials(widget.classSession.id)
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentVM = Provider.of<StudentViewModel>(context);
    final user = Provider.of<AuthViewModel>(context, listen: false).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Kelas', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Header Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.classSession.course?.name ?? 'Matakuliah',
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(widget.classSession.dosenName, style: GoogleFonts.poppins(color: Colors.grey[700])),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('${widget.classSession.day}, ${widget.classSession.timeStart} - ${widget.classSession.timeEnd}', 
                      style: GoogleFonts.poppins(color: Colors.grey[700])),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.room, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(widget.classSession.room, style: GoogleFonts.poppins(color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
          ),
          
          // 2. Action Buttons (Materi, Tugas, Ujian, Absen)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(Icons.menu_book, 'Materi', Colors.blue, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentMaterialsPage(classSession: widget.classSession),
                    ),
                  );
                }),
                _buildActionButton(Icons.assignment, 'Tugas', Colors.orange, () {}),
                _buildActionButton(Icons.quiz, 'Ujian', Colors.red, () {}),
                _buildActionButton(Icons.qr_code, 'Absen', Colors.green, () {}),
              ],
            ),
          ),

          const Divider(thickness: 1),

          // 3. Content List (Materi/Tugas)
          Expanded(
            child: studentVM.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Daftar Materi & Tugas',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      if (studentVM.currentClassMaterials.isEmpty)
                        const Center(child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('Belum ada materi atau tugas.'),
                        ))
                      else
                        ...studentVM.currentClassMaterials.map((material) => 
                          _MaterialItem(material: material, studentId: user!.id)
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _MaterialItem extends StatefulWidget {
  final MaterialModel material;
  final String studentId;

  const _MaterialItem({required this.material, required this.studentId});

  @override
  State<_MaterialItem> createState() => _MaterialItemState();
}

class _MaterialItemState extends State<_MaterialItem> {
  SubmissionModel? _submission;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkSubmission();
  }

  void _checkSubmission() async {
    final vm = Provider.of<StudentViewModel>(context, listen: false);
    final sub = await vm.getSubmission(widget.material.id, widget.studentId);
    if (mounted) {
      setState(() {
        _submission = sub;
      });
    }
  }

  void _handleUpload() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => _isLoading = true);
      final fileName = result.files.single.name;
      
      if (!mounted) return;
      final vm = Provider.of<StudentViewModel>(context, listen: false);
      final success = await vm.uploadAssignment(widget.material.id, widget.studentId, fileName);
      
      if (success) {
        _checkSubmission(); // Refresh status
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tugas berhasil dikirim!')),
          );
        }
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAssignment = widget.material.type == 'tugas' || widget.material.type == 'ujian';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isAssignment ? Icons.assignment : Icons.description,
                  color: isAssignment ? Colors.orange : Colors.blue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.material.title,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.material.description,
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Download Button (Mock)
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Mengunduh ${widget.material.fileUrl}...')),
                    );
                  },
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Download'),
                ),

                // Upload Button (Only for Assignments)
                if (isAssignment)
                  _submission != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, size: 16, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(
                                'Dikirim',
                                style: GoogleFonts.poppins(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handleUpload,
                          icon: const Icon(Icons.upload_file, size: 18),
                          label: Text(_isLoading ? 'Uploading...' : 'Upload Jawaban'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667EEA),
                            foregroundColor: Colors.white,
                          ),
                        ),
              ],
            ),
            if (_submission != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'File: ${_submission!.fileUrl} (${DateFormat('dd MMM HH:mm').format(_submission!.submittedAt)})',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
