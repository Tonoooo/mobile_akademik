import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../repositories/academic_repository.dart';
import '../../../models/academic_models.dart';
import '../../../viewmodels/auth_viewmodel.dart';

class StudentClassAttendancePage extends StatefulWidget {
  final EnrollmentModel enrollment;

  const StudentClassAttendancePage({super.key, required this.enrollment});

  @override
  State<StudentClassAttendancePage> createState() => _StudentClassAttendancePageState();
}

class _StudentClassAttendancePageState extends State<StudentClassAttendancePage> {
  List<AttendanceRecordModel> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<AcademicRepository>(context, listen: false);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    
    // We need records strictly for this class.
    // Assuming backend returns records for all sessions of this class where student exists.
    final records = await repo.getStudentClassAttendance(
      authVM.currentUser!.id, 
      widget.enrollment.classId
    );
    
    if (mounted) {
      setState(() {
        _records = records;
        _isLoading = false;
      });
    }
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
    final hadir = _records.where((r) => r.status == 'H').length;
    final sakit = _records.where((r) => r.status == 'S').length;
    final izin = _records.where((r) => r.status == 'I').length;
    final alpha = _records.where((r) => r.status == 'A').length;
    final total = _records.length;
    final percentage = total > 0 ? (hadir / total * 100).toStringAsFixed(0) : '0';

    return Scaffold(
      appBar: AppBar(
        title: Text('Rekap Absensi', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                Text(
                  widget.enrollment.classSession?.course?.name ?? 'Matakuliah',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green, width: 4),
                      ),
                      child: Text(
                        '$percentage%',
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegend(Colors.green, 'Hadir: $hadir'),
                        _buildLegend(Colors.orange, 'Sakit: $sakit'),
                        _buildLegend(Colors.blue, 'Izin: $izin'),
                        _buildLegend(Colors.red, 'Alpha: $alpha'),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _records.isEmpty
                    ? const Center(child: Text('Belum ada data absensi'))
                    : ListView.separated(
                        itemCount: _records.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final record = _records[index];
                          return ListTile(
                            tileColor: Colors.white,
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'P${record.meetingNumber}',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800]),
                              ),
                            ),
                            title: Text(record.sessionTitle ?? 'Pertemuan'),
                            subtitle: Text(
                              record.sessionDate != null 
                                ? DateFormat('dd MMM yyyy').format(record.sessionDate!) 
                                : '-'
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(record.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getStatusLabel(record.status),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
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

  Widget _buildLegend(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.poppins(fontSize: 14)),
        ],
      ),
    );
  }
}
