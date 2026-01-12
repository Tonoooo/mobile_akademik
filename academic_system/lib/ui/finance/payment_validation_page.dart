import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';

class PaymentValidationPage extends StatefulWidget {
  const PaymentValidationPage({super.key});

  @override
  State<PaymentValidationPage> createState() => _PaymentValidationPageState();
}

class _PaymentValidationPageState extends State<PaymentValidationPage> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _students = [];
  List<UserModel> _filteredStudents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() => _isLoading = true);
    try {
      // Fetch all students (role=mahasiswa)
      // In a real app with many users, we should use server-side search.
      // For this UAS, fetching all and filtering locally is acceptable.
      final response = await http.get(
        Uri.parse('https://sitono.online/manajer_data/api/users/read.php?role=mahasiswa'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> usersJson = data['data'];
          setState(() {
            _students = usersJson.map((json) => UserModel.fromJson(json)).toList();
            _filteredStudents = _students;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching students: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterStudents(String query) {
    if (query.isEmpty) {
      setState(() => _filteredStudents = _students);
    } else {
      setState(() {
        _filteredStudents = _students.where((student) {
          final name = student.name.toLowerCase();
          final nim = (student.nimOrNip ?? '').toLowerCase();
          final search = query.toLowerCase();
          return name.contains(search) || nim.contains(search);
        }).toList();
      });
    }
  }

  Future<void> _validatePayment(UserModel student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validasi Pembayaran'),
        content: Text('Validasi pembayaran semester untuk ${student.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Validasi'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.post(
          Uri.parse('https://sitono.online/manajer_data/api/finance/validate_payment.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'student_id': student.id,
            'status': 'paid',
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pembayaran berhasil divalidasi')),
            );
            _fetchStudents(); // Refresh list
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'] ?? 'Gagal validasi')),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Validasi Pembayaran', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Mahasiswa (Nama / NIM)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _filterStudents,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStudents.isEmpty
                    ? Center(child: Text('Tidak ada data mahasiswa', style: GoogleFonts.poppins(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = _filteredStudents[index];
                          final isPaid = student.paymentStatus == 'paid';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                child: Icon(
                                  isPaid ? Icons.check_circle : Icons.pending,
                                  color: isPaid ? Colors.green : Colors.orange,
                                ),
                              ),
                              title: Text(
                                student.name,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${student.nimOrNip} • ${student.majorName ?? '-'}'),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isPaid ? Colors.green : Colors.orange,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isPaid ? 'LUNAS' : 'BELUM BAYAR',
                                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: isPaid
                                  ? null
                                  : ElevatedButton(
                                      onPressed: () => _validatePayment(student),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF667EEA),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Validasi', style: TextStyle(color: Colors.white)),
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
