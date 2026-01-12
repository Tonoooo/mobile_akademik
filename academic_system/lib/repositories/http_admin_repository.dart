import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/academic_models.dart';
import 'admin_repository.dart';

class HttpAdminRepository implements AdminRepository {
  final String baseUrl = 'https://sitono.online/manajer_data/api/users';

  @override
  Future<Map<String, int>> getRoleCounts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/count_role.php'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Map<String, int>.from(data['data']);
        }
      }
    } catch (e) {
      print('Error getting role counts: $e');
    }
    return {};
  }

  @override
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/read.php?role=$role'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((json) => UserModel.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      print('Error getting users: $e');
    }
    return [];
  }

  @override
  Future<bool> createUser(UserModel user, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': user.nimOrNip, // Using nimOrNip as username
          'password': password,
          'name': user.name,
          'role': user.role,
          'major_id': user.majorId,
          'dosen_wali_id': user.dosenWaliId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error creating user: $e');
    }
    return false;
  }

  @override
  Future<bool> updateUser(UserModel user, String? password) async {
    try {
      final body = {
        'id': user.id,
        'username': user.nimOrNip,
        'name': user.name,
        'role': user.role,
        'major_id': user.majorId,
        'dosen_wali_id': user.dosenWaliId,
      };
      if (password != null && password.isNotEmpty) {
        body['password'] = password;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/update.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error updating user: $e');
    }
    return false;
  }

  @override
  Future<bool> deleteUser(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error deleting user: $e');
    }
    return false;
  }

  // Majors Implementation
  final String academicBaseUrl = 'https://sitono.online/manajer_data/api/academic';

  @override
  Future<List<MajorModel>> getMajors() async {
    try {
      final response = await http.get(Uri.parse('$academicBaseUrl/majors/read.php'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((json) => MajorModel.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      print('Error getting majors: $e');
    }
    return [];
  }

  @override
  Future<bool> createMajor(MajorModel major) async {
    try {
      final response = await http.post(
        Uri.parse('$academicBaseUrl/majors/create.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'code': major.code,
          'name': major.name,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error creating major: $e');
    }
    return false;
  }

  @override
  Future<bool> updateMajor(MajorModel major) async {
    try {
      final response = await http.post(
        Uri.parse('$academicBaseUrl/majors/update.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': major.id,
          'code': major.code,
          'name': major.name,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error updating major: $e');
    }
    return false;
  }

  @override
  Future<bool> deleteMajor(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$academicBaseUrl/majors/delete.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error deleting major: $e');
    }
    return false;
  }

  // Courses Implementation
  @override
  Future<List<CourseModel>> getCourses(String? majorId) async {
    try {
      final url = majorId != null 
          ? '$academicBaseUrl/courses/read.php?major_id=$majorId'
          : '$academicBaseUrl/courses/read.php';
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((json) => CourseModel.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      print('Error getting courses: $e');
    }
    return [];
  }

  @override
  Future<bool> createCourse(CourseModel course) async {
    try {
      final response = await http.post(
        Uri.parse('$academicBaseUrl/courses/create.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'code': course.code,
          'name': course.name,
          'sks': course.sks,
          'semester': course.semester,
          'major_id': course.majorId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error creating course: $e');
    }
    return false;
  }

  @override
  Future<bool> updateCourse(CourseModel course) async {
    try {
      final response = await http.post(
        Uri.parse('$academicBaseUrl/courses/update.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': course.id,
          'code': course.code,
          'name': course.name,
          'sks': course.sks,
          'semester': course.semester,
          'major_id': course.majorId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error updating course: $e');
    }
    return false;
  }

  @override
  Future<bool> deleteCourse(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$academicBaseUrl/courses/delete.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error deleting course: $e');
    }
    return false;
  }

  // Classes Implementation
  @override
  Future<List<ClassSessionModel>> getClasses(String? majorId) async {
    try {
      final url = majorId != null 
          ? '$academicBaseUrl/classes/read.php?major_id=$majorId'
          : '$academicBaseUrl/classes/read.php';
      
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
      print('Error getting classes: $e');
    }
    return [];
  }

  @override
  Future<bool> createClass(ClassSessionModel classSession) async {
    try {
      final response = await http.post(
        Uri.parse('$academicBaseUrl/classes/create.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(classSession.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error creating class: $e');
    }
    return false;
  }

  @override
  Future<bool> updateClass(ClassSessionModel classSession) async {
    try {
      final response = await http.post(
        Uri.parse('$academicBaseUrl/classes/update.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(classSession.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error updating class: $e');
    }
    return false;
  }

  @override
  Future<bool> deleteClass(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$academicBaseUrl/classes/delete.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error deleting class: $e');
    }
    return false;
  }
}
