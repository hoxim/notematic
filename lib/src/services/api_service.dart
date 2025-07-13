import 'dart:convert';
import 'package:http/http.dart' as http;
import 'logger_service.dart';
import '../config/app_config.dart';

class ApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Register user
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final logger = LoggerService();
    logger.info('Attempting to register user: $username');

    final url = '$baseUrl/register';
    final body = jsonEncode({
      'username': username,
      'email': email,
      'password': password,
    });

    logger.debug('Register request: URL=$url, Body=$body');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      logger.info(
        'Register response: Status=${response.statusCode}, Body=${response.body}',
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        logger.info('User registered successfully: $username');
        return result;
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['error'] ?? 'Registration failed';
        logger.error('Registration failed: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      logger.error('Exception during registration: $e');
      rethrow;
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final logger = LoggerService();
    logger.info('Attempting to login user: $username');

    final url = '$baseUrl/login';
    final body = jsonEncode({'username': username, 'password': password});

    logger.debug('Login request: URL=$url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      logger.info('Login response: Status=${response.statusCode}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        logger.info('User logged in successfully: $username');
        return result;
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['error'] ?? 'Login failed';
        logger.error('Login failed: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      logger.error('Exception during login: $e');
      rethrow;
    }
  }

  // Refresh token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Token refresh failed');
    }
  }

  // Create notebook
  Future<Map<String, dynamic>> createNotebook({
    required String accessToken,
    required String name,
    String? description,
    String? color,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/protected/notebooks'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'color': color,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to create notebook');
    }
  }

  // Get user notebooks
  Future<List<Map<String, dynamic>>> getUserNotebooks(
    String accessToken,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/protected/notebooks'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> notebooks = data['notebooks'] ?? [];
      return notebooks.cast<Map<String, dynamic>>();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to get notebooks');
    }
  }

  // Create note
  Future<Map<String, dynamic>> createNote({
    required String accessToken,
    required String notebookId,
    required String title,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/protected/notebooks/$notebookId/notes'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'title': title,
        'content': content,
        // Add 'tags' and 'is_pinned' if needed in the future
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        // Return empty map if response is empty
        return {};
      }
    } else {
      if (response.body.isNotEmpty) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to create note');
      } else {
        throw Exception('Failed to create note');
      }
    }
  }

  // Get notebook notes
  Future<List<Map<String, dynamic>>> getNotebookNotes(
    String notebookId,
    String accessToken,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/protected/notebooks/$notebookId/notes'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> notes = data['notes'] ?? [];
      return notes.cast<Map<String, dynamic>>();
    } else {
      if (response.body.isNotEmpty) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to get notes');
      } else {
        throw Exception('Failed to get notes');
      }
    }
  }
}
