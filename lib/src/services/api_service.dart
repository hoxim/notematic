import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ApiService handles HTTP communication with the Rust backend API.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _loadTokens();
  }

  String? _accessToken;
  String? _refreshToken;

  Future<void> _saveTokens() async {
    final prefs = await SharedPreferences.getInstance();
    if (_accessToken != null && _refreshToken != null) {
      await prefs.setString('accessToken', _accessToken!);
      await prefs.setString('refreshToken', _refreshToken!);
    }
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    _refreshToken = prefs.getString('refreshToken');
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    _accessToken = null;
    _refreshToken = null;
  }

  /// Logs in a user and stores tokens on success.
  Future<bool> login({required String email, required String password}) async {
    final url = Uri.parse('${AppConfig.authLoginEndpoint}');
    final body = jsonEncode({'email': email, 'password': password});
    print('LOGIN URL: $url');
    print('LOGIN BODY: $body');
    print('LOGIN HEADERS: ${{'Content-Type': 'application/json'}}');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];
      _refreshToken = data['refresh_token'];
      await _saveTokens();
      return true;
    } else {
      print('LOGIN RESPONSE STATUS: ${response.statusCode}');
      print('LOGIN RESPONSE BODY: ${response.body}');
      return false;
    }
  }

  /// Registers a new user and stores tokens on success.
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${AppConfig.authRegisterEndpoint}');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];
      _refreshToken = data['refresh_token'];
      await _saveTokens();
      return true;
    } else {
      return false;
    }
  }

  /// Refreshes the access token using the stored refresh token.
  Future<bool> refreshToken() async {
    if (_refreshToken == null) return false;
    final url = Uri.parse('${AppConfig.authRefreshEndpoint}');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': _refreshToken}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];
      _refreshToken = data['refresh_token'];
      await _saveTokens();
      return true;
    } else {
      return false;
    }
  }

  /// Returns true if the user is logged in (access token is present).
  bool isLoggedIn() => _accessToken != null;

  /// Logs out the user (clears tokens from memory and storage).
  void logout() {
    _clearTokens();
  }

  /// Gets the user id from the current access token (if JWT, decodes payload).
  String? getUserId() {
    if (_accessToken == null) return null;
    try {
      final parts = _accessToken!.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final payloadMap = jsonDecode(payload);
      return payloadMap['sub']?.toString();
    } catch (_) {
      return null;
    }
  }

  /// Returns the current access token (for use in API calls).
  String? get accessToken => _accessToken;

  /// Gets all user notebooks (requires access token)
  Future<List<dynamic>> getUserNotebooks() async {
    if (_accessToken == null) return [];
    final url = Uri.parse(AppConfig.notebooksEndpoint);
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data;
      } else if (data is Map) {
        return [data];
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  /// Creates a new notebook (requires access token)
  Future<bool> createNotebook({
    required String name,
    String? description,
    String? color,
  }) async {
    if (_accessToken == null) return false;
    final url = Uri.parse(AppConfig.notebooksEndpoint);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
      body: jsonEncode({
        'name': name,
        if (description != null) 'description': description,
        if (color != null) 'color': color,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  /// Gets all notes for a notebook (requires access token)
  Future<List<dynamic>> getNotebookNotes(String notebookId) async {
    if (_accessToken == null) return [];
    final url = Uri.parse('${AppConfig.notesEndpoint}?notebook_id=$notebookId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data;
      } else if (data is Map) {
        return [data];
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  /// Creates a new note in a notebook (requires access token)
  Future<bool> createNote({
    required String notebookId,
    required String title,
    required String content,
  }) async {
    if (_accessToken == null) return false;
    final url = Uri.parse(AppConfig.notesEndpoint);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
      body: jsonEncode({
        'notebook_id': notebookId,
        'title': title,
        'content': content,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
