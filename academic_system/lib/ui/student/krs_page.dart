import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../repositories/academic_repository.dart';
import '../../models/academic_models.dart';
import '../../models/user_model.dart';
import '../../viewmodels/auth_viewmodel.dart';

class KrsPage extends StatefulWidget {
  const KrsPage({super.key});

  @override
  State<KrsPage> createState() => _KrsPageState();
}

class _KrsPageState extends State<KrsPage> {
  List<ClassSessionModel> _availableClasses = [];
  List<EnrollmentModel> _myEnrollments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    
    // Refresh user profile to get latest status
    await authVM.refreshProfile();
    
    final repo = Provider.of<AcademicRepository>(context, listen: false);
    final studentId = authVM.currentUser?.id;

    if (studentId != null) {
      final classes = await repo.getAvailableClasses(majorId: authVM.currentUser?.majorId);
      final enrollments = await repo.getStudentEnrollments(studentId);
      
      if (mounted) {
        setState(() {
          _availableClasses = classes;
          _myEnrollments = enrollments;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleEnrollment(ClassSessionModel classSession) async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final studentId = authVM.currentUser?.id;
    if (studentId == null) return;

    // Check if already enrolled
    final isEnrolled = _myEnrollments.any((e) => e.classId == classSession.id);

    if (isEnrolled) {
      // Drop logic
       final success = await Provider.of<AcademicRepository>(context, listen: false)
          .dropClass(studentId, classSession.id);
       if (success) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kelas dibatalkan')));
         _fetchData();
       }
    } else {
      // Enroll logic
      final success = await Provider.of<AcademicRepository>(context, listen: false)
          .enrollClass(studentId, classSession.id);
      if (success) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kelas diambil')));
         _fetchData();
      } else {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengambil kelas (Penuh/Bentrok)')));
      }
    }
  }

  Future<void> _submitKRS() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final studentId = authVM.currentUser?.id;
    if (studentId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit KRS'),
        content: const Text('Apakah Anda yakin ingin mengirimkan KRS? Setelah dikirim, Anda tidak dapat mengubah pilihan kelas sampai disetujui atau ditolak oleh Dosen Wali.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final success = await Provider.of<AcademicRepository>(context, listen: false).submitKRS(studentId);
      if (success) {
        await _fetchData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('KRS Berhasil disubmit')));
        }
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal submit KRS')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final user = authVM.currentUser;

    if (user?.paymentStatus != 'paid') {
      return _buildLockedScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Isi KRS', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatusCard(user!),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _availableClasses.length,
                    itemBuilder: (context, index) {
                      final cls = _availableClasses[index];
                      final isEnrolled = _myEnrollments.any((e) => e.classId == cls.id);
                      final isLocked = user.krsStatus != 'draft';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: isEnrolled ? Colors.blue.shade50 : Colors.white,
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
                                      cls.course?.name ?? 'Unknown',
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${cls.course?.sks} SKS',
                                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('${cls.course?.code} - ${cls.section}'),
                              const SizedBox(height: 4),
                              Text('Dosen: ${cls.dosenName}', style: const TextStyle(color: Colors.grey)),
                              Text('Jadwal: ${cls.day}, ${cls.timeStart} - ${cls.timeEnd}', style: const TextStyle(color: Colors.grey)),
                              Text('Kuota: ${cls.enrolledCount}/${cls.quota}', style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 12),
                              if (!isLocked)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _toggleEnrollment(cls),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isEnrolled ? Colors.red.shade400 : const Color(0xFF667EEA),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: Text(
                                      isEnrolled ? 'Batalkan' : 'Ambil Kelas',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )
                              else if (isEnrolled)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('Sudah Diambil', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (user.krsStatus == 'draft' && _myEnrollments.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitKRS,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Submit KRS (${_myEnrollments.length} Kelas)',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildStatusCard(UserModel user) {
    Color statusColor;
    String statusText;
    String description;

    switch (user.krsStatus) {
      case 'submitted':
        statusColor = Colors.orange;
        statusText = 'Menunggu Persetujuan';
        description = 'KRS Anda sedang diperiksa oleh Dosen Wali.';
        break;
      case 'approved':
        statusColor = Colors.green;
        statusText = 'Disetujui';
        description = 'KRS Anda telah disetujui. Selamat belajar!';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Ditolak';
        description = 'KRS Anda ditolak. Silakan perbaiki pilihan kelas Anda.';
        break;
      default:
        statusColor = Colors.blue;
        statusText = 'Draft';
        description = 'Silakan pilih kelas dan klik Submit jika sudah selesai.';
    }

    final totalSks = _myEnrollments.fold<int>(0, (sum, e) => sum + (e.classSession?.course?.sks ?? 0));

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: statusColor),
              const SizedBox(width: 8),
              Text(
                'Status: $statusText',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: statusColor),
              ),
              const Spacer(),
              Text(
                'Total SKS: $totalSks',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: GoogleFonts.poppins(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLockedScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Isi KRS', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              Text(
                'KRS Terkunci',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Silakan lakukan pembayaran uang semester terlebih dahulu untuk membuka akses KRS.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Text(
                  'Status: Belum Bayar',
                  style: GoogleFonts.poppins(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
