import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/academic_models.dart';
import 'materials/lecturer_materials_page.dart';
import 'materials/lecturer_assignments_page.dart';
import 'materials/lecturer_exams_page.dart';
import 'attendance/lecturer_attendance_page.dart';
import 'grades/lecturer_grade_recap_page.dart';

class LecturerClassDetailPage extends StatelessWidget {
  final ClassSessionModel classSession;

  const LecturerClassDetailPage({super.key, required this.classSession});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Kelas', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
                  classSession.course?.name ?? 'Matakuliah',
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('${classSession.course?.code} - ${classSession.section}', 
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700])),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('${classSession.day}, ${classSession.timeStart} - ${classSession.timeEnd}', 
                      style: GoogleFonts.poppins(color: Colors.grey[700])),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.room, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(classSession.room, style: GoogleFonts.poppins(color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Menu Grid
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _buildMenuCard(
                  context, 
                  'Materi', 
                  Icons.menu_book, 
                  Colors.blue,
                  () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => LecturerMaterialsPage(classSession: classSession))
                  ),
                ),
                _buildMenuCard(
                  context, 
                  'Tugas', 
                  Icons.assignment, 
                  Colors.orange,
                  () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => LecturerAssignmentsPage(classSession: classSession))
                  ),
                ),
                _buildMenuCard(
                  context, 
                  'Ujian', 
                  Icons.quiz, 
                  Colors.red,
                  () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => LecturerExamsPage(classSession: classSession))
                  ),
                ),
                _buildMenuCard(
                  context, 
                  'Absensi', 
                  Icons.qr_code, 
                  Colors.green,
                  () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => LecturerAttendancePage(classSession: classSession))
                  ),
                ),
                _buildMenuCard(
                  context, 
                  'Nilai', 
                  Icons.bar_chart, 
                  Colors.purple,
                  () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => LecturerGradeRecapPage(classSession: classSession))
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    if (title == 'Nilai' && onTap == null) {
        // Fallback or explicit handling if I missed where 'Nilai' card is actually created
        // Wait, looking at lines 69-115, the "Nilai" button is NOT there. It only has Materi, Tugas, Ujian, Absensi.
        // I need to ADD the button first!
    }
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
