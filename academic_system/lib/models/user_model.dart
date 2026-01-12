class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'superadmin', 'admin', 'dosen', 'mahasiswa', 'keuangan'
  final String? nimOrNip; // NIM for student, NIP for lecturer
  final String? majorId;
  final String? majorName;
  final String paymentStatus; // 'paid', 'unpaid'

  final String? dosenWaliId;
  final String krsStatus; // 'draft', 'submitted', 'approved', 'rejected'

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.nimOrNip,
    this.majorId,
    this.majorName,
    this.paymentStatus = 'unpaid',
    this.dosenWaliId,
    this.krsStatus = 'draft',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      email: json['email'] ?? json['username'] ?? '',
      name: json['name'],
      role: json['role'],
      nimOrNip: json['nimOrNip'] ?? json['username'],
      majorId: json['major_id']?.toString(),
      majorName: json['major_name'],
      paymentStatus: json['payment_status'] ?? 'unpaid',
      dosenWaliId: json['dosen_wali_id']?.toString(),
      krsStatus: json['krs_status'] ?? 'draft',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'nimOrNip': nimOrNip,
      'major_id': majorId,
      'major_name': majorName,
      'payment_status': paymentStatus,
      'dosen_wali_id': dosenWaliId,
      'krs_status': krsStatus,
    };
  }
}
