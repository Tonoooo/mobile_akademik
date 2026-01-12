import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../repositories/admin_repository.dart';
import '../../../models/user_model.dart';
import 'user_form_page.dart';

class UserListPage extends StatefulWidget {
  final String? role;
  final String? roleTitle;

  const UserListPage({super.key, this.role, this.roleTitle});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<UserModel> _users = [];
  
  // For tab view (legacy/default behavior if needed)
  List<UserModel> _students = [];
  List<UserModel> _lecturers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<AdminRepository>(context, listen: false);
    
    if (widget.role != null) {
      // Single role mode
      final users = await repo.getUsersByRole(widget.role!);
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } else {
      // Default tab mode (Mahasiswa & Dosen)
      final students = await repo.getUsersByRole('mahasiswa');
      final lecturers = await repo.getUsersByRole('dosen');
      if (mounted) {
        setState(() {
          _students = students;
          _lecturers = lecturers;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteUser(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus User'),
        content: Text('Apakah Anda yakin ingin menghapus ${user.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final repo = Provider.of<AdminRepository>(context, listen: false);
      final success = await repo.deleteUser(user.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User berhasil dihapus')));
        _fetchUsers();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menghapus user')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSingleRole = widget.role != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roleTitle ?? 'Manajemen User', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        bottom: isSingleRole 
            ? null 
            : TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Mahasiswa'),
                  Tab(text: 'Dosen'),
                ],
              ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : isSingleRole
              ? _buildUserList(_users, widget.role!)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUserList(_students, 'mahasiswa'),
                    _buildUserList(_lecturers, 'dosen'),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserFormPage(
                initialRole: isSingleRole ? widget.role : (_tabController.index == 0 ? 'mahasiswa' : 'dosen'),
              ),
            ),
          );
          if (result == true) _fetchUsers();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUserList(List<UserModel> users, String role) {
    if (users.isEmpty) {
      return Center(child: Text('Belum ada data $role', style: GoogleFonts.poppins()));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: role == 'dosen' ? Colors.orange.shade100 : Colors.blue.shade100,
              child: Icon(
                role == 'dosen' ? Icons.person_outline : Icons.school_outlined,
                color: role == 'dosen' ? Colors.orange : Colors.blue,
              ),
            ),
            title: Text(user.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.nimOrNip ?? '-', style: GoogleFonts.poppins(fontSize: 12)),
                if (user.majorName != null)
                  Text(user.majorName!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                if (role == 'mahasiswa' && user.dosenWaliId != null)
                   Text('Dosen Wali ID: ${user.dosenWaliId}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.green)),
              ],
            ),
            trailing: PopupMenuButton(
              onSelected: (value) async {
                if (value == 'edit') {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserFormPage(user: user)),
                  );
                  if (result == true) _fetchUsers();
                } else if (value == 'delete') {
                  _deleteUser(user);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
        );
      },
    );
  }
}
