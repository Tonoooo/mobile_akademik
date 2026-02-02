import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../repositories/academic_repository.dart';
import '../../models/academic_models.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'lecturer_class_detail_page.dart';

class LecturerClassesPage extends StatefulWidget {
  const LecturerClassesPage({super.key});

  @override
  State<LecturerClassesPage> createState() => _LecturerClassesPageState();
}

class _LecturerClassesPageState extends State<LecturerClassesPage> {
  List<ClassSessionModel> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    setState(() => _isLoading = true);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final repo = Provider.of<AcademicRepository>(context, listen: false);
    
    if (authVM.currentUser?.id != null) {
      final classes = await repo.getLecturerClasses(authVM.currentUser!.id);
      if (mounted) {
        setState(() {
          _classes = classes;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelas Mengajar', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.class_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('Belum ada kelas yang diajar', style: GoogleFonts.poppins(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _classes.length,
                  itemBuilder: (context, index) {
                    final cls = _classes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LecturerClassDetailPage(classSession: cls),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      cls.course?.name ?? 'Matakuliah',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${cls.enrolledCount} Mhs',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('${cls.course?.code} - ${cls.section}', style: GoogleFonts.poppins(color: Colors.grey[600])),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${cls.day}, ${cls.timeStart} - ${cls.timeEnd}',
                                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  const Spacer(),
                                  Icon(Icons.room, size: 14, color: Colors.grey[500]),
                                  const SizedBox(width: 6),
                                  Text(
                                    cls.room,
                                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                                  ),
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
