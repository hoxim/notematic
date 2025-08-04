import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/logger_service.dart';

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

  static String get apiHost {
    final host = _getEnv('API_HOST');
    if (host.isEmpty) {
      throw Exception('API_HOST must be set in .env');
    }
    return host;
  }

  static int get apiPort => int.tryParse(_getEnv('API_PORT')) ?? 8080;
  static String get environment =>
      _getEnv('ENVIRONMENT').isNotEmpty ? _getEnv('ENVIRONMENT') : 'production';
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get enableAutoLoginOnWeb =>
      _getEnv('ENABLE_AUTO_LOGIN_ON_WEB') == 'true';

  // Development tokens for auto-login in development mode
  static String get devAccessToken => _getEnv('DEV_ACCESS_TOKEN');
  static String get devRefreshToken => _getEnv('DEV_REFRESH_TOKEN');
  static bool get hasDevTokens =>
      devAccessToken.isNotEmpty && devRefreshToken.isNotEmpty;

  // Offline mode helpers
  static bool get isOfflineMode => _getEnv('OFFLINE_MODE') == 'true';
  static bool get isWebPlatform => kIsWeb;
  static bool get isDesktopPlatform =>
      !kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows);
  static bool get isMobilePlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  // Get API endpoints
  static String get authRegisterEndpoint => '$apiBaseUrl/register';
  static String get authLoginEndpoint => '$apiBaseUrl/login';
  static String get authRefreshEndpoint => '$apiBaseUrl/refresh';
  static String get notebooksEndpoint => '$apiBaseUrl/protected/notebooks';
  static String get notesEndpoint => '$apiBaseUrl/protected/notes';

  // Log configuration
  static void logConfiguration(LoggerService logger) {
    logger.info('=== App Configuration ===');
    logger.info('Environment: $environment');
    logger.info('API Base URL: $apiBaseUrl');
    logger.info('API Host: $apiHost');
    logger.info('API Port: $apiPort');
    logger.info('Is Development: $isDevelopment');
    logger.info('Is Production: $isProduction');
    logger.info('Enable Auto Login On Web: $enableAutoLoginOnWeb');
    logger.info('Has Dev Tokens: $hasDevTokens');
    logger.info('========================');
  }
}
