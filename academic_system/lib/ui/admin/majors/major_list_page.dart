import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../repositories/admin_repository.dart';
import '../../../models/academic_models.dart';
import 'major_form_page.dart';

class MajorListPage extends StatefulWidget {
  const MajorListPage({super.key});

  @override
  State<MajorListPage> createState() => _MajorListPageState();
}

class _MajorListPageState extends State<MajorListPage> {
  List<MajorModel> _majors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMajors();
  }

  Future<void> _fetchMajors() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<AdminRepository>(context, listen: false);
    final majors = await repo.getMajors();
    setState(() {
      _majors = majors;
      _isLoading = false;
    });
  }

  Future<void> _deleteMajor(MajorModel major) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jurusan'),
        content: Text('Apakah Anda yakin ingin menghapus ${major.name}?'),
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
      final success = await repo.deleteMajor(major.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jurusan berhasil dihapus')),
        );
        _fetchMajors();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus jurusan (Mungkin masih ada data terkait)')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Jurusan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MajorFormPage()),
          ).then((_) => _fetchMajors());
        },
        backgroundColor: const Color(0xFF667EEA),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _majors.isEmpty
              ? Center(child: Text('Belum ada data Jurusan'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _majors.length,
                  itemBuilder: (context, index) {
                    final major = _majors[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.withOpacity(0.1),
                          child: Text(
                            major.code,
                            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        title: Text(major.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MajorFormPage(major: major),
                                  ),
                                ).then((_) => _fetchMajors());
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMajor(major),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
