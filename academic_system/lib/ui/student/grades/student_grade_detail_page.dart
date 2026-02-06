import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/academic_models.dart';
import '../../../repositories/academic_repository.dart';

class StudentGradeDetailPage extends StatefulWidget {
  final String classSessionId;
  final String studentId;
  final String courseName;

  const StudentGradeDetailPage({
    super.key,
    required this.classSessionId,
    required this.studentId,
    required this.courseName,
  });

  @override
  State<StudentGradeDetailPage> createState() => _StudentGradeDetailPageState();
}

class _StudentGradeDetailPageState extends State<StudentGradeDetailPage> {
  GradeDetailModel? _detail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<AcademicRepository>(context, listen: false);
    final detail = await repo.getStudentGradeDetail(widget.classSessionId, widget.studentId);
    
    if (mounted) {
      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rincian Nilai', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _detail == null
              ? const Center(child: Text('Gagal memuat rincian'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Course
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue[50], 
                                shape: BoxShape.circle
                              ),
                              child: Icon(Icons.school, size: 32, color: Colors.blue[700]),
                            ),
                            const SizedBox(height: 12),
                            Text(widget.courseName, 
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Score Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                           gradient: LinearGradient(colors: [Colors.blue[700]!, Colors.blue[500]!]),
                           borderRadius: BorderRadius.circular(20),
                           boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                        ),
                        child: Column(
                          children: [
                            Text('Nilai Akhir', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 8),
                            Text(
                              _detail!.storedGrade ?? 'N/A',
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                            ),
                             if (_detail!.storedGrade == null)
                                Text('Est: ${_detail!.finalScoreCalculated.toStringAsFixed(1)}', 
                                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Breakdown
                      Text('Komponen Nilai', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      
                      _buildBreakdownCard('Absensi (30%)', 
                        _detail!.attendance.score, 
                        '${_detail!.attendance.presentCount} / ${_detail!.attendance.totalSessions} Pertemuan',
                        Icons.calendar_today, Colors.orange),
                      
                      const SizedBox(height: 12),
                      _buildComponentDetail('Tugas (40%)', _detail!.tasks, Icons.assignment, Colors.green),
                      
                      const SizedBox(height: 12),
                      _buildComponentDetail('Ujian (30%)', _detail!.exams, Icons.quiz, Colors.purple),
                    ],
                  ),
                ),
    );
  }

  Widget _buildBreakdownCard(String title, double score, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, offset: const Offset(0, 1))],
      ),
      child: Row(
        children: [
          Container(
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
             child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                if (subtitle.isNotEmpty)
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Text(score.toStringAsFixed(2), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildComponentDetail(String title, ComponentGradeDetail detail, IconData icon, Color color) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[100]!),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[100]!),
      ),
      backgroundColor: Colors.white,
      collapsedBackgroundColor: Colors.white,
      leading: Container(
         padding: const EdgeInsets.all(12),
         decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
         child: Icon(icon, color: color),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(detail.average.toStringAsFixed(2), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          const Icon(Icons.expand_more),
        ],
      ),
      children: [
        if (detail.items.isEmpty)
           Padding(
             padding: const EdgeInsets.all(16.0),
             child: Text('Belum ada data', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
           )
        else
          ...detail.items.map((item) => ListTile(
            dense: true,
            title: Text(item.title, style: GoogleFonts.poppins(fontSize: 13)),
            trailing: Text(item.score.toStringAsFixed(1), style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          )),
      ],
    );
  }
}
