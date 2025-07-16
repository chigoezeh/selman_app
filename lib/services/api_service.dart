import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:selman/models/content.dart';
import 'package:selman/models/user.dart';
import 'package:selman/models/playlist.dart';

class ApiService {
  // We use 10.0.2.2 because it is a special alias for the host machine's
  // localhost when running in the Android Emulator.
  final String _baseUrl = "http://10.0.2.2:8000/api";

  // Method to fetch the list of content from the API
  Future<List<Content>> fetchContent() async {
    final response = await http.get(Uri.parse('$_baseUrl/content'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, then parse the JSON.
      List<dynamic> body = jsonDecode(response.body);

      // Map the list of JSON objects to a list of Content objects.
      List<Content> contentList = body
          .map(
            (dynamic item) => Content.fromJson(item),
          )
          .toList();

      return contentList;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load content from API');
    }
  }

  // Method to handle user login
  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      // and return the token.
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      // If the server did not return a 200 OK response,
      // parse the error message and throw an exception.
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to login.');
    }
  }

  // Method to handle user registration
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    if (response.statusCode != 201) {
      // If the server did not return a 201 Created response,
      // throw an exception with the error message.
      final errorData = jsonDecode(response.body);
      // We'll grab the first error from the 'errors' map if it exists.
      final errorMessage = errorData['errors']?.values?.first[0] ??
          errorData['message'] ??
          'Failed to register.';
      throw Exception(errorMessage);
    }
    // If registration is successful, we don't need to return anything.
  }

  // Method to get the current user's data using a token
  Future<User> fetchUser(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch user data.');
    }
  }

  // Method to log the user out
  Future<void> logout(String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/logout'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      // It's okay if it fails, we'll log the user out on the client-side anyway
      print('Failed to logout on server: ${response.body}');
    }
  }

  // Method to create a new playlist for the authenticated user
  Future<Playlist> createPlaylist({
    required String name,
    String? description,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/playlists'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String?>{
        'name': name,
        'description': description,
      }),
    );

    if (response.statusCode == 201) {
      // If the playlist is created successfully, parse and return it.
      return Playlist.fromJson(jsonDecode(response.body));
    } else {
      // If it fails, throw an error.
      throw Exception('Failed to create playlist.');
    }
  }

  // Method to fetch the playlists for the authenticated user
  Future<List<Playlist>> fetchPlaylists(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/playlists'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Playlist> playlists =
          body.map((dynamic item) => Playlist.fromJson(item)).toList();
      return playlists;
    } else {
      throw Exception('Failed to load playlists.');
    }
  }

  // Method to fetch a single playlist and its contents
  Future<Playlist> fetchPlaylistDetails(int playlistId, String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/playlists/$playlistId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // We need to update our Playlist model to handle the nested content
      return Playlist.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load playlist details.');
    }
  }

  // Method to add a piece of content to favorites
  Future<void> favoriteContent(int contentId, String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/content/$contentId/favorite'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add to favorites.');
    }
  }

  // Method to remove a piece of content from favorites
  Future<void> unfavoriteContent(int contentId, String token) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/content/$contentId/favorite'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove from favorites.');
    }
  }

  // Method to fetch the user's favorited content
  Future<List<Content>> fetchFavorites(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/favorites'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Content.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load favorites.');
    }
  }

  // Method to search for content
  Future<List<Content>> searchContent(String term) async {
    // We don't search if the term is too short
    if (term.length < 3) {
      return [];
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/search?term=$term'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Content.fromJson(item)).toList();
    } else {
      throw Exception('Failed to perform search.');
    }
  }

  // Method to sync playback progress
  Future<void> syncProgress({
    required int contentId,
    required int progressInSeconds,
    required String token,
  }) async {
    // No need to send if progress is 0
    if (progressInSeconds == 0) return;

    final response = await http.post(
      Uri.parse('$_baseUrl/content/$contentId/progress'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'progress_in_seconds': progressInSeconds,
      }),
    );

    if (response.statusCode != 200) {
      // We can just print the error, as failing to sync isn't a critical crash
      print('Failed to sync progress: ${response.body}');
    }
  }

  // Method to get saved progress for a piece of content
  Future<int?> fetchProgress(int contentId, String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/content/$contentId/progress'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['progress_in_seconds'];
    } else if (response.statusCode == 404) {
      // It's normal for no progress to be found, so we return null
      return null;
    } else {
      // For other errors, we throw an exception
      throw Exception('Failed to fetch progress.');
    }
  }
}
