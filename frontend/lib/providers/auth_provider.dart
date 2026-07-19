import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;

  AuthProvider(this._authService);

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;

  Future<void> checkLoginStatus() async {
    _setLoading(true);
    try {
      _isAuthenticated = await _authService.isLoggedIn();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    _setLoading(true);
    try {
      await _authService.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    try {
      _user = await _authService.login(username: username, password: password);
      _isAuthenticated = true;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
