import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notematic_app/src/config/app_config.dart';
import 'package:notematic_app/src/providers/logger_provider.dart';

final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService(ref);
});

/// Minimal Google Sign-In service
class GoogleAuthService {
  final Ref ref;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  GoogleAuthService(this.ref);

  /// Initialize Google Sign-In
  Future<void> initialize() async {
    final logger = ref.read(loggerServiceProvider);

    try {
      logger.info('🔧 Initializing Google Sign-In...');
      // Prefer IDs from oauth/*.json; fallback to AppConfig (.env)
      final ids = await _loadOauthIdsFromAssets();
      final clientId = ids.$1.isNotEmpty ? ids.$1 : AppConfig.googleClientId;
      final serverClientId =
          ids.$2.isNotEmpty ? ids.$2 : AppConfig.googleServerClientId;
      logger.info('📋 Using clientId: $clientId');
      logger.info('📋 Using serverClientId: $serverClientId');

      await _googleSignIn.initialize(
        clientId: clientId,
        serverClientId: serverClientId,
      );
      logger.info('✅ Google Sign-In initialized successfully');
    } catch (e) {
      logger.error('💥 Google Sign-In initialization failed: $e');
    }
  }

  // Load OAuth client IDs from asset JSON (oauth/*.json)
  // Returns (clientId, serverClientId)
  Future<(String, String)> _loadOauthIdsFromAssets() async {
    try {
      final path = _selectOauthAssetPath();
      if (path == null) return ('', '');
      final raw = await rootBundle.loadString(path);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      if (json.containsKey('installed')) {
        final m = json['installed'] as Map<String, dynamic>;
        final clientId = (m['client_id'] as String?) ?? '';
        var serverClientId = (m['server_client_id'] as String?) ?? '';
        // Android often needs web client ID as serverClientId; try to load it if missing
        if (serverClientId.isEmpty && AppConfig.isMobilePlatform) {
          final webIds = await _loadWebOauthIdsFromAssets();
          if (webIds != null) {
            serverClientId = webIds;
          }
        }
        return (clientId, serverClientId);
      }
      if (json.containsKey('web')) {
        final m = json['web'] as Map<String, dynamic>;
        final clientId = (m['client_id'] as String?) ?? '';
        final serverClientId = (m['server_client_id'] as String?) ?? '';
        return (clientId, serverClientId);
      }
      return ('', '');
    } catch (_) {
      return ('', '');
    }
  }

  // Load web client_id from web JSON; used as serverClientId fallback on Android
  Future<String?> _loadWebOauthIdsFromAssets() async {
    try {
      const webPath =
          'oauth/client_secret_892029182992-ionifa21f0g894gaaog7ju4goluqqaoj.apps.googleusercontent.com.json';
      final raw = await rootBundle.loadString(webPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      if (json.containsKey('web')) {
        final m = json['web'] as Map<String, dynamic>;
        return (m['client_id'] as String?) ?? '';
      }
    } catch (_) {}
    return null;
  }

  String? _selectOauthAssetPath() {
    try {
      if (AppConfig.isWebPlatform) {
        return 'oauth/client_secret_892029182992-ionifa21f0g894gaaog7ju4goluqqaoj.apps.googleusercontent.com.json';
      }
      if (AppConfig.isDesktopPlatform) {
        return 'oauth/client_secret_892029182992-ub0gt2bn049khef3c852ppmjo8tfq7ee.apps.googleusercontent.com.json';
      }
      if (AppConfig.isMobilePlatform) {
        // Use debug/release selection via AppConfig.isDevelopment
        return AppConfig.isDevelopment
            ? 'oauth/client_secret_892029182992-b6p84bl6l3bjrjkehup2nikq68e4je25.apps.googleusercontent.com.json'
            : 'oauth/client_secret_892029182992-felsgkrftdua596qsrs4j9rqo47pmg0r.apps.googleusercontent.com.json';
      }
    } catch (_) {}
    return null;
  }

  /// Authenticate and return Google account
  Future<GoogleSignInAccount?> authenticateAndGetAccount() async {
    final logger = ref.read(loggerServiceProvider);

    try {
      logger.info('🔐 Authenticating with Google...');
      final account = await _googleSignIn.authenticate();
      logger.info('✅ Authenticated: ${account.email}');
      return account;
    } catch (e) {
      logger.error('💥 Google authentication failed: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignore sign out errors
    }
  }
}
