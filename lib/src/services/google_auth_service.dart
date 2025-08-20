import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Notematic/src/config/app_config.dart';
import 'package:Notematic/src/providers/logger_provider.dart';

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
      // Use AppConfig as the single source of truth (from .env)
      final clientId = AppConfig.googleClientId;
      final serverClientId = AppConfig.googleServerClientId;
      logger.info('📋 Using clientId: $clientId');
      logger.info('📋 Using serverClientId: $serverClientId');

      if (clientId.isEmpty || serverClientId.isEmpty) {
        throw Exception('Missing clientId/serverClientId in AppConfig (.env)');
      }

      // For web, we need to pass client IDs explicitly
      if (AppConfig.isWebPlatform) {
        await _googleSignIn.initialize(
          clientId: clientId,
          // serverClientId is not supported on web
        );
        logger.info('✅ Google Sign-In initialized successfully for web');
      } else {
        // For Android, serverClientId is required
        if (serverClientId.isEmpty) {
          throw Exception('serverClientId is required for Android');
        }
        await _googleSignIn.initialize(
          clientId: clientId,
          serverClientId: serverClientId,
        );
        logger.info('✅ Google Sign-In initialized successfully');
      }
    } catch (e) {
      logger.error('💥 Google Sign-In initialization failed: $e');
    }
  }

  // All OAuth configuration is managed by AppConfig; no JSON asset loading here

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
