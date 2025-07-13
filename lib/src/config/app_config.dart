import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  // Production API address (change to your server!)
  static const String _prodApiHost = '192.109.245.95'; // or VPS IP
  static const int _prodApiPort = 8080;

  // Local API address (for development)
  static const String _devApiHost = '127.0.0.1';
  static const int _devApiPort = 8080;

  // Helper method to get config from environment or use defaults
  static String _getConfig(String key, String defaultValue) {
    if (kIsWeb) {
      // On web always use default values
      // JS configuration will be added later
      return defaultValue;
    } else {
      // On desktop/mobile use Platform.environment
      try {
        return Platform.environment[key] ?? defaultValue;
      } catch (e) {
        return defaultValue;
      }
    }
  }

  static String get apiBaseUrl {
    if (kIsWeb) {
      // Na web użyj konfiguracji JS
      final host = _getConfig('API_HOST', _prodApiHost);
      final port = _getConfig('API_PORT', _prodApiPort.toString());
      return 'http://$host:$port';
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Na mobile zawsze produkcja (albo zmień na dev jeśli testujesz lokalnie)
      return 'http://$_prodApiHost:$_prodApiPort';
    } else {
      // Na desktopie możesz łatwo przełączać
      // (np. przez zmienną środowiskową, tu domyślnie prod)
      return 'http://$_prodApiHost:$_prodApiPort';
    }
  }

  // Get API Host from environment or use default
  static String get apiHost {
    return _getConfig('API_HOST', _prodApiHost);
  }

  // Get API Port from environment or use default
  static int get apiPort {
    final portStr = _getConfig('API_PORT', _prodApiPort.toString());
    return int.tryParse(portStr) ?? _prodApiPort;
  }

  // Get Environment from environment or use default
  static String get environment {
    return _getConfig('ENVIRONMENT', 'production');
  }

  // Check if running in development mode
  static bool get isDevelopment {
    return environment == 'development';
  }

  // Check if running in production mode
  static bool get isProduction {
    return environment == 'production';
  }

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
