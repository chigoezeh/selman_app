import 'package:flutter/material.dart';
import 'package:selman/models/user.dart';
import 'package:selman/services/api_service.dart';

// The AuthProvider extends ChangeNotifier, which allows it to notify listeners of changes.
class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isAuthenticated = false;
  String? _token;
  User? _user;

  // Public getters to access the state from the UI
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  User? get user => _user;

  Future<void> login(String email, String password) async {
    try {
      final token = await _apiService.login(email, password);
      _token = token;

      // After getting the token, fetch the user's data
      final user = await _apiService.fetchUser(_token!);
      _user = user;

      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _apiService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      // After successful registration, we can automatically log the user in.
      await login(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    if (_token != null) {
      try {
        await _apiService.logout(_token!);
      } catch (e) {
        // Handle potential errors if the server can't be reached
        print('Error logging out from server: $e');
      }
    }

    _isAuthenticated = false;
    _token = null;
    _user = null;
    notifyListeners();
  }
}
