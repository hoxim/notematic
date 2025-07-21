import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/unified_note.dart';
import '../config/app_config.dart';
import 'logger_service.dart';

/// Service for API communication and token management
class ApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  void Function()? onForceLogout;

  Future<void> initialize() async {
    // Check token validity and refresh if needed
    await _checkAndRefreshToken();
  }

  /// Check if token is valid and refresh if needed
  Future<bool> _checkAndRefreshToken() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      // Decode JWT to check expiration
      final parts = token.split('.');
      if (parts.length != 3) {
        return false;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(resp);

      final exp = payloadMap['exp'];
      if (exp == null) {
        return false;
      }

      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      // If token expires in less than 10 minutes, try to refresh
      if (expiry.isBefore(now.add(const Duration(minutes: 10)))) {
        return await _refreshToken();
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Refresh the access token
  Future<bool> _refreshToken() async {
    try {
      final response = await post('/auth/refresh');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await setToken(data['access_token']);
        return true;
      }
    } catch (e) {
      // If refresh fails, clear token and force logout
      await clearToken();
      onForceLogout?.call();
    }
    return false;
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

    String? bodyString;
    if (body is String) {
      bodyString = body;
    } else if (body is Map) {
      bodyString = jsonEncode(body);
    }

    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: allHeaders,
      body: bodyString,
    );
  }

  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    bool enableLogging = true,
  }) async {
    final token = await getToken();
    final logger = LoggerService();

    if (enableLogging) {
      if (token == null) {
        logger.warning('No token available for API request to: $endpoint');
      } else {
        logger.info('Using token for API request to: $endpoint');
      }
    }

    final allHeaders = <String, String>{
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    final response =
        await http.get(Uri.parse('$baseUrl$endpoint'), headers: allHeaders);

    if (enableLogging) {
      logger.info('API response for $endpoint: ${response.statusCode}');
    }

    // Handle 401 Unauthorized
    if (response.statusCode == 401) {
      logger.warning('Unauthorized access to $endpoint, forcing logout');
      await clearToken();
      onForceLogout?.call();
    }

    return response;
  }

  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final token = await getToken();
    final allHeaders = <String, String>{
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
    return await http.delete(Uri.parse('$baseUrl$endpoint'),
        headers: allHeaders);
  }

  /// Push local notes to API
  Future<bool> syncNotes(List<UnifiedNote> notes) async {
    final response = await post(
      '/notes/sync',
      body: jsonEncode(
        notes
            .map(
              (n) => {
                'uuid': n.uuid,
                'title': n.title,
                'content': n.content,
                'notebookUuid': n.notebookUuid,
                'notebookName': n.notebookName,
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

  /// Check if API is available (for offline detection)
  Future<bool> isApiAvailable() async {
    try {
      final response = await get('/health', enableLogging: false);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Check if online mode is available (alias for isApiAvailable)
  Future<bool> isOnline() async {
    return await isApiAvailable();
  }

  /// Get all notes from API
  Future<List<Map<String, dynamic>>> getNotes() async {
    try {
      final response = await get('/protected/notes');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('notes')) {
          return (data['notes'] as List).cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get all notebooks from API
  Future<List<Map<String, dynamic>>> getNotebooks() async {
    try {
      final response = await get('/protected/notebooks');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('notebooks')) {
          return (data['notebooks'] as List).cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Create note on API
  Future<Map<String, dynamic>> createNote(Map<String, dynamic> noteData) async {
    try {
      final response = await post('/protected/notes', body: noteData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to create note: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Update note on API
  Future<Map<String, dynamic>> updateNote(
      String uuid, Map<String, dynamic> noteData) async {
    try {
      final response = await post('/protected/notes/$uuid', body: noteData);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to update note: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Create notebook on API
  Future<Map<String, dynamic>> createNotebook(
      Map<String, dynamic> notebookData) async {
    try {
      final response = await post('/protected/notebooks', body: notebookData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to create notebook: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Update notebook on API
  Future<Map<String, dynamic>> updateNotebook(
      String uuid, Map<String, dynamic> notebookData) async {
    try {
      final response =
          await post('/protected/notebooks/$uuid', body: notebookData);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to update notebook: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Delete note from API
  Future<void> deleteNote(String uuid) async {
    try {
      final response = await delete('/protected/notes/$uuid');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete note: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete notebook from API
  Future<void> deleteNotebook(String uuid) async {
    try {
      final response = await delete('/protected/notebooks/$uuid');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete notebook: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
