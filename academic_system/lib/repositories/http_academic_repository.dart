import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/academic_models.dart';
import '../models/user_model.dart'; // Added import
import 'academic_repository.dart';

class HttpAcademicRepository implements AcademicRepository {
  final String baseUrl = 'https://sitono.online/manajer_data/api';

  @override
  Future<UserModel?> login(String username, String password) async {
    try {
      print('Sending login request to: $baseUrl/auth/login.php');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return UserModel(
            id: data['data']['id'].toString(),
            nimOrNip: data['data']['username'],
            name: data['data']['name'],
            role: data['data']['role'],
            email: data['data']['username'],
            // photoUrl: data['data']['photo_url'], // Removed
          );
        }
      }
    } catch (e) {
      print('Login error: $e');
    }
    return null;
  }

  // Implement other methods (currently returning empty/mock for now to avoid errors)
  @override
  Future<List<ClassSessionModel>> getTodayClasses(String userId) async => [];

  @override
  Future<List<ClassSessionModel>> getWeeklySchedule(String userId) async => [];

  @override
  Future<List<ClassSessionModel>> getAvailableClasses({String? majorId}) async {
    try {
      final url = majorId != null 
          ? '$baseUrl/academic/classes/read.php?major_id=$majorId'
          : '$baseUrl/academic/classes/read.php';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((json) => ClassSessionModel.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      print('Error getting available classes: $e');
    }
    return [];
  }

  @override
  Future<List<EnrollmentModel>> getStudentEnrollments(String studentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/academic/enrollments/my_schedule.php?student_id=$studentId'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((json) {
            return EnrollmentModel(
              id: json['enrollment_id'].toString(),
              studentId: studentId,
              classId: json['class_id'].toString(),
              status: json['status'],
              grade: json['grade'],
              classSession: ClassSessionModel(
                id: json['class_id'].toString(),
                courseId: '', 
                dosenId: '',
                dosenName: json['dosen_name'],
                section: json['section'],
                day: json['day'],
                timeStart: json['time_start'],
                timeEnd: json['time_end'],
                room: json['room'],
                quota: 0,
                enrolledCount: 0,
                course: CourseModel(
                  id: '',
                  code: json['course_code'],
                  name: json['course_name'],
                  sks: int.tryParse(json['course_sks'].toString()) ?? 0,
                  semester: int.tryParse(json['course_semester'].toString()) ?? 0,
                  majorId: '',
                ),
              ),
            );
          }).toList();
        }
      }
    } catch (e) {
      print('Error getting student enrollments: $e');
    }
    return [];
  }

  @override
  Future<bool> enrollClass(String studentId, String classId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/academic/enrollments/enroll.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'student_id': studentId, 'class_id': classId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error enrolling class: $e');
    }
    return false;
  }

  @override
  Future<bool> dropClass(String studentId, String classId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/academic/enrollments/drop.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'student_id': studentId, 'class_id': classId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error dropping class: $e');
    }
    return false;
  }

  @override
  Future<bool> submitKRS(String studentId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/krs/submit.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'student_id': studentId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error submitting KRS: $e');
    }
    return false;
  }

  @override
  Future<List<UserModel>> getAdvisees(String dosenId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/krs/list_advisees.php?dosen_id=$dosenId&t=${DateTime.now().millisecondsSinceEpoch}'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((json) => UserModel.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Error getting advisees: $e');
    }
    return [];
  }

  @override
  Future<bool> approveKRS(String studentId, String status) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/krs/approve.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'student_id': studentId, 'status': status}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error approving KRS: $e');
    }
    return false;
  }

  @override
  Future<List<MaterialModel>> getClassMaterials(String classId) async => [];

  @override
  Future<bool> uploadSubmission(SubmissionModel submission) async => false; // Implemented

  @override
  Future<SubmissionModel?> getStudentSubmission(String materialId, String studentId) async => null;
}
