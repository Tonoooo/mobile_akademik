import '../models/user_model.dart';
import '../models/academic_models.dart';

abstract class AdminRepository {
  Future<Map<String, int>> getRoleCounts();
  Future<List<UserModel>> getUsersByRole(String role);
  Future<bool> createUser(UserModel user, String password);
  Future<bool> updateUser(UserModel user, String? password);
  Future<bool> deleteUser(String id);

  // Majors (Jurusan)
  Future<List<MajorModel>> getMajors();
  Future<bool> createMajor(MajorModel major);
  Future<bool> updateMajor(MajorModel major);
  Future<bool> deleteMajor(String id);

  // Courses (Mata Kuliah)
  Future<List<CourseModel>> getCourses(String? majorId);
  Future<bool> createCourse(CourseModel course);
  Future<bool> updateCourse(CourseModel course);
  Future<bool> deleteCourse(String id);

  // Classes (Kelas & Jadwal)
  Future<List<ClassSessionModel>> getClasses(String? majorId);
  Future<bool> createClass(ClassSessionModel classSession);
  Future<bool> updateClass(ClassSessionModel classSession);
  Future<bool> deleteClass(String id);
}
