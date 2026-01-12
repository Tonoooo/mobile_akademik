import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../repositories/admin_repository.dart';
import '../../../models/academic_models.dart';
import '../../../models/user_model.dart';

class ClassFormPage extends StatefulWidget {
  final ClassSessionModel? classSession;
  final String initialMajorId;

  const ClassFormPage({super.key, this.classSession, required this.initialMajorId});

  @override
  State<ClassFormPage> createState() => _ClassFormPageState();
}

class _ClassFormPageState extends State<ClassFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedCourseId;
  String? _selectedDosenId;
  late TextEditingController _sectionController;
  late TextEditingController _dayController;
  late TextEditingController _timeStartController;
  late TextEditingController _timeEndController;
  late TextEditingController _roomController;
  late TextEditingController _quotaController;

  List<CourseModel> _courses = [];
  List<UserModel> _lecturers = [];
  bool _isLoading = false;

  final List<String> _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

  @override
  void initState() {
    super.initState();
    _sectionController = TextEditingController(text: widget.classSession?.section ?? '');
    _dayController = TextEditingController(text: widget.classSession?.day ?? 'Senin');
    _timeStartController = TextEditingController(text: widget.classSession?.timeStart ?? '');
    _timeEndController = TextEditingController(text: widget.classSession?.timeEnd ?? '');
    _roomController = TextEditingController(text: widget.classSession?.room ?? '');
    _quotaController = TextEditingController(text: widget.classSession?.quota.toString() ?? '40');
    
    _selectedCourseId = widget.classSession?.courseId;
    _selectedDosenId = widget.classSession?.dosenId;

    _fetchData();
  }

  Future<void> _fetchData() async {
    final repo = Provider.of<AdminRepository>(context, listen: false);
    
    // Fetch Courses for the major
    final courses = await repo.getCourses(widget.initialMajorId);
    // Fetch Lecturers
    final lecturers = await repo.getUsersByRole('dosen');

    setState(() {
      _courses = courses;
      _lecturers = lecturers;
    });
  }

  @override
  void dispose() {
    _sectionController.dispose();
    _dayController.dispose();
    _timeStartController.dispose();
    _timeEndController.dispose();
    _roomController.dispose();
    _quotaController.dispose();
    super.dispose();
  }

  Future<void> _saveClass() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null || _selectedDosenId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih Mata Kuliah dan Dosen')));
      return;
    }

    setState(() => _isLoading = true);
    final repo = Provider.of<AdminRepository>(context, listen: false);
    
    final classData = ClassSessionModel(
      id: widget.classSession?.id ?? '',
      courseId: _selectedCourseId!,
      dosenId: _selectedDosenId!,
      dosenName: '', // Backend handles this join
      section: _sectionController.text,
      day: _dayController.text,
      timeStart: _timeStartController.text,
      timeEnd: _timeEndController.text,
      room: _roomController.text,
      quota: int.parse(_quotaController.text),
      enrolledCount: 0,
    );

    bool success;
    if (widget.classSession == null) {
      success = await repo.createClass(classData);
    } else {
      success = await repo.updateClass(classData);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil disimpan')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.classSession != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Kelas' : 'Buat Kelas', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Course Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCourseId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Mata Kuliah',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.book),
                ),
                items: _courses.map((course) {
                  return DropdownMenuItem(
                    value: course.id,
                    child: Text('${course.code} - ${course.name}'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedCourseId = value),
                validator: (value) => value == null ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 16),
              
              // Lecturer Dropdown
              DropdownButtonFormField<String>(
                value: _selectedDosenId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Dosen Pengampu',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person),
                ),
                items: _lecturers.map((dosen) {
                  return DropdownMenuItem(
                    value: dosen.id,
                    child: Text(dosen.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedDosenId = value),
                validator: (value) => value == null ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _sectionController,
                decoration: InputDecoration(
                  labelText: 'Nama Kelas (ex: Kelas A)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.class_),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _days.contains(_dayController.text) ? _dayController.text : _days.first,
                decoration: InputDecoration(
                  labelText: 'Hari',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                items: _days.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                onChanged: (value) => setState(() => _dayController.text = value!),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _timeStartController,
                      decoration: InputDecoration(
                        labelText: 'Jam Mulai (HH:MM)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.access_time),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _timeEndController,
                      decoration: InputDecoration(
                        labelText: 'Jam Selesai (HH:MM)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.access_time_filled),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _roomController,
                      decoration: InputDecoration(
                        labelText: 'Ruangan',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.room),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _quotaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Kuota',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.people),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveClass,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Simpan',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
