import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notematic/src/services/auth_service.dart';
import 'package:notematic/src/services/logger_service.dart';

class TokenService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';

  // Save tokens
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    final logger = LoggerService();
    logger.info('Saving tokens for user: $userId');

    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      await _storage.write(key: _userIdKey, value: userId);
      logger.info('Tokens saved successfully');
    } catch (e) {
      logger.error('Failed to save tokens: $e');
      rethrow;
    }
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    final logger = LoggerService();
    try {
      final token = await _storage.read(key: _accessTokenKey);
      if (token != null) {
        logger.debug('Access token retrieved successfully');
      } else {
        logger.warning('No access token found');
      }
      return token;
    } catch (e) {
      logger.error('Failed to get access token: $e');
      return null;
    }
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // Get user ID
  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  // Clear all tokens
  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final logger = LoggerService();
    try {
      final accessToken = await getAccessToken();
      final isLoggedIn = accessToken != null;
      logger.debug('User login status: $isLoggedIn');
      return isLoggedIn;
    } catch (e) {
      logger.error('Failed to check login status: $e');
      // On web, flutter_secure_storage might not work properly
      // Return false to show login screen
      return false;
    }
  }

  // Get username from stored user ID
  static Future<String?> getUsernameFromToken() async {
    final logger = LoggerService();
    try {
      final userId = await getUserId();
      if (userId != null) {
        logger.debug('Username retrieved from stored user ID');
        return userId; // userId contains the actual username
      }
      return null;
    } catch (e) {
      logger.error('Failed to get username from stored user ID: $e');
      return null;
    }
  }
}

Future<T> withValidToken<T>(Future<T> Function(String token) action) async {
  final logger = LoggerService();
  String? token = await TokenService.getAccessToken();
  if (token == null) {
    logger.error('No access token');
    throw Exception('No access token');
  }
  try {
    return await action(token);
  } catch (e) {
    if (e.toString().contains('Invalid token')) {
      logger.warning('Access token invalid, attempting refresh');
      final refreshed = await AuthService().refreshToken();
      if (refreshed) {
        final newToken = await TokenService.getAccessToken();
        if (newToken != null) {
          logger.info('Token refreshed, retrying request');
          return await action(newToken);
        }
      }
      logger.error('Token refresh failed, logging out');
      await AuthService().logout();
      throw Exception('Session expired');
    }
    rethrow;
  }
}
