import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/student_viewmodel.dart';
import 'krs_page.dart';
import 'schedule_page.dart';
import 'kelas_page.dart';
import 'tugas_page.dart';
import 'profile_page.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const StudentHomePage(),
    const KelasPage(),
    const TugasPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // Load data when dashboard opens
    Future.microtask(() {
      final user = Provider.of<AuthViewModel>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<StudentViewModel>(context, listen: false).loadData(user.id, majorId: user.majorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final user = authVM.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, ${user?.name ?? 'Mahasiswa'}',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.nimOrNip ?? '',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authVM.logout(),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Kelas',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Tugas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final studentVM = Provider.of<StudentViewModel>(context);
    final user = Provider.of<AuthViewModel>(context).currentUser;

    // Filter jadwal hari ini (Mock: assume today is Monday/Senin for demo)
    final today = 'Senin'; 
    final todayClasses = studentVM.myEnrollments.where((e) => e.classSession?.day == today).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Jadwal Hari Ini Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jadwal Hari Ini',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                today, // Dynamic day
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (todayClasses.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                   const Icon(Icons.event_busy, size: 48, color: Colors.grey),
                   const SizedBox(height: 8),
                   Text('Tidak ada jadwal hari ini', style: GoogleFonts.poppins(color: Colors.grey)),
                ],
              ),
            )
          else
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: todayClasses.length,
                itemBuilder: (context, index) {
                  final cls = todayClasses[index].classSession!;
                  return Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667EEA).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cls.course?.name ?? 'Matakuliah',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${cls.timeStart} - ${cls.timeEnd}',
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.room, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              cls.room,
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            cls.dosenName,
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 24),

          // 2. Grid Menu
          Text(
            'Menu Akademik',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
            children: [
              _buildMenuIcon(Icons.badge, 'KTM', Colors.orange),
              _buildMenuIcon(Icons.account_balance_wallet, 'Keuangan', Colors.green),
              _buildMenuIcon(Icons.edit_note, 'KRS', Colors.blue, onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const KrsPage()));
              }),
              _buildMenuIcon(Icons.assignment_turned_in, 'KHS', Colors.purple),
              _buildMenuIcon(Icons.bar_chart, 'Nilai', Colors.red),
              _buildMenuIcon(Icons.description, 'Transkrip', Colors.teal),
              _buildMenuIcon(Icons.qr_code_scanner, 'Presensi', Colors.indigo),
              _buildMenuIcon(Icons.supervisor_account, 'Perwalian', Colors.brown),
              _buildMenuIcon(Icons.star, 'SKKM', Colors.amber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuIcon(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
