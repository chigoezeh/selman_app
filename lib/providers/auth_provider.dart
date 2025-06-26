import 'package:flutter/material.dart';
import 'package:selman/services/api_service.dart';

// The AuthProvider extends ChangeNotifier, which allows it to notify listeners of changes.
class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isAuthenticated = false;
  String? _token;
  // We can add a User model object here later
  // User? _user;

  // Public getters to access the state from the UI
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  // User? get user => _user;

  Future<void> login(String email, String password) async {
    try {
      final token = await _apiService.login(email, password);
      _token = token;
      _isAuthenticated = true;

      // TODO: Securely store the token on the device

      // Notify all listening widgets that the auth state has changed.
      notifyListeners();
    } catch (e) {
      // Re-throw the exception to be caught by the UI
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

  void logout() {
    _isAuthenticated = false;
    _token = null;
    // TODO: Clear the token from secure storage
    notifyListeners();
  }
}
