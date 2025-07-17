import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';
import '../config/app_config.dart';
import 'logger_service.dart';

/// Service for API communication and token management
class ApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  void Function()? onForceLogout;

  Future<void> initialize() async {
    // Możesz tu dodać inicjalizację, np. sprawdzenie tokenu, refresh, itp.
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final token = await getToken();
    final allHeaders = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: allHeaders,
      body: body,
    );
  }

  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final token = await getToken();
    final allHeaders = <String, String>{
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
    return await http.get(Uri.parse('$baseUrl$endpoint'), headers: allHeaders);
  }

  /// Push local notes to API
  Future<bool> syncNotes(List<Note> notes) async {
    final response = await post(
      '/notes/sync',
      body: jsonEncode(
        notes
            .map(
              (n) => {
                'uuid': n.id,
                'title': n.title,
                'content': n.content,
                'updatedAt': n.updatedAt.toIso8601String(),
                'deleted': n.deleted,
              },
            )
            .toList(),
      ),
    );
    return response.statusCode == 200;
  }

  /// Pull notes changed since lastSync from API
  Future<List<Map<String, dynamic>>> getNotesChangedSince(
    DateTime lastSync,
  ) async {
    final response = await get(
      '/notes/changes?since=${lastSync.toIso8601String()}',
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Example login method
  Future<bool> login({required String email, required String password}) async {
    final logger = LoggerService();
    logger.info('Login attempt for email: $email');
    try {
      final response = await post(
        '/login',
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await setToken(data['access_token']);
        logger.info('Login successful for email: $email');
        logger.info(
          'JWT access_token: ${data['access_token']}',
        ); // Dodaj logowanie tokena
        return true;
      } else {
        logger.warning(
          'Login failed for email: $email, status: ${response.statusCode}, body: ${response.body}',
        );
      }
    } catch (e, st) {
      logger.error('Login error for email: $email', e, st);
    }
    return false;
  }

  /// Example register method
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    final logger = LoggerService();
    logger.info('Register attempt for email: $email');
    try {
      final response = await post(
        '/register',
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        logger.info('Register successful for email: $email');
        return true;
      } else {
        logger.warning(
          'Register failed for email: $email, status: ${response.statusCode}, body: ${response.body}',
        );
      }
    } catch (e, st) {
      logger.error('Register error for email: $email', e, st);
    }
    return false;
  }

  /// Example logout method
  Future<void> logout() async {
    await clearToken();
  }
}
