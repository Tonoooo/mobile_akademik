import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../repositories/admin_repository.dart';
import '../../../models/user_model.dart';
import '../../../models/academic_models.dart';

class UserFormPage extends StatefulWidget {
  final UserModel? user;
  final String? initialRole;

  const UserFormPage({super.key, this.user, this.initialRole});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _nimNipController;
  late TextEditingController _passwordController;
  
  String _role = 'mahasiswa';
  String? _selectedMajorId;
  String? _selectedDosenWaliId;
  
  List<MajorModel> _majors = [];
  List<UserModel> _dosenList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _nimNipController = TextEditingController(text: widget.user?.nimOrNip ?? '');
    _passwordController = TextEditingController();
    
    _role = widget.user?.role ?? widget.initialRole ?? 'mahasiswa';
    _selectedMajorId = widget.user?.majorId;
    _selectedDosenWaliId = widget.user?.dosenWaliId;

    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<AdminRepository>(context, listen: false);
    
    try {
      final majors = await repo.getMajors();
      final dosenList = await repo.getUsersByRole('dosen');
      
      if (mounted) {
        setState(() {
          _majors = majors;
          _dosenList = dosenList;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching form data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final repo = Provider.of<AdminRepository>(context, listen: false);

    final user = UserModel(
      id: widget.user?.id ?? '',
      email: '', // Backend handles email/username
      name: _nameController.text,
      role: _role,
      nimOrNip: _nimNipController.text,
      majorId: _selectedMajorId,
      dosenWaliId: _role == 'mahasiswa' ? _selectedDosenWaliId : null,
    );

    bool success;
    if (widget.user == null) {
      success = await repo.createUser(user, _passwordController.text);
    } else {
      success = await repo.updateUser(user, _passwordController.text.isEmpty ? null : _passwordController.text);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User berhasil ${widget.user == null ? 'dibuat' : 'diupdate'}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan user')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Tambah User' : 'Edit User', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _role,
                      decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'mahasiswa', child: Text('Mahasiswa')),
                        DropdownMenuItem(value: 'dosen', child: Text('Dosen')),
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        DropdownMenuItem(value: 'keuangan', child: Text('Keuangan')),
                      ],
                      onChanged: widget.user == null 
                          ? (val) => setState(() => _role = val!) 
                          : null, // Disable role change on edit
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nimNipController,
                      decoration: InputDecoration(
                        labelText: _role == 'mahasiswa' ? 'NIM' : 'NIP / Username',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
                      validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: widget.user == null ? 'Password' : 'Password (Kosongkan jika tidak diubah)',
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (val) => (widget.user == null && val!.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    if (_role == 'mahasiswa' || _role == 'dosen')
                      DropdownButtonFormField<String>(
                        value: _selectedMajorId,
                        decoration: const InputDecoration(labelText: 'Jurusan', border: OutlineInputBorder()),
                        items: _majors.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
                        onChanged: (val) => setState(() => _selectedMajorId = val),
                        validator: (val) => val == null ? 'Wajib dipilih' : null,
                      ),
                    
                    if (_role == 'mahasiswa') ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedDosenWaliId,
                        decoration: const InputDecoration(labelText: 'Dosen Wali', border: OutlineInputBorder()),
                        items: [
                          const DropdownMenuItem<String>(value: null, child: Text('- Pilih Dosen Wali -')),
                          ..._dosenList.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))),
                        ],
                        onChanged: (val) => setState(() => _selectedDosenWaliId = val),
                      ),
                    ],

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Simpan', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
