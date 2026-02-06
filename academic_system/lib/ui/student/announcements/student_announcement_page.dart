import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../models/academic_models.dart';
import '../../../repositories/academic_repository.dart';

class StudentAnnouncementPage extends StatefulWidget {
  const StudentAnnouncementPage({super.key});

  @override
  State<StudentAnnouncementPage> createState() => _StudentAnnouncementPageState();
}

class _StudentAnnouncementPageState extends State<StudentAnnouncementPage> {
  List<AnnouncementModel> _announcements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<AcademicRepository>(context, listen: false);
    final list = await repo.getAnnouncements();
    if (mounted) {
      setState(() {
        _announcements = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadFile(String? url) async {
    if (url == null) return;
    // Construct full URL if needed given the simple backend
    // Backend returns 'uploads/announcements/filename' relative path.
    // Need to prepend domain.
    final fullUrl = Uri.parse('https://sitono.online/manajer_data/$url');
    
    if (await canLaunchUrl(fullUrl)) {
      await launchUrl(fullUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak dapat membuka file')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengumuman', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _announcements.isEmpty
              ? Center(child: Text('Belum ada pengumuman', style: GoogleFonts.poppins()))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _announcements.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = _announcements[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50], 
                                    shape: BoxShape.circle
                                  ),
                                  child: const Icon(Icons.campaign, color: Colors.blue),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${DateFormat('dd MMM yyyy, HH:mm').format(item.createdAt)}',
                                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.content,
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            if (item.attachmentUrl != null) ...[
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () => _downloadFile(item.attachmentUrl),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.blue[200]!),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.download, color: Colors.blue),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Download Lampiran',
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.blue[700]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
