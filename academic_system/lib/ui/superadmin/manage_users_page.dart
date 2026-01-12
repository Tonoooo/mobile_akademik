import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../repositories/admin_repository.dart';
import '../../core/constants.dart';
import '../../core/constants.dart';
import '../admin/users/user_list_page.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  Map<String, int> _roleCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCounts();
  }

  Future<void> _fetchCounts() async {
    final repo = Provider.of<AdminRepository>(context, listen: false);
    final counts = await repo.getRoleCounts();
    setState(() {
      _roleCounts = counts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola User', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchCounts,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildRoleCard(
                    context,
                    'Mahasiswa',
                    AppConstants.roleMahasiswa,
                    Icons.school,
                    Colors.blue,
                  ),
                  _buildRoleCard(
                    context,
                    'Dosen',
                    AppConstants.roleDosen,
                    Icons.person_outline,
                    Colors.green,
                  ),
                  _buildRoleCard(
                    context,
                    'Admin Akademik',
                    AppConstants.roleAdmin,
                    Icons.admin_panel_settings,
                    Colors.orange,
                  ),
                  _buildRoleCard(
                    context,
                    'Keuangan',
                    AppConstants.roleKeuangan,
                    Icons.monetization_on,
                    Colors.purple,
                  ),
                  _buildRoleCard(
                    context,
                    'Super Admin',
                    AppConstants.roleSuperAdmin,
                    Icons.security,
                    Colors.red,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRoleCard(BuildContext context, String title, String role, IconData icon, Color color) {
    final count = _roleCounts[role] ?? 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserListPage(role: role, roleTitle: title),
            ),
          ).then((_) => _fetchCounts()); // Refresh counts when returning
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$count User',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
