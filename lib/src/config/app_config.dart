import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Helper method to get config from dotenv or use empty string
  static String _getEnv(String key) {
    return dotenv.env[key] ?? '';
  }

  static String get apiBaseUrl {
    final host = _getEnv('API_HOST');
    final port = _getEnv('API_PORT');
    if (host.isEmpty || port.isEmpty) {
      throw Exception('API_HOST and API_PORT must be set in .env');
    }
    return 'http://$host:$port';
  }

  static String get apiHost => _getEnv('API_HOST');
  static int get apiPort => int.tryParse(_getEnv('API_PORT')) ?? 0;
  static String get environment => _getEnv('ENVIRONMENT');
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';

  // Get API endpoints
  static String get authRegisterEndpoint => '$apiBaseUrl/register';
  static String get authLoginEndpoint => '$apiBaseUrl/login';
  static String get authRefreshEndpoint => '$apiBaseUrl/refresh';
  static String get notebooksEndpoint => '$apiBaseUrl/protected/notebooks';
  static String get notesEndpoint => '$apiBaseUrl/protected/notes';

  // Log configuration
  static void logConfiguration() {
    print('=== App Configuration ===');
    print('Environment: $environment');
    print('API Base URL: $apiBaseUrl');
    print('API Host: $apiHost');
    print('API Port: $apiPort');
    print('Is Development: $isDevelopment');
    print('Is Production: $isProduction');
    print('========================');
  }
}
