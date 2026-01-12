import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../repositories/admin_repository.dart';
import '../../../models/academic_models.dart';
import 'course_form_page.dart';

class CourseListPage extends StatefulWidget {
  const CourseListPage({super.key});

  @override
  State<CourseListPage> createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage> {
  List<CourseModel> _courses = [];
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
    
    // Fetch Majors first
    final majors = await repo.getMajors();
    setState(() {
      _majors = majors;
      if (_majors.isNotEmpty) {
        _selectedMajor = _majors.first; // Default select first major
      }
    });

    if (_selectedMajor != null) {
      await _fetchCourses();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchCourses() async {
    if (_selectedMajor == null) return;
    
    setState(() => _isLoading = true);
    final repo = Provider.of<AdminRepository>(context, listen: false);
    final courses = await repo.getCourses(_selectedMajor!.id);
    setState(() {
      _courses = courses;
      _isLoading = false;
    });
  }

  Future<void> _deleteCourse(CourseModel course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Mata Kuliah'),
        content: Text('Apakah Anda yakin ingin menghapus ${course.name}?'),
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
      final success = await repo.deleteCourse(course.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mata Kuliah berhasil dihapus')),
        );
        _fetchCourses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus mata kuliah')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Mata Kuliah', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: _selectedMajor == null ? null : FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseFormPage(initialMajorId: _selectedMajor!.id),
            ),
          ).then((_) => _fetchCourses());
        },
        backgroundColor: const Color(0xFF667EEA),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Major Filter Dropdown
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
                _fetchCourses();
              },
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _courses.isEmpty
                    ? Center(child: Text(_selectedMajor == null ? 'Pilih Jurusan terlebih dahulu' : 'Belum ada Mata Kuliah di jurusan ini'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _courses.length,
                        itemBuilder: (context, index) {
                          final course = _courses[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.withOpacity(0.1),
                                child: Text(
                                  '${course.semester}',
                                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(course.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                              subtitle: Text('${course.code} • ${course.sks} SKS'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CourseFormPage(course: course, initialMajorId: _selectedMajor!.id),
                                        ),
                                      ).then((_) => _fetchCourses());
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteCourse(course),
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
