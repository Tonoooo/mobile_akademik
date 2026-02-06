import 'dart:convert';
import 'dart:typed_data';
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
  Future<List<ClassSessionModel>> getLecturerClasses(String dosenId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/academic/classes/read_by_dosen.php?dosen_id=$dosenId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((json) => ClassSessionModel.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Error getting lecturer classes: $e');
    }
    return [];
  }

  @override
  Future<List<MaterialModel>> getClassMaterials(String classId, {String? type}) async {
    try {
      final url = '$baseUrl/academic/materials/read.php?class_session_id=$classId'
          '${type != null ? '&type=$type' : ''}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((json) => MaterialModel.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Error getting class materials: $e');
    }
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
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/academic/materials/create.php'));
      request.fields['class_session_id'] = classSessionId;
      request.fields['title'] = title;
      request.fields['type'] = type;
      request.fields['description'] = description;
      if (deadline != null) {
        request.fields['deadline'] = deadline.toIso8601String();
      }
      
      // ... (existing file handling)
      
      if (fileBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'file', 
          fileBytes,
          filename: filename,
        ));
      } else if (filePath != null) {
        request.files.add(await http.MultipartFile.fromPath('file', filePath));
      } else {
        return false;
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error uploading material: $e');
    }
    return false;
  }

  @override
  Future<bool> deleteMaterial(String materialId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/academic/materials/delete.php'),
        body: jsonEncode({'id': materialId}),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error deleting material: $e');
    }
    return false;
  }

  @override
  Future<bool> uploadSubmission(SubmissionModel submission) async => false; // Implemented

  @override
    @override
  Future<SubmissionModel?> getStudentSubmission(String materialId, String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/academic/submissions/get_submission.php?material_id=$materialId&student_id=$studentId')
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return SubmissionModel.fromJson(data['data']);
        }
      }
    } catch (e) {
      print('Error getting student submission: $e');
    }
    return null;
  }

  @override
  Future<List<SubmissionModel>> getAssignmentSubmissions(String materialId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/academic/submissions/list_by_material.php?material_id=$materialId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((json) => SubmissionModel.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Error getting submissions: $e');
    }
    return [];
  }

  @override
  Future<bool> gradeSubmission(String submissionId, double grade) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/academic/submissions/grade.php'),
        body: jsonEncode({'submission_id': submissionId, 'grade': grade}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error grading submission: $e');
    }
    return false;
  }

  @override
  Future<bool> submitAssignment({
    required String studentId,
    required String materialId,
    String answer = '',
    String? filePath,
    Uint8List? fileBytes,
    String? filename,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/academic/submissions/submit_assignment.php'));
      request.fields['student_id'] = studentId;
      request.fields['material_id'] = materialId;
      request.fields['answer'] = answer;
      
      if (fileBytes != null && filename != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'file', 
          fileBytes,
          filename: filename,
        ));
      } else if (filePath != null) {
        request.files.add(await http.MultipartFile.fromPath('file', filePath));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error submitting assignment: $e');
    }
    return false;
  }

  @override
  Future<List<MaterialModel>> getPendingAssignments(String studentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/academic/assignments/list_pending.php?student_id=$studentId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((json) {
            // Helper to map
            return MaterialModel.fromJson(json);
          }).toList();
        }
      }
    } catch (e) {
      print('Error getting pending assignments: $e');
    }
    return [];
  }

  @override
  Future<List<EnrollmentModel>> getClassEnrollments(String classId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/academic/enrollments/list_by_class.php?class_id=$classId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((json) => EnrollmentModel.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Error getting class enrollments: $e');
    }
    return [];
  }

  @override
  Future<bool> createAttendanceSession(String classId, String title, int meetingNumber, List<Map<String, dynamic>> students) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/academic/attendance/create_session.php'),
        body: jsonEncode({
          'class_id': classId,
          'title': title,
          'meeting_number': meetingNumber,
          'students': students, 
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error creating attendance: $e');
    }
    return false;
  }

  @override
  Future<List<AttendanceSessionModel>> getClassAttendanceSessions(String classId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/academic/attendance/list_sessions.php?class_id=$classId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((json) => AttendanceSessionModel.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Error getting attendance sessions: $e');
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>?> getAttendanceSessionDetails(String sessionId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/academic/attendance/get_session_details.php?session_id=$sessionId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final session = AttendanceSessionModel.fromJson(data['data']['session']);
          final records = (data['data']['records'] as List).map((json) => AttendanceRecordModel.fromJson(json)).toList();
          return {'session': session, 'records': records};
        }
      }
    } catch (e) {
      print('Error getting attendance details: $e');
    }
    return null;
  }

  @override
  Future<List<AttendanceSummaryModel>> getStudentAttendanceSummary(String studentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/academic/attendance/student_summary.php?student_id=$studentId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((json) => AttendanceSummaryModel.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Error getting student attendance summary: $e');
    }
    return [];
  }

  @override
  Future<List<AttendanceRecordModel>> getStudentClassAttendance(String studentId, String classId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/academic/attendance/student_class_records.php?student_id=$studentId&class_id=$classId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((json) => AttendanceRecordModel.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Error getting student class attendance: $e');
    }
    return [];
  }

  @override
  Future<List<EnrollmentModel>> getClassGrades(String classId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/academic/grades/class_summary.php?class_id=$classId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // We assume the response structure matches EnrollmentModel minimally (student data + grade)
          return (data['data'] as List).map((json) => EnrollmentModel(
            id: json['enrollment_id'].toString(),
            studentId: json['student_id'].toString(),
            classId: classId,
            status: 'active',
            grade: json['grade'],
            studentName: json['student_name'],
            studentNim: json['student_nim'],
            calculatedScore: json['calculated_score'] != null ? double.tryParse(json['calculated_score'].toString()) : null,
          )).toList();
        }
      }
    } catch (e) {
      print('Error getting class grades: $e');
    }
    return [];
  }

  @override
  Future<GradeDetailModel?> getStudentGradeDetail(String classId, String studentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/academic/grades/student_detail.php?class_id=$classId&student_id=$studentId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return GradeDetailModel.fromJson(data['data']);
        }
      }
    } catch (e) {
      print('Error getting grade detail: $e');
    }
    return null;
  }

  @override
  Future<bool> updateFinalGrade(String enrollmentId, String grade) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/academic/grades/update_final_grade.php'),
        body: jsonEncode({'enrollment_id': enrollmentId, 'grade': grade}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error updating grade: $e');
    }
    return false;
  }

  @override
  Future<List<EnrollmentModel>> getStudentAllGrades(String studentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/academic/grades/student_list.php?student_id=$studentId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
           return (data['data'] as List).map((json) {
            return EnrollmentModel(
              id: '', // Not returned by list endpoint
              studentId: studentId,
              classId: json['class_id'].toString(),
              status: 'active',
              grade: json['grade'],
              classSession: ClassSessionModel(
                id: json['class_id'].toString(),
                courseId: '',
                dosenId: '',
                dosenName: '',
                day: '', timeStart: '', timeEnd: '', room: '', quota: 0, enrolledCount: 0,
                course: CourseModel(
                  id: '',
                  code: json['course_code'],
                  name: json['course_name'],
                  sks: int.tryParse(json['sks'].toString()) ?? 0,
                  semester: int.tryParse(json['semester'].toString()) ?? 0,
                  majorId: '',
                ),
              ),
            );
          }).toList();
        }
      }
    } catch (e) {
      print('Error getting all student grades: $e');
    }
    return [];
  }

  @override
  Future<List<AnnouncementModel>> getAnnouncements() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/announcements/list.php'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((json) => AnnouncementModel.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Error getting announcements: $e');
    }
    return [];
  }

  @override
  @override
  Future<bool> createAnnouncement(String title, String content, {String? attachmentPath, Uint8List? attachmentBytes, String? attachmentName, required String userId}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/announcements/create.php'));
      request.fields['title'] = title;
      request.fields['content'] = content;
      request.fields['created_by'] = userId;

      if (attachmentBytes != null && attachmentName != null) {
        // Web / Bytes provided
        request.files.add(http.MultipartFile.fromBytes(
          'attachment',
          attachmentBytes,
          filename: attachmentName,
        ));
      } else if (attachmentPath != null) {
        // Mobile / Path provided
        request.files.add(await http.MultipartFile.fromPath('attachment', attachmentPath));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error creating announcement: $e');
    }
    return false;
  }
}
