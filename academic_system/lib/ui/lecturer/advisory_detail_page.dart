import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../repositories/academic_repository.dart';
import '../../../models/user_model.dart';
import '../../../models/academic_models.dart';

class AdvisoryDetailPage extends StatefulWidget {
  final UserModel student;

  const AdvisoryDetailPage({super.key, required this.student});

  @override
  State<AdvisoryDetailPage> createState() => _AdvisoryDetailPageState();
}

class _AdvisoryDetailPageState extends State<AdvisoryDetailPage> {
  List<EnrollmentModel> _enrollments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchKrsDetails();
  }

  Future<void> _fetchKrsDetails() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<AcademicRepository>(context, listen: false);
    final data = await repo.getStudentEnrollments(widget.student.id);
    
    if (mounted) {
      setState(() {
        _enrollments = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String status) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(status == 'approved' ? 'Setujui KRS' : 'Tolak KRS'),
        content: Text('Apakah Anda yakin ingin ${status == 'approved' ? 'menyetujui' : 'menolak'} KRS mahasiswa ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(status == 'approved' ? 'Setujui' : 'Tolak'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final repo = Provider.of<AcademicRepository>(context, listen: false);
      final success = await repo.approveKRS(widget.student.id, status);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('KRS berhasil ${status == 'approved' ? 'disetujui' : 'ditolak'}')),
        );
        Navigator.pop(context, true); // Return success to reload list
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengupdate status KRS')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate Total SKS
    int totalSks = 0;
    for (var e in _enrollments) {
      totalSks += e.classSession?.course?.sks ?? 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail KRS', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Header Student Info
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(widget.student.name[0], style: GoogleFonts.poppins(fontSize: 20, color: Colors.blue)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.student.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('${widget.student.nimOrNip} - ${widget.student.majorName}', style: GoogleFonts.poppins(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Enrollment List
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _enrollments.isEmpty
                ? Center(child: Text('Mahasiswa belum mengambil mata kuliah', style: GoogleFonts.poppins(color: Colors.grey)))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _enrollments.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _enrollments[index];
                      final cls = item.classSession!;
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      cls.course?.name ?? 'Matakuliah',
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${cls.course?.sks ?? 0} SKS',
                                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text('${cls.day}, ${cls.timeStart}-${cls.timeEnd}', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
                                  const SizedBox(width: 16),
                                  Icon(Icons.room, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(cls.room, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Bottom Summary & Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total SKS diambil:', style: GoogleFonts.poppins()),
                    Text('$totalSks SKS', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.student.krsStatus == 'submitted')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _updateStatus('rejected'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Tolak KRS'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _updateStatus('approved'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Setujui KRS', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: widget.student.krsStatus == 'approved' ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.student.krsStatus == 'approved' ? 'KRS Telah Disetujui' : 'Status: ${widget.student.krsStatus}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: widget.student.krsStatus == 'approved' ? Colors.green : Colors.grey[700],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
