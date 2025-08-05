import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/unified_note.dart';
import '../models/login_response.dart';
import '../config/app_config.dart';
import '../providers/logger_provider.dart';
import '../providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService(ref));

/// Service for API communication and token management
class ApiService {
  final Ref ref;
  ApiService(this.ref);

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
      final response = await post('/refresh');
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
    final logger = ref.read(loggerServiceProvider);

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

  Future<http.Response> put(
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

    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: allHeaders,
      body: bodyString,
    );
  }

  // ===== NEW API METHODS =====

  /// Get all notebooks from API
  Future<List<Map<String, dynamic>>> getNotebooks() async {
    try {
      final response = await get('/notebooks');
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

  /// Get single notebook from API
  Future<Map<String, dynamic>?> getNotebook(String uuid) async {
    try {
      final response = await get('/notebooks/$uuid');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Create notebook on API
  Future<Map<String, dynamic>?> createNotebook(
      Map<String, dynamic> notebookData) async {
    try {
      final response = await post('/notebooks', body: notebookData);
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update notebook on API
  Future<Map<String, dynamic>?> updateNotebook(
      String uuid, Map<String, dynamic> notebookData) async {
    try {
      final response = await put('/notebooks/$uuid', body: notebookData);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete notebook from API
  Future<bool> deleteNotebook(String uuid) async {
    try {
      final response = await delete('/notebooks/$uuid');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get all notes from API
  Future<List<Map<String, dynamic>>> getNotes() async {
    try {
      final response = await get('/notes');
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

  /// Get notes from specific notebook
  Future<List<Map<String, dynamic>>> getNotesFromNotebook(
      String notebookUuid) async {
    try {
      final response = await get('/notebooks/$notebookUuid/notes');
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

  /// Get single note from API
  Future<Map<String, dynamic>?> getNote(String uuid) async {
    try {
      final response = await get('/notes/$uuid');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Create note on API
  Future<Map<String, dynamic>?> createNote(
      Map<String, dynamic> noteData) async {
    try {
      final response = await post('/notes', body: noteData);
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Create note in specific notebook
  Future<Map<String, dynamic>?> createNoteInNotebook(
      String notebookUuid, Map<String, dynamic> noteData) async {
    try {
      final response =
          await post('/notebooks/$notebookUuid/notes', body: noteData);
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update note on API
  Future<Map<String, dynamic>?> updateNote(
      String uuid, Map<String, dynamic> noteData) async {
    try {
      final response = await put('/notes/$uuid', body: noteData);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete note from API
  Future<bool> deleteNote(String uuid) async {
    try {
      final response = await delete('/notes/$uuid');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Sync notes with API
  Future<Map<String, dynamic>?> syncNotes(
      List<Map<String, dynamic>> changes) async {
    try {
      final syncData = {
        'last_sync': null, // TODO: implement last sync tracking
        'device_id': 'flutter_app',
        'changes': changes,
      };

      final response = await post('/sync/notes', body: syncData);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Sync notebooks with API
  Future<Map<String, dynamic>?> syncNotebooks(
      List<Map<String, dynamic>> changes) async {
    try {
      final syncData = {
        'last_sync': null, // TODO: implement last sync tracking
        'device_id': 'flutter_app',
        'changes': changes,
      };

      final response = await post('/sync/notebooks', body: syncData);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get sync status
  Future<Map<String, dynamic>?> getSyncStatus() async {
    try {
      final response = await get('/sync/status');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ===== LEGACY METHODS (for backward compatibility) =====

  /// Legacy method - now uses new API
  Future<bool> syncNotesLegacy(List<UnifiedNote> notes) async {
    final changes = notes
        .map((note) => {
              'uuid': note.uuid,
              'title': note.title,
              'content': note.content,
              'notebookUuid': note.notebookUuid,
              'notebookName': note.notebookName,
              'updatedAt': note.updatedAt.toIso8601String(),
              'deleted': note.deleted,
            })
        .toList();

    final result = await syncNotes(changes);
    return result != null;
  }

  /// Legacy method - now uses new API
  Future<List<Map<String, dynamic>>> getNotesChangedSince(
      DateTime lastSync) async {
    // TODO: implement proper change tracking
    return await getNotes();
  }

  /// Example login method
  Future<LoginResponse?> login({required String email, required String password}) async {
    final logger = ref.read(loggerServiceProvider);
    logger.info('Login attempt for email: $email');
    try {
      final response = await post(
        '/login',
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(data);
        
        await setToken(loginResponse.accessToken);
        logger.info('Login successful for email: $email');
        
        // Log API version information
        if (loginResponse.isApiVersionCompatible) {
          logger.info('API version compatible: ${loginResponse.apiVersion}');
        } else {
          logger.warning('API version incompatible: ${loginResponse.apiVersion}');
        }
        
        return loginResponse;
      } else {
        logger.warning(
          'Login failed for email: $email, status: ${response.statusCode}, body: ${response.body}',
        );
      }
    } catch (e, st) {
      logger.error('Login error for email: $email', e, st);
    }
    return null;
  }

  /// Example register method
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    final logger = ref.read(loggerServiceProvider);
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

  /// Get API version information
  Future<Map<String, dynamic>?> getApiVersion() async {
    try {
      final response = await get('/version', enableLogging: false);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get API status information
  Future<Map<String, dynamic>?> getApiStatus() async {
    try {
      final response = await get('/status', enableLogging: false);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if API version is compatible
  Future<bool> isApiVersionCompatible() async {
    try {
      final versionInfo = await getApiVersion();
      if (versionInfo != null) {
        final apiVersion = versionInfo['version'] as String?;
        if (apiVersion != null) {
          // Simple version check - can be enhanced with semantic versioning
          return apiVersion == '1.0.0';
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if online mode is available (alias for isApiAvailable)
  Future<bool> isOnline() async {
    return await isApiAvailable();
  }

  Future<void> checkAndSetLoginStatus() async {
    final token = await getToken();
    bool isLoggedIn = false;
    if (token != null && token.isNotEmpty) {
      isLoggedIn = await _checkAndRefreshToken();
    }
    ref.read(isLoggedInProvider.notifier).state = isLoggedIn;
  }
}
