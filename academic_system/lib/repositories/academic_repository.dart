import '../models/academic_models.dart';
import '../models/user_model.dart';

abstract class AcademicRepository {
  // Read
  Future<List<ClassSessionModel>> getAvailableClasses({String? majorId});
  Future<List<EnrollmentModel>> getStudentEnrollments(String studentId);
  
  // Write
  Future<bool> enrollClass(String studentId, String classId);
  Future<bool> dropClass(String studentId, String classId);
  Future<bool> submitKRS(String studentId);
  
  // Dosen / Advisory
  Future<List<UserModel>> getAdvisees(String dosenId);
  Future<bool> approveKRS(String studentId, String status); // status: 'approved' or 'rejected'

  // Materials & Submissions
  Future<List<MaterialModel>> getClassMaterials(String classId);
  Future<bool> uploadSubmission(SubmissionModel submission);
  Future<SubmissionModel?> getStudentSubmission(String materialId, String studentId);
}

class MockAcademicRepository implements AcademicRepository {
  // Mock Master Data Courses
  final List<CourseModel> _courses = [
    CourseModel(id: 'c1', code: 'IF101', name: 'Algoritma Pemrograman', sks: 3, semester: 1, majorId: 'dummy'),
    CourseModel(id: 'c2', code: 'IF102', name: 'Struktur Data', sks: 4, semester: 2, majorId: 'dummy'),
    CourseModel(id: 'c3', code: 'IF201', name: 'Pemrograman Mobile', sks: 3, semester: 4, majorId: 'dummy'),
    CourseModel(id: 'c4', code: 'IF202', name: 'Basis Data', sks: 3, semester: 3, majorId: 'dummy'),
    CourseModel(id: 'c5', code: 'IF301', name: 'Kecerdasan Buatan', sks: 3, semester: 5, majorId: 'dummy'),
  ];

  // Mock Active Classes (Jadwal)
  late List<ClassSessionModel> _classes;
  
  // Mock Enrollments (KRS)
  final List<EnrollmentModel> _enrollments = [];

  // Mock Materials
  final List<MaterialModel> _materials = [];
  final List<SubmissionModel> _submissions = [];

  MockAcademicRepository() {
    _initMockData();
  }

  void _initMockData() {
    _classes = [
      ClassSessionModel(
        id: 'cls1', courseId: 'c1', dosenId: '3', dosenName: 'Budi Santoso, M.Kom',
        day: 'Senin', timeStart: '08:00', timeEnd: '10:30', room: 'R.101', quota: 30, enrolledCount: 0,
        course: _courses[0],
      ),
      ClassSessionModel(
        id: 'cls2', courseId: 'c2', dosenId: '3', dosenName: 'Budi Santoso, M.Kom',
        day: 'Selasa', timeStart: '10:00', timeEnd: '13:30', room: 'Lab.1', quota: 25, enrolledCount: 0,
        course: _courses[1],
      ),
      ClassSessionModel(
        id: 'cls3', courseId: 'c3', dosenId: '99', dosenName: 'Siti Aminah, M.T',
        day: 'Rabu', timeStart: '13:00', timeEnd: '15:30', room: 'Lab.Mobile', quota: 20, enrolledCount: 5,
        course: _courses[2],
      ),
      ClassSessionModel(
        id: 'cls4', courseId: 'c4', dosenId: '99', dosenName: 'Siti Aminah, M.T',
        day: 'Kamis', timeStart: '08:00', timeEnd: '10:30', room: 'R.202', quota: 40, enrolledCount: 10,
        course: _courses[3],
      ),
    ];

    // Add some mock materials for Algoritma Pemrograman (cls1)
    _materials.add(MaterialModel(
      id: 'm1', classId: 'cls1', title: 'Pengantar Algoritma', description: 'Slide pertemuan 1',
      fileUrl: 'slide_pertemuan_1.pdf', type: 'material', createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ));
    _materials.add(MaterialModel(
      id: 'm2', classId: 'cls1', title: 'Tugas 1: Flowchart', description: 'Kerjakan soal di slide halaman 10',
      fileUrl: 'soal_tugas_1.pdf', type: 'tugas', createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ));
  }

  @override
  Future<List<ClassSessionModel>> getAvailableClasses({String? majorId}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _classes;
  }

  @override
  Future<List<EnrollmentModel>> getStudentEnrollments(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _enrollments.where((e) => e.studentId == studentId && e.status == 'active').toList();
  }

  @override
  Future<List<MaterialModel>> getClassMaterials(String classId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _materials.where((m) => m.classId == classId).toList();
  }

  @override
  Future<bool> uploadSubmission(SubmissionModel submission) async {
    await Future.delayed(const Duration(seconds: 1));
    _submissions.add(submission);
    return true;
  }

  @override
  Future<SubmissionModel?> getStudentSubmission(String materialId, String studentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _submissions.firstWhere((s) => s.materialId == materialId && s.studentId == studentId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> enrollClass(String studentId, String classId) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Check if already enrolled
    final isEnrolled = _enrollments.any((e) => 
      e.studentId == studentId && e.classId == classId && e.status == 'active'
    );
    if (isEnrolled) throw Exception('Anda sudah mengambil kelas ini');

    // Check quota (Mock logic)
    final classIndex = _classes.indexWhere((c) => c.id == classId);
    if (classIndex == -1) throw Exception('Kelas tidak ditemukan');
    
    if (_classes[classIndex].enrolledCount >= _classes[classIndex].quota) {
      throw Exception('Kelas penuh');
    }

    // Add Enrollment
    final newEnrollment = EnrollmentModel(
      id: 'enr_${DateTime.now().millisecondsSinceEpoch}',
      studentId: studentId,
      classId: classId,
      status: 'active',
      classSession: _classes[classIndex],
    );
    _enrollments.add(newEnrollment);

    // Update Quota
    // In a real app, this would be atomic. Here we just replace the object for mock.
    // We won't actually update the _classes list count strictly for this simple mock unless needed, 
    // but let's do it for realism.
    // _classes[classIndex] = ... (Skipping complex immutable update for mock simplicity)
    
    return true;
  }

  @override
  Future<bool> dropClass(String studentId, String classId) async {
    await Future.delayed(const Duration(seconds: 1));
    _enrollments.removeWhere((e) => e.studentId == studentId && e.classId == classId);
    return true;
  }

  @override
  Future<bool> submitKRS(String studentId) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  @override
  Future<List<UserModel>> getAdvisees(String dosenId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  @override
  Future<bool> approveKRS(String studentId, String status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}
