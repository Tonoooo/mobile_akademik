import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TugasPage extends StatelessWidget {
  const TugasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tugas', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Belum ada tugas yang harus dikerjakan', style: GoogleFonts.poppins(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
