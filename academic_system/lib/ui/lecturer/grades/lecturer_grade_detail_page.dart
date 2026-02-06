import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/academic_models.dart';
import '../../../repositories/academic_repository.dart';

class LecturerGradeDetailPage extends StatefulWidget {
  final ClassSessionModel classSession;
  final String studentId;
  final String studentName;

  const LecturerGradeDetailPage({
    super.key,
    required this.classSession,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<LecturerGradeDetailPage> createState() => _LecturerGradeDetailPageState();
}

class _LecturerGradeDetailPageState extends State<LecturerGradeDetailPage> {
  GradeDetailModel? _detail;
  bool _isLoading = true;
  final _gradeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<AcademicRepository>(context, listen: false);
    final detail = await repo.getStudentGradeDetail(widget.classSession.id, widget.studentId);
    
    if (mounted) {
      setState(() {
        _detail = detail;
        _isLoading = false;
        if (detail?.storedGrade != null) {
          _gradeController.text = detail!.storedGrade!;
        } else if (detail != null) {
          // Suggest grade based on calculation
          _gradeController.text = _getGradeLetter(detail.finalScoreCalculated);
        }
      });
    }
  }

  String _getGradeLetter(double score) {
    if (score >= 85) return 'A';
    if (score >= 75) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'E';
  }

  Future<void> _saveGrade() async {
    if (_detail == null) return;
    
    final repo = Provider.of<AcademicRepository>(context, listen: false);
    final success = await repo.updateFinalGrade(_detail!.enrollmentId, _gradeController.text.trim().toUpperCase());
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nilai berhasil disimpan')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan nilai')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Nilai', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _detail == null
              ? const Center(child: Text('Gagal memuat detail'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Header Student
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blue[100],
                              child: Text(widget.studentName[0], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 8),
                            Text(widget.studentName, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('Final Score: ${_detail!.finalScoreCalculated.toStringAsFixed(2)}', 
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700])),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Input Grade
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0,2))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nilai Akhir (Huruf)', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _gradeController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: 'A, B, C, D, E',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.check_circle, color: Colors.green),
                                  onPressed: _saveGrade,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Breakdown
                      _buildBreakdownCard('Absensi (30%)', 
                        _detail!.attendance.score, 
                        '${_detail!.attendance.presentCount} / ${_detail!.attendance.totalSessions} Pertemuan'),
                      
                      const SizedBox(height: 16),
                      _buildComponentDetail('Tugas (40%)', _detail!.tasks),
                      
                      const SizedBox(height: 16),
                      _buildComponentDetail('Ujian (30%)', _detail!.exams),
                    ],
                  ),
                ),
    );
  }

  Widget _buildBreakdownCard(String title, double score, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              if (subtitle.isNotEmpty)
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Text(score.toStringAsFixed(2), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildComponentDetail(String title, ComponentGradeDetail detail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              Text(detail.average.toStringAsFixed(2), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const Divider(height: 24),
          if (detail.items.isEmpty)
             const Text('Belum ada data', style: TextStyle(color: Colors.grey))
          else
            ...detail.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.title, style: GoogleFonts.poppins(fontSize: 14)),
                  Text(item.score.toStringAsFixed(1), style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                ],
              ),
            )),
        ],
      ),
    );
  }
}
