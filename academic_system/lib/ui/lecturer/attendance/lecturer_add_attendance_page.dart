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
  bool _isSubmitting = false;
  
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
    final enrollments = await repo.getClassEnrollments(widget.classSession.id);
    
    if (mounted) {
      setState(() {
        _students = enrollments.map((e) => {
          'id': e.studentId,
          'name': e.studentName,
          'nim': e.studentNim,
          'status': 'H', // Default Hadir
        }).toList();
        _isLoadingStudents = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _meetingNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul dan Pertemuan Ke harus diisi')));
      return;
    }

    final meetingNum = int.tryParse(_meetingNumberController.text);
    if (meetingNum == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pertemuan Ke harus berupa angka')));
      return;
    }

    setState(() => _isSubmitting = true);
    final repo = Provider.of<AcademicRepository>(context, listen: false);

    final payload = _students.map((s) => {
      'student_id': s['id'],
      'status': s['status']
    }).toList();

    final success = await repo.createAttendanceSession(
      widget.classSession.id,
      _titleController.text,
      meetingNum,
      payload,
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      Navigator.pop(context, true); // Return true to refresh list
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Absensi berhasil dibuat')));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuat absensi')));
    }
  }

  void _toggleStatus(int index) {
    setState(() {
      final currentStatus = _students[index]['status'];
      String nextStatus = 'H';
      if (currentStatus == 'H') nextStatus = 'S';
      else if (currentStatus == 'S') nextStatus = 'I';
      else if (currentStatus == 'I') nextStatus = 'A';
      else if (currentStatus == 'A') nextStatus = 'H';
      _students[index]['status'] = nextStatus;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'H': return Colors.green;
      case 'S': return Colors.orange;
      case 'I': return Colors.blue;
      case 'A': return Colors.red;
      default: return Colors.grey;
    }
  }
  
  String _getStatusLabel(String status) {
    switch (status) {
      case 'H': return 'Hadir';
      case 'S': return 'Sakit';
      case 'I': return 'Izin';
      case 'A': return 'Alpha';
      default: return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buat Absensi Baru', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
            TextButton(
                onPressed: _isSubmitting ? null : _submit,
                child: Text('SIMPAN', style: GoogleFonts.poppins(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
            )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _meetingNumberController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Pertemuan Ke'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Topik / Judul'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoadingStudents
                ? const Center(child: CircularProgressIndicator())
                : _students.isEmpty
                    ? const Center(child: Text('Tidak ada mahasiswa di kelas ini'))
                    : ListView.separated(
                        itemCount: _students.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final student = _students[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              child: Text('${index + 1}'),
                            ),
                            title: Text(student['name'] ?? 'Student'),
                            subtitle: Text(student['nim'] ?? '-'),
                            trailing: InkWell(
                              onTap: () => _toggleStatus(index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(student['status']),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getStatusLabel(student['status']),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
