import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:async';

/// ApiService handles HTTP communication with the Rust backend API.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Initialize the service by loading tokens
  Future<void> initialize() async {
    print('INITIALIZE API SERVICE: starting...');

    // In development mode, use dev tokens if available
    if (AppConfig.isDevelopment && AppConfig.hasDevTokens) {
      print('INITIALIZE API SERVICE: using development tokens');
      _accessToken = AppConfig.devAccessToken;
      _refreshToken = AppConfig.devRefreshToken;
      print(
        'INITIALIZE API SERVICE: dev tokens loaded - accessToken=${_accessToken?.substring(0, 20) ?? 'null'}..., refreshToken=${_refreshToken?.substring(0, 20) ?? 'null'}...',
      );
      print('INITIALIZE API SERVICE: completed (dev mode)');
      return;
    }

    // Test sessionStorage availability in web
    if (kIsWeb) {
      try {
        html.window.sessionStorage['test_key'] = 'test_value';
        final testValue = html.window.sessionStorage['test_key'];
        html.window.sessionStorage.remove('test_key');
        print(
          'INITIALIZE API SERVICE: sessionStorage test - testValue=$testValue',
        );

        // Add debug function to window for console access
        js.context['debugTokens'] = js.allowInterop(() {
          print(
            'DEBUG TOKENS: sessionStorage keys: ${html.window.sessionStorage.keys.toList()}',
          );
          print(
            'DEBUG TOKENS: accessToken: ${html.window.sessionStorage['accessToken']?.substring(0, 20) ?? 'null'}...',
          );
          print(
            'DEBUG TOKENS: refreshToken: ${html.window.sessionStorage['refreshToken']?.substring(0, 20) ?? 'null'}...',
          );
        });
        print('INITIALIZE API SERVICE: debugTokens function added to window');
      } catch (e) {
        print('INITIALIZE API SERVICE: sessionStorage test failed - $e');
      }

      // Add delay for web to ensure storage is ready
      await Future.delayed(const Duration(milliseconds: 100));
    }

    await _loadTokens();
    print('INITIALIZE API SERVICE: completed');
  }

  String? _accessToken;
  String? _refreshToken;

  Future<void> _saveTokens() async {
    print(
      'SAVE TOKENS: starting... accessToken=${_accessToken?.substring(0, 20) ?? 'null'}..., refreshToken=${_refreshToken?.substring(0, 20) ?? 'null'}...',
    );

    if (_accessToken != null && _refreshToken != null) {
      // Try SharedPreferences first
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', _accessToken!);
        await prefs.setString('refreshToken', _refreshToken!);
        print(
          'SAVE TOKENS (SharedPreferences): accessToken=${_accessToken!.substring(0, 20)}..., refreshToken=${_refreshToken!.substring(0, 20)}...',
        );
      } catch (e) {
        print('SAVE TOKENS (SharedPreferences failed): $e');
      }

      // Also try sessionStorage for web (more persistent in development)
      try {
        if (kIsWeb) {
          // Use html.window.sessionStorage for web
          html.window.sessionStorage['accessToken'] = _accessToken!;
          html.window.sessionStorage['refreshToken'] = _refreshToken!;
          print(
            'SAVE TOKENS (sessionStorage): accessToken=${_accessToken!.substring(0, 20)}..., refreshToken=${_refreshToken!.substring(0, 20)}...',
          );

          // Verify the save by reading back
          final savedAccessToken = html.window.sessionStorage['accessToken'];
          final savedRefreshToken = html.window.sessionStorage['refreshToken'];
          print(
            'SAVE TOKENS (sessionStorage verification): savedAccessToken=${savedAccessToken?.substring(0, 20) ?? 'null'}..., savedRefreshToken=${savedRefreshToken?.substring(0, 20) ?? 'null'}...',
          );

          // Log all sessionStorage keys for debugging
          print(
            'SAVE TOKENS (sessionStorage all keys): ${html.window.sessionStorage.keys.toList()}',
          );
        }
      } catch (e) {
        print('SAVE TOKENS (sessionStorage failed): $e');
      }
    } else {
      print(
        'SAVE TOKENS: tokens are null - accessToken=$_accessToken, refreshToken=$_refreshToken',
      );
    }

    print('SAVE TOKENS: completed');
  }

  Future<void> _loadTokens() async {
    print('LOAD TOKENS: starting...');

    // Try SharedPreferences first
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('accessToken');
      _refreshToken = prefs.getString('refreshToken');
      print(
        'LOAD TOKENS (SharedPreferences): accessToken=${_accessToken?.substring(0, 20) ?? 'null'}..., refreshToken=${_refreshToken?.substring(0, 20) ?? 'null'}...',
      );
    } catch (e) {
      print('LOAD TOKENS (SharedPreferences failed): $e');
    }

    // If no tokens from SharedPreferences, try sessionStorage for web
    if (_accessToken == null && kIsWeb) {
      try {
        _accessToken = html.window.sessionStorage['accessToken'];
        _refreshToken = html.window.sessionStorage['refreshToken'];
        print(
          'LOAD TOKENS (sessionStorage): accessToken=${_accessToken?.substring(0, 20) ?? 'null'}..., refreshToken=${_refreshToken?.substring(0, 20) ?? 'null'}...',
        );

        // Log all sessionStorage keys for debugging
        print(
          'LOAD TOKENS (sessionStorage all keys): ${html.window.sessionStorage.keys.toList()}',
        );
      } catch (e) {
        print('LOAD TOKENS (sessionStorage failed): $e');
      }
    }

    print(
      'LOAD TOKENS: completed - accessToken=${_accessToken?.substring(0, 20) ?? 'null'}..., refreshToken=${_refreshToken?.substring(0, 20) ?? 'null'}...',
    );
  }

  Future<void> _clearTokens() async {
    // Clear SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      print('CLEAR TOKENS (SharedPreferences): tokens removed');
    } catch (e) {
      print('CLEAR TOKENS (SharedPreferences failed): $e');
    }

    // Clear sessionStorage for web
    try {
      if (kIsWeb) {
        html.window.sessionStorage.remove('accessToken');
        html.window.sessionStorage.remove('refreshToken');
        print('CLEAR TOKENS (sessionStorage): tokens removed');
      }
    } catch (e) {
      print('CLEAR TOKENS (sessionStorage failed): $e');
    }

    _accessToken = null;
    _refreshToken = null;
    print('CLEAR TOKENS: memory tokens cleared');
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

      print('DEV_ACCESS_TOKEN: $_accessToken');
      print('DEV_REFRESH_TOKEN: $_refreshToken');
      print('LOGIN SUCCESS: got tokens from API');
      await _saveTokens();
      print('LOGIN SUCCESS: tokens saved to storage');
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

  /// Returns true if the user is logged in (access token is present and valid).
  Future<bool> isLoggedIn() async {
    print(
      'IS LOGGED IN: checking... accessToken=${_accessToken?.substring(0, 20) ?? 'null'}...',
    );

    // In development mode with dev tokens, always return true
    if (AppConfig.isDevelopment &&
        AppConfig.hasDevTokens &&
        _accessToken != null) {
      print('IS LOGGED IN: true - using development tokens');
      return true;
    }

    // In development mode on web without dev tokens, skip auto-login
    if (kIsWeb && AppConfig.isDevelopment && !AppConfig.hasDevTokens) {
      print('IS LOGGED IN: skipping auto-login on web in development mode');
      return false;
    }

    if (_accessToken == null) {
      print('IS LOGGED IN: false - no access token');
      return false;
    }

    // Check if token is valid by making a test request
    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}/protected');
      print('IS LOGGED IN: testing token with URL $url');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      );
      print('IS LOGGED IN: response status ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('IS LOGGED IN: token validation failed: $e');
      return false;
    }
  }

  /// Logs out the user (clears tokens from memory and storage).
  Future<void> logout() async {
    print('LOGOUT: starting logout process');

    // In development mode with dev tokens, just clear memory tokens
    if (AppConfig.isDevelopment && AppConfig.hasDevTokens) {
      print('LOGOUT: clearing dev tokens from memory only');
      _accessToken = null;
      _refreshToken = null;
      print('LOGOUT: dev tokens cleared from memory');
      return;
    }

    await _clearTokens();
    print('LOGOUT: logout completed');
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
    final url = Uri.parse(
      '${AppConfig.apiBaseUrl}/protected/notebooks/$notebookId/notes',
    );
    print('GETTING NOTES URL: $url');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
    );
    print('GETTING NOTES STATUS: ${response.statusCode}');
    print('GETTING NOTES BODY: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('GETTING NOTES PARSED DATA: $data');

      // Handle different response structures
      if (data is List) {
        return data;
      } else if (data is Map) {
        // Check if it's {notes: [...]} structure
        if (data.containsKey('notes') && data['notes'] is List) {
          return data['notes'] as List;
        } else {
          return [data];
        }
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
    List<String>? tags,
  }) async {
    if (_accessToken == null) return false;
    final url = Uri.parse(
      '${AppConfig.apiBaseUrl}/protected/notebooks/$notebookId/notes',
    );
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
      body: jsonEncode({
        'title': title,
        'content': content,
        if (tags != null) 'tags': tags,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
