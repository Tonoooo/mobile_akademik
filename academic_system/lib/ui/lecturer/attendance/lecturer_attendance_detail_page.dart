import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../repositories/academic_repository.dart';
import '../../../models/academic_models.dart';

class LecturerAttendanceDetailPage extends StatefulWidget {
  final String sessionId;

  const LecturerAttendanceDetailPage({super.key, required this.sessionId});

  @override
  State<LecturerAttendanceDetailPage> createState() => _LecturerAttendanceDetailPageState();
}

class _LecturerAttendanceDetailPageState extends State<LecturerAttendanceDetailPage> {
  AttendanceSessionModel? _session;
  List<AttendanceRecordModel> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<AcademicRepository>(context, listen: false);
    final result = await repo.getAttendanceSessionDetails(widget.sessionId);
    if (mounted) {
      if (result != null) {
        setState(() {
          _session = result['session'];
          _records = result['records'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Absensi', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _session == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Pertemuan ${_session!.meetingNumber}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('dd MMM yyyy').format(_session!.createdAt),
                                style: GoogleFonts.poppins(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _session!.title,
                            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSummaryItem('Hadir', _records.where((r) => r.status == 'H').length, Colors.green),
                              _buildSummaryItem('Sakit', _records.where((r) => r.status == 'S').length, Colors.orange),
                              _buildSummaryItem('Izin', _records.where((r) => r.status == 'I').length, Colors.blue),
                              _buildSummaryItem('Alpha', _records.where((r) => r.status == 'A').length, Colors.red),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _records.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final record = _records[index];
                          return ListTile(
                            tileColor: Colors.white,
                            leading: CircleAvatar(
                              child: Text(record.studentName?[0] ?? 'S'),
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.black87,
                            ),
                            title: Text(record.studentName ?? '-'),
                            subtitle: Text(record.studentNim ?? '-'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(record.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _getStatusColor(record.status)),
                              ),
                              child: Text(
                                _getStatusLabel(record.status),
                                style: TextStyle(
                                  color: _getStatusColor(record.status),
                                  fontWeight: FontWeight.bold,
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

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Column(
      children: [
        Text('$count', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
