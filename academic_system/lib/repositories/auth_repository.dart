import '../models/user_model.dart';
import '../core/constants.dart';

abstract class AuthRepository {
  Future<UserModel?> login(String email, String password);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<UserModel?> getUserProfile(String id);
}

class MockAuthRepository implements AuthRepository {
  UserModel? _currentUser;

  // Mock Data Users
  final List<UserModel> _mockUsers = [
    UserModel(id: '1', email: 'super@admin.com', name: 'Super Admin', role: AppConstants.roleSuperAdmin),
    UserModel(id: '2', email: 'admin@kampus.com', name: 'Admin Akademik', role: AppConstants.roleAdmin),
    UserModel(id: '3', email: 'dosen@kampus.com', name: 'Budi Santoso, M.Kom', role: AppConstants.roleDosen, nimOrNip: '198001012005011001'),
    UserModel(id: '4', email: 'mhs@kampus.com', name: 'Ahmad Siswa', role: AppConstants.roleMahasiswa, nimOrNip: '2023001'),
    UserModel(id: '5', email: 'keuangan@kampus.com', name: 'Staff Keuangan', role: AppConstants.roleKeuangan),
  ];

  @override
  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    // Simple mock validation: password must be 'password'
    if (password != 'password') return null;

    try {
      final user = _mockUsers.firstWhere((u) => u.email == email);
      _currentUser = user;
      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<UserModel?> getUserProfile(String id) async {
    try {
      return _mockUsers.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }
}
