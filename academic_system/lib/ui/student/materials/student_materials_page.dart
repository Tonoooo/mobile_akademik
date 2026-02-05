import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../repositories/academic_repository.dart';
import '../../../models/academic_models.dart';

class StudentMaterialsPage extends StatefulWidget {
  final ClassSessionModel classSession;

  const StudentMaterialsPage({super.key, required this.classSession});

  @override
  State<StudentMaterialsPage> createState() => _StudentMaterialsPageState();
}

class _StudentMaterialsPageState extends State<StudentMaterialsPage> {
  List<MaterialModel> _materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMaterials();
  }

  Future<void> _fetchMaterials() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<AcademicRepository>(context, listen: false);
    // Fetch only 'materi' type
    final materials = await repo.getClassMaterials(widget.classSession.id, type: 'materi');
    if (mounted) {
      setState(() {
        _materials = materials;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Materi Kelas', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        elevation: 0,
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
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DataTable(
                        columns: [
                          const DataColumn(label: Text('No')),
                          const DataColumn(label: Text('Judul Materi')),
                          const DataColumn(label: Text('Tipe')),
                          const DataColumn(label: Text('Tanggal Upload')),
                          const DataColumn(label: Text('Aksi')),
                        ],
                        rows: List<DataRow>.generate(
                          _materials.length,
                          (index) {
                            final material = _materials[index];
                            return DataRow(
                              cells: [
                                DataCell(Text('${index + 1}')),
                                DataCell(Text(material.title)),
                                DataCell(Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    material.type.toUpperCase(),
                                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600),
                                  ),
                                )),
                                DataCell(Text(DateFormat('dd MMM yyyy HH:mm').format(material.createdAt))),
                                DataCell(IconButton(
                                  icon: const Icon(Icons.download, color: Colors.green),
                                  onPressed: () => launchUrl(Uri.parse(material.fileUrl), mode: LaunchMode.externalApplication),
                                  tooltip: 'Download',
                                )),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
