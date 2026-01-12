import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'auth_repository.dart';

class HttpAuthRepository implements AuthRepository {
  final String baseUrl = 'https://sitono.online/manajer_data/api';
  UserModel? _currentUser;

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
          _currentUser = UserModel(
            id: data['data']['id'].toString(),
            nimOrNip: data['data']['username'],
            name: data['data']['name'],
            role: data['data']['role'],
            // photoUrl: data['data']['photo_url'], // Removed as it's not in UserModel
            email: data['data']['username'], // Use username as email for now since backend uses username
          );
          return _currentUser;
        }
      }
    } catch (e) {
      print('Login error: $e');
    }
    return null;
  }

  @override
  Future<UserModel?> getUserProfile(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/read.php?id=$id'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && (data['data'] as List).isNotEmpty) {
          return UserModel.fromJson(data['data'][0]);
        }
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
    return null;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }
}
