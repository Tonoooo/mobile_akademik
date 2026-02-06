import 'dart:async';
import 'dart:typed_data';
import '../models/academic_models.dart';
import '../models/user_model.dart';
import 'academic_repository.dart';

class MockAcademicRepository implements AcademicRepository {
  @override
  Future<UserModel?> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (username == 'dosen' && password == 'dosen') {
      return UserModel(
        id: '1',
        nimOrNip: '198501012010011001',
        name: 'Dr. Budi Santoso, M.Kom.',
        role: 'dosen',
        email: 'budi@university.ac.id',
      );
    } else if (username == 'mahasiswa' && password == 'mahasiswa') {
      return UserModel(
        id: '2',
        nimOrNip: '20200801001',
        name: 'Andi Pratama',
        role: 'mahasiswa',
        email: 'andi@student.university.ac.id',
      );
    }
    return null;
  }

  @override
  Future<List<ClassSessionModel>> getTodayClasses(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  @override
  Future<List<ClassSessionModel>> getWeeklySchedule(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  @override
  Future<List<ClassSessionModel>> getAvailableClasses({String? majorId}) async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  @override
  Future<List<EnrollmentModel>> getStudentEnrollments(String studentId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  @override
  Future<bool> enrollClass(String studentId, String classId) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  @override
  Future<bool> dropClass(String studentId, String classId) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  @override
  Future<bool> submitKRS(String studentId) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  @override
  Future<List<UserModel>> getAdvisees(String dosenId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  @override
  Future<bool> approveKRS(String studentId, String status) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  @override
  Future<List<ClassSessionModel>> getLecturerClasses(String dosenId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  @override
  Future<List<MaterialModel>> getClassMaterials(String classId, {String? type}) async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  @override
  Future<bool> uploadMaterial({
    required String classSessionId,
    required String title,
    required String type,
    String description = '',
    DateTime? deadline,
    String? filePath,
    Uint8List? fileBytes,
    required String filename,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  @override
  Future<bool> deleteMaterial(String materialId) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
  
  @override
  Future<List<EnrollmentModel>> getClassEnrollments(String classId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  @override
  Future<bool> createAttendanceSession(String classId, String title, int meetingNumber, List<Map<String, dynamic>> students) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  @override
  Future<List<AttendanceSessionModel>> getClassAttendanceSessions(String classId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  @override
  Future<Map<String, dynamic>?> getAttendanceSessionDetails(String sessionId) async {
    await Future.delayed(const Duration(seconds: 1));
    return null;
  }

  @override
  Future<List<AttendanceSummaryModel>> getStudentAttendanceSummary(String studentId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  @override
  Future<List<AttendanceRecordModel>> getStudentClassAttendance(String studentId, String classId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  @override
  Future<bool> uploadSubmission(SubmissionModel submission) async => false;

  @override
  Future<SubmissionModel?> getStudentSubmission(String materialId, String studentId) async => null;

  @override
  Future<List<SubmissionModel>> getAssignmentSubmissions(String materialId) async => [];

  @override
  Future<bool> gradeSubmission(String submissionId, double grade) async => true;

  @override
  Future<bool> submitAssignment({
    required String studentId,
    required String materialId,
    String answer = '',
    String? filePath,
    Uint8List? fileBytes,
    String? filename,
  }) async => true;
}
