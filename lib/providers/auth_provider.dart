import 'package:flutter/material.dart';
import 'package:selman/models/content.dart';
import 'package:selman/models/playlist.dart';
import 'package:selman/models/user.dart';
import 'package:selman/services/api_service.dart';
import 'package:selman/services/audio_handler.dart';

// The AuthProvider extends ChangeNotifier, which allows it to notify listeners of changes.
class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final MyAudioHandler audioHandler;

  AuthProvider(this.audioHandler);

  bool _isAuthenticated = false;
  String? _token;
  User? _user;
  List<Playlist> _playlists = [];
  List<Content> _favorites = [];

  // Public getters to access the state from the UI
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  User? get user => _user;
  List<Playlist> get playlists => _playlists;
  List<Content> get favorites => _favorites;

  Future<void> login(String email, String password) async {
    try {
      final token = await _apiService.login(email, password);
      _token = token;

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
        print('Error logging out from server: $e');
      }
    }

    _isAuthenticated = false;
    _token = null;
    _user = null;
    _playlists = []; // Clear playlists on logout
    _favorites = []; // Clear favorites on logout
    notifyListeners();
  }

  Future<void> fetchMyPlaylists() async {
    if (_token == null) return;
    try {
      _playlists = await _apiService.fetchPlaylists(_token!);
      notifyListeners();
    } catch (e) {
      print('Error fetching playlists: $e');
    }
  }

  Future<void> fetchMyFavorites() async {
    if (_token == null) return;
    try {
      _favorites = await _apiService.fetchFavorites(_token!);
      notifyListeners();
    } catch (e) {
      print('Error fetching favorites: $e');
    }
  }

  Future<void> createPlaylist({
    required String name,
    String? description,
  }) async {
    if (_token == null) {
      throw Exception('Not authenticated. Cannot create playlist.');
    }

    try {
      final newPlaylist = await _apiService.createPlaylist(
        name: name,
        description: description,
        token: _token!,
      );
      _playlists.add(newPlaylist);
      notifyListeners(); // Update UI
    } catch (e) {
      rethrow;
    }
  }

  Future<void> favoriteContent(int contentId) async {
    if (_token == null) return;
    try {
      await _apiService.favoriteContent(contentId, _token!);
      // For a better user experience, we can immediately update the local list
      // or simply refetch the list from the server. Let's refetch for simplicity.
      fetchMyFavorites();
    } catch (e) {
      print('Error favoriting content: $e');
      rethrow;
    }
  }

  Future<void> unfavoriteContent(int contentId) async {
    if (_token == null) return;
    try {
      await _apiService.unfavoriteContent(contentId, _token!);
      fetchMyFavorites();
    } catch (e) {
      print('Error unfavoriting content: $e');
      rethrow;
    }
  }
}
