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
}
