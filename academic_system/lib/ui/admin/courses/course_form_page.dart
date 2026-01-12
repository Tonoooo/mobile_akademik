import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../repositories/admin_repository.dart';
import '../../../models/academic_models.dart';

class CourseFormPage extends StatefulWidget {
  final CourseModel? course;
  final String initialMajorId;

  const CourseFormPage({super.key, this.course, required this.initialMajorId});

  @override
  State<CourseFormPage> createState() => _CourseFormPageState();
}

class _CourseFormPageState extends State<CourseFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _sksController;
  late TextEditingController _semesterController;
  String? _selectedMajorId;
  List<MajorModel> _majors = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.course?.code ?? '');
    _nameController = TextEditingController(text: widget.course?.name ?? '');
    _sksController = TextEditingController(text: widget.course?.sks.toString() ?? '');
    _semesterController = TextEditingController(text: widget.course?.semester.toString() ?? '');
    _selectedMajorId = widget.course?.majorId ?? widget.initialMajorId;
    _fetchMajors();
  }

  Future<void> _fetchMajors() async {
    final repo = Provider.of<AdminRepository>(context, listen: false);
    final majors = await repo.getMajors();
    setState(() {
      _majors = majors;
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _sksController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMajorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih Jurusan')));
      return;
    }

    setState(() => _isLoading = true);
    final repo = Provider.of<AdminRepository>(context, listen: false);
    
    bool success;
    if (widget.course == null) {
      // Create
      final newCourse = CourseModel(
        id: '',
        code: _codeController.text,
        name: _nameController.text,
        sks: int.parse(_sksController.text),
        semester: int.parse(_semesterController.text),
        majorId: _selectedMajorId!,
      );
      success = await repo.createCourse(newCourse);
    } else {
      // Update
      final updatedCourse = CourseModel(
        id: widget.course!.id,
        code: _codeController.text,
        name: _nameController.text,
        sks: int.parse(_sksController.text),
        semester: int.parse(_semesterController.text),
        majorId: _selectedMajorId!,
      );
      success = await repo.updateCourse(updatedCourse);
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
    final isEdit = widget.course != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Mata Kuliah' : 'Tambah Mata Kuliah', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
              DropdownButtonFormField<String>(
                value: _selectedMajorId,
                decoration: InputDecoration(
                  labelText: 'Jurusan',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.domain),
                ),
                items: _majors.map((major) {
                  return DropdownMenuItem(
                    value: major.id,
                    child: Text(major.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMajorId = value;
                  });
                },
                validator: (value) => value == null ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Kode Matkul (ex: IF101)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.code),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Mata Kuliah',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.book),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sksController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'SKS',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.format_list_numbered),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _semesterController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Semester',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.timeline),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveCourse,
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
