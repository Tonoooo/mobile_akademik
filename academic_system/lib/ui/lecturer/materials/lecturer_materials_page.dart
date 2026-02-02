import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../repositories/academic_repository.dart';
import '../../../models/academic_models.dart';

class LecturerMaterialsPage extends StatefulWidget {
  final ClassSessionModel classSession;

  const LecturerMaterialsPage({super.key, required this.classSession});

  @override
  State<LecturerMaterialsPage> createState() => _LecturerMaterialsPageState();
}

class _LecturerMaterialsPageState extends State<LecturerMaterialsPage> {
  List<MaterialModel> _materials = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchMaterials();
  }

  Future<void> _fetchMaterials() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<AcademicRepository>(context, listen: false);
    final materials = await repo.getClassMaterials(widget.classSession.id);
    if (mounted) {
      setState(() {
        _materials = materials;
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadMaterial() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'jpg', 'png', 'zip'],
    );

    if (result != null) {
      // Show dialog to enter title
      final titleController = TextEditingController(text: result.files.single.name);
      
      if (!mounted) return;
      final shouldUpload = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Upload Materi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Judul Materi'),
              ),
              const SizedBox(height: 8),
              Text('File: ${result.files.single.name}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Upload')),
          ],
        ),
      );

      if (shouldUpload == true) {
        setState(() => _isUploading = true);
        final repo = Provider.of<AcademicRepository>(context, listen: false);
        
        final success = await repo.uploadMaterial(
          classSessionId: widget.classSession.id,
          title: titleController.text,
          filePath: result.files.single.path, // Can be null on web
          fileBytes: result.files.single.bytes, // Available on web
          filename: result.files.single.name,
          type: 'materi',
        );

        setState(() => _isUploading = false);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Materi berhasil diupload')));
          _fetchMaterials();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal upload materi')));
        }
      }
    }
  }

  Future<void> _deleteMaterial(MaterialModel material) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Materi'),
        content: Text('Yakin ingin menghapus "${material.title}"?'),
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
      final repo = Provider.of<AcademicRepository>(context, listen: false);
      final success = await repo.deleteMaterial(material.id);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Materi dihapus')));
        _fetchMaterials();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menghapus materi')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Materi Kelas', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _uploadMaterial,
        label: Text(_isUploading ? 'Uploading...' : 'Upload Materi'),
        icon: _isUploading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.upload_file),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _materials.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('Belum ada materi', style: GoogleFonts.poppins(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _materials.length,
                  itemBuilder: (context, index) {
                    final material = _materials[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.description, color: Colors.blue),
                        ),
                        title: Text(material.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        subtitle: Text(DateFormat('dd MMM yyyy HH:mm').format(material.createdAt), style: GoogleFonts.poppins(fontSize: 12)),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'download',
                              child: Row(children: [Icon(Icons.download, size: 18), SizedBox(width: 8), Text('Download')]),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))]),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deleteMaterial(material);
                            } else if (value == 'download') {
                              launchUrl(Uri.parse(material.fileUrl), mode: LaunchMode.externalApplication);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
