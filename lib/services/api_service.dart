import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:selman/models/content.dart';

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
}
