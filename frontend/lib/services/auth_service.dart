import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService(this._apiService);

  Future<User> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _apiService.post('/auth/register', data: {
      'username': username,
      'email': email,
      'password': password,
      'fullName': fullName,
    });

    final data = response.data;
    if (data is Map && data['user'] is Map) {
      return User.fromJson(Map<String, dynamic>.from(data['user'] as Map));
    }

    return User(id: 0, username: username, email: email, fullName: fullName);
  }

  Future<User> login({
    required String username,
    required String password,
  }) async {
    final response = await _apiService.post('/auth/login', data: {
      'username': username,
      'password': password,
    });

    final data = response.data;
    if (data is! Map) {
      throw 'Format response login tidak valid.';
    }

    final token = data['token']?.toString();
    if (token == null || token.isEmpty) {
      throw 'Token tidak ditemukan pada response login.';
    }

    await _storage.write(key: 'auth_token', value: token);

    final userData = data['user'];
    if (userData is Map) {
      return User.fromJson(Map<String, dynamic>.from(userData));
    }

    return User(id: 0, username: username, email: '', fullName: username);
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() async {
    return _storage.read(key: 'auth_token');
  }
}
