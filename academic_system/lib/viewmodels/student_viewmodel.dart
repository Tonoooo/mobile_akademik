import 'package:flutter/foundation.dart';
import '../models/academic_models.dart';
import '../repositories/academic_repository.dart';

class StudentViewModel with ChangeNotifier {
  final AcademicRepository _repository;
  
  List<ClassSessionModel> _availableClasses = [];
  List<EnrollmentModel> _myEnrollments = [];
  bool _isLoading = false;
  String? _errorMessage;

  StudentViewModel({required AcademicRepository repository}) : _repository = repository;

  List<ClassSessionModel> get availableClasses => _availableClasses;
  List<EnrollmentModel> get myEnrollments => _myEnrollments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get total SKS taken
  int get totalSks {
    int total = 0;
    for (var enrollment in _myEnrollments) {
      if (enrollment.classSession?.course != null) {
        total += enrollment.classSession!.course!.sks;
      }
    }
    return total;
  }

  Future<void> loadData(String studentId, {String? majorId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load both available classes and my enrollments
      final results = await Future.wait([
        _repository.getAvailableClasses(majorId: majorId),
        _repository.getStudentEnrollments(studentId),
      ]);

      _availableClasses = results[0] as List<ClassSessionModel>;
      _myEnrollments = results[1] as List<EnrollmentModel>;
    } catch (e) {
      _errorMessage = 'Gagal memuat data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> enrollClass(String studentId, String classId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.enrollClass(studentId, classId);
      // Refresh data
      await loadData(studentId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> dropClass(String studentId, String classId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.dropClass(studentId, classId);
      // Refresh data
      await loadData(studentId);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal membatalkan kelas: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Materials & Submissions Logic
  List<MaterialModel> _currentClassMaterials = [];
  List<MaterialModel> get currentClassMaterials => _currentClassMaterials;

  Future<void> loadClassMaterials(String classId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentClassMaterials = await _repository.getClassMaterials(classId);
    } catch (e) {
      _errorMessage = 'Gagal memuat materi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<SubmissionModel?> getSubmission(String materialId, String studentId) async {
    return await _repository.getStudentSubmission(materialId, studentId);
  }

  Future<bool> uploadAssignment(String materialId, String studentId, String fileName) async {
    _isLoading = true;
    notifyListeners();
    try {
      final submission = SubmissionModel(
        id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
        materialId: materialId,
        studentId: studentId,
        fileUrl: fileName, // Mock: just storing the name
        submittedAt: DateTime.now(),
      );
      await _repository.uploadSubmission(submission);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal upload tugas: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
