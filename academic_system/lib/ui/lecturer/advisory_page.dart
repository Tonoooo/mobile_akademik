import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../repositories/academic_repository.dart';
import '../../models/user_model.dart';
import '../../viewmodels/auth_viewmodel.dart';

class AdvisoryPage extends StatefulWidget {
  const AdvisoryPage({super.key});

  @override
  State<AdvisoryPage> createState() => _AdvisoryPageState();
}

class _AdvisoryPageState extends State<AdvisoryPage> {
  List<UserModel> _advisees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdvisees();
  }

  Future<void> _fetchAdvisees() async {
    setState(() => _isLoading = true);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final dosenId = authVM.currentUser?.id;

    if (dosenId != null) {
      final repo = Provider.of<AcademicRepository>(context, listen: false);
      final students = await repo.getAdvisees(dosenId);
      if (mounted) {
        setState(() {
          _advisees = students;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateStatus(UserModel student, String status) async {
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
      final success = await repo.approveKRS(student.id, status);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('KRS berhasil ${status == 'approved' ? 'disetujui' : 'ditolak'}')),
        );
        _fetchAdvisees();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengupdate status KRS')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perwalian', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _advisees.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Belum ada mahasiswa bimbingan', style: GoogleFonts.poppins()),
                      const SizedBox(height: 8),
                      Text('Debug: Dosen ID = ${Provider.of<AuthViewModel>(context).currentUser?.id}', 
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _advisees.length,
                  itemBuilder: (context, index) {
                    final student = _advisees[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  student.name,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                _buildStatusBadge(student.krsStatus),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('NIM: ${student.nimOrNip}', style: GoogleFonts.poppins(color: Colors.grey)),
                            Text('Prodi: ${student.majorName}', style: GoogleFonts.poppins(color: Colors.grey)),
                            const SizedBox(height: 12),
                            if (student.krsStatus == 'submitted')
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => _updateStatus(student, 'rejected'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                    ),
                                    child: const Text('Tolak'),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed: () => _updateStatus(student, 'approved'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text('Setujui', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'submitted':
        color = Colors.orange;
        text = 'Menunggu';
        break;
      case 'approved':
        color = Colors.green;
        text = 'Disetujui';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Ditolak';
        break;
      default:
        color = Colors.grey;
        text = 'Draft';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
