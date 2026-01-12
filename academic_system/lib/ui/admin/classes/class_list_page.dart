import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../repositories/admin_repository.dart';
import '../../../models/academic_models.dart';
import 'class_form_page.dart';

class ClassListPage extends StatefulWidget {
  const ClassListPage({super.key});

  @override
  State<ClassListPage> createState() => _ClassListPageState();
}

class _ClassListPageState extends State<ClassListPage> {
  List<ClassSessionModel> _classes = [];
  List<MajorModel> _majors = [];
  MajorModel? _selectedMajor;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<AdminRepository>(context, listen: false);
    
    final majors = await repo.getMajors();
    setState(() {
      _majors = majors;
      if (_majors.isNotEmpty) {
        _selectedMajor = _majors.first;
      }
    });

    if (_selectedMajor != null) {
      await _fetchClasses();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchClasses() async {
    if (_selectedMajor == null) return;
    
    setState(() => _isLoading = true);
    final repo = Provider.of<AdminRepository>(context, listen: false);
    final classes = await repo.getClasses(_selectedMajor!.id);
    setState(() {
      _classes = classes;
      _isLoading = false;
    });
  }

  Future<void> _deleteClass(ClassSessionModel classSession) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kelas'),
        content: Text('Apakah Anda yakin ingin menghapus kelas ${classSession.course?.name} (${classSession.section})?'),
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
      final success = await repo.deleteClass(classSession.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kelas berhasil dihapus')),
        );
        _fetchClasses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus kelas')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jadwal & Kelas', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: _selectedMajor == null ? null : FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClassFormPage(initialMajorId: _selectedMajor!.id),
            ),
          ).then((_) => _fetchClasses());
        },
        backgroundColor: const Color(0xFF667EEA),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: DropdownButtonFormField<MajorModel>(
              value: _selectedMajor,
              decoration: InputDecoration(
                labelText: 'Pilih Jurusan',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: _majors.map((major) {
                return DropdownMenuItem(
                  value: major,
                  child: Text(major.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMajor = value;
                });
                _fetchClasses();
              },
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _classes.isEmpty
                    ? Center(child: Text(_selectedMajor == null ? 'Pilih Jurusan terlebih dahulu' : 'Belum ada Kelas di jurusan ini'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _classes.length,
                        itemBuilder: (context, index) {
                          final cls = _classes[index];
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
                                      Expanded(
                                        child: Text(
                                          cls.course?.name ?? 'Unknown Course',
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
                                          cls.section,
                                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.person, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(cls.dosenName, style: const TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.schedule, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text('${cls.day}, ${cls.timeStart} - ${cls.timeEnd} @ ${cls.room}', style: const TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ClassFormPage(classSession: cls, initialMajorId: _selectedMajor!.id),
                                            ),
                                          ).then((_) => _fetchClasses());
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteClass(cls),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
