import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../repositories/academic_repository.dart';
import '../../../models/academic_models.dart';
import 'lecturer_add_attendance_page.dart';
import 'lecturer_attendance_detail_page.dart';

class LecturerAttendancePage extends StatefulWidget {
  final ClassSessionModel classSession;

  const LecturerAttendancePage({super.key, required this.classSession});

  @override
  State<LecturerAttendancePage> createState() => _LecturerAttendancePageState();
}

class _LecturerAttendancePageState extends State<LecturerAttendancePage> {
  List<AttendanceSessionModel> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<AcademicRepository>(context, listen: false);
    final sessions = await repo.getClassAttendanceSessions(widget.classSession.id);
    if (mounted) {
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Absensi', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.date_range, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('Belum ada data absensi', style: GoogleFonts.poppins(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'P${session.meetingNumber}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        title: Text(session.title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(session.createdAt)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LecturerAttendanceDetailPage(sessionId: session.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LecturerAddAttendancePage(classSession: widget.classSession),
            ),
          );
          if (result == true) {
            _fetchSessions();
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
