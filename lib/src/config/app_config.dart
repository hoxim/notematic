import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
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

  // Google OAuth Configuration - Android Debug/Release
  static String get googleClientIdAndroidDebug =>
      _getEnv('GOOGLE_CLIENT_ID_ANDROID_DEBUG');
  static String get googleServerClientIdAndroidDebug =>
      _getEnv('GOOGLE_SERVER_CLIENT_ID_ANDROID_DEBUG');

  static String get googleClientIdAndroidRelease =>
      _getEnv('GOOGLE_CLIENT_ID_ANDROID_RELEASE');
  static String get googleServerClientIdAndroidRelease =>
      _getEnv('GOOGLE_SERVER_CLIENT_ID_ANDROID_RELEASE');

  // Legacy Android OAuth Configuration (for backward compatibility)
  static String get googleClientIdAndroid =>
      _getEnv('GOOGLE_CLIENT_ID_ANDROID');
  static String get googleServerClientIdAndroid =>
      _getEnv('GOOGLE_SERVER_CLIENT_ID_ANDROID');

  static String get googleClientIdIos => _getEnv('GOOGLE_CLIENT_ID_IOS');
  static String get googleServerClientIdIos =>
      _getEnv('GOOGLE_SERVER_CLIENT_ID_IOS');

  static String get googleClientIdDesktop =>
      _getEnv('GOOGLE_CLIENT_ID_DESKTOP');
  static String get googleServerClientIdDesktop =>
      _getEnv('GOOGLE_SERVER_CLIENT_ID_DESKTOP');

  static String get googleClientIdWeb => _getEnv('GOOGLE_CLIENT_ID_WEB');
  static String get googleServerClientIdWeb =>
      _getEnv('GOOGLE_SERVER_CLIENT_ID_WEB');

  static String get googleProjectId => _getEnv('GOOGLE_PROJECT_ID');

  // Platform-specific Google OAuth getters
  static String get googleClientId {
    // Prefer JSON assets if present; fallback to .env
    final ids = _loadGoogleIdsFromAssetsSync();
    if (ids.$1.isNotEmpty) return ids.$1;
    // Fallback to existing env logic
    if (isWebPlatform) return googleClientIdWeb;
    if (isDesktopPlatform) return googleClientIdDesktop;
    if (isMobilePlatform) return googleClientIdAndroid;
    return '';
  }

  static String get googleServerClientId {
    final ids = _loadGoogleIdsFromAssetsSync();
    if (ids.$2.isNotEmpty) return ids.$2;
    if (isWebPlatform) return googleServerClientIdWeb;
    if (isDesktopPlatform) return googleServerClientIdDesktop;
    if (isMobilePlatform) return googleServerClientIdAndroid;
    return '';
  }

  static bool get hasGoogleOAuthConfig {
    if (isWebPlatform) {
      return googleClientIdWeb.isNotEmpty && googleServerClientIdWeb.isNotEmpty;
    }
    if (isDesktopPlatform) {
      return googleClientIdDesktop.isNotEmpty &&
          googleServerClientIdDesktop.isNotEmpty;
    }
    if (isMobilePlatform) {
      if (Platform.isAndroid) {
        if (kDebugMode) {
          return (googleClientIdAndroidDebug.isNotEmpty &&
                  googleServerClientIdAndroidDebug.isNotEmpty) ||
              (googleClientIdAndroid.isNotEmpty &&
                  googleServerClientIdAndroid.isNotEmpty); // fallback to legacy
        } else {
          return (googleClientIdAndroidRelease.isNotEmpty &&
                  googleServerClientIdAndroidRelease.isNotEmpty) ||
              (googleClientIdAndroid.isNotEmpty &&
                  googleServerClientIdAndroid.isNotEmpty); // fallback to legacy
        }
      }
      // For iOS, use legacy check
      return googleClientIdAndroid.isNotEmpty &&
          googleServerClientIdAndroid.isNotEmpty;
    }
    return false;
  }

  // Offline mode helpers
  static bool get isOfflineMode => _getEnv('OFFLINE_MODE') == 'true';
  static bool get isWebPlatform => kIsWeb;
  static bool get isDesktopPlatform {
    if (kIsWeb) return false;
    try {
      return Platform.isLinux || Platform.isMacOS || Platform.isWindows;
    } catch (e) {
      return false;
    }
  }

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
    logger.info(
        'Platform: ${isWebPlatform ? "Web" : isDesktopPlatform ? "Desktop" : isMobilePlatform ? "Mobile" : "Unknown"}');
    logger.info('Debug Mode: $kDebugMode');
    logger.info('Has Google OAuth Config: $hasGoogleOAuthConfig');
    if (hasGoogleOAuthConfig) {
      logger.info('Google Client ID: $googleClientId');
      logger.info('Google Server Client ID: $googleServerClientId');
      if (isMobilePlatform && !kIsWeb) {
        try {
          if (Platform.isAndroid) {
            if (kDebugMode) {
              logger.info('Using Android Debug OAuth Client');
            } else {
              logger.info('Using Android Release OAuth Client');
            }
          }
        } catch (e) {
          logger.info('Platform detection not available on this platform');
        }
      }
    }
    logger.info('========================');
  }

  // Load Google OAuth client IDs from bundled JSON assets (oauth/*.json)
  // Returns (clientId, serverClientId); serverClientId may be empty if not present in file
  static (String, String) _loadGoogleIdsFromAssetsSync() {
    try {
      final path = _selectOauthAssetPath();
      if (path == null) return ('', '');
      // Note: synchronous rootBundle load is not available; this method will be used only for reading values lazily at runtime
      // We provide a lazy cache via environment; if needed, switch to async initialization path.
      return ('', '');
    } catch (_) {
      return ('', '');
    }
  }

  // Decide which JSON file to use based on platform and mode
  static String? _selectOauthAssetPath() {
    if (isWebPlatform) {
      return 'oauth/client_secret_892029182992-ionifa21f0g894gaaog7ju4goluqqaoj.apps.googleusercontent.com.json';
    }
    if (isDesktopPlatform) {
      return 'oauth/client_secret_892029182992-ub0gt2bn049khef3c852ppmjo8tfq7ee.apps.googleusercontent.com.json';
    }
    if (isMobilePlatform && Platform.isAndroid) {
      return kDebugMode
          ? 'oauth/client_secret_892029182992-b6p84bl6l3bjrjkehup2nikq68e4je25.apps.googleusercontent.com.json'
          : 'oauth/client_secret_892029182992-felsgkrftdua596qsrs4j9rqo47pmg0r.apps.googleusercontent.com.json';
    }
    return null;
  }
}
