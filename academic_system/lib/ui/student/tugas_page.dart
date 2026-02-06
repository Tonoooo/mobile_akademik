import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/academic_models.dart';
import '../../repositories/academic_repository.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'materials/student_assignment_detail_page.dart';

class TugasPage extends StatefulWidget {
  const TugasPage({super.key});

  @override
  State<TugasPage> createState() => _TugasPageState();
}

class _TugasPageState extends State<TugasPage> {
  List<MaterialModel> _pendingTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingTasks();
  }

  Future<void> _fetchPendingTasks() async {
    setState(() => _isLoading = true);
    final user = Provider.of<AuthViewModel>(context, listen: false).currentUser;
    if (user != null) {
      final repo = Provider.of<AcademicRepository>(context, listen: false);
      final list = await repo.getPendingAssignments(user.id);
      if (mounted) {
        setState(() {
          _pendingTasks = list;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tugas Belum Dikerjakan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingTasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                      const SizedBox(height: 16),
                      Text(
                        'Hore! Semua tugas sudah dikerjakan', 
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingTasks.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final task = _pendingTasks[index];
                    final isOverdue = task.deadline != null && task.deadline!.isBefore(DateTime.now());
                    
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: InkWell(
                        onTap: () async {
                           await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentAssignmentDetailPage(
                                assignment: task,
                                // studentId: ... is not needed in constructor anymore? Wait, let me check the constructor again.
                                // Constructor: ({super.key, required this.assignment});
                                // It seems `studentId` is NOT in the constructor of StudentAssignmentDetailPage shown in the view_file output.
                                // Line 14: const StudentAssignmentDetailPage({super.key, required this.assignment});
                                // So I should remove `studentId` parameter as well.
                              ),
                            ),
                          );
                          _fetchPendingTasks(); // Refresh after return
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50], 
                                      borderRadius: BorderRadius.circular(8)
                                    ),
                                    child: Text(
                                      task.courseName ?? 'Matakuliah',
                                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue[800], fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (isOverdue)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red[50], 
                                        borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: Text(
                                        'Terlambat',
                                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                task.title,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Deadline: ${task.deadline != null ? DateFormat('dd MMM yyyy, HH:mm').format(task.deadline!) : '-'}',
                                style: GoogleFonts.poppins(fontSize: 12, color: isOverdue ? Colors.red : Colors.grey[700]),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 16, color: Colors.orange[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Belum dikumpulkan',
                                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange[700]),
                                  ),
                                  const Spacer(),
                                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
