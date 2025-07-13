import 'package:notematic/src/rust/api/auth.dart';
import 'package:notematic/src/services/token_service.dart';
import 'package:notematic/src/services/logger_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  final _logger = LoggerService();

  // Register new user
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await registerUser(
        username: username,
        email: email,
        password: password,
      );

      // Save tokens
      await TokenService.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userId: response.accessToken, // We'll extract user ID from token later
      );

      return true;
    } catch (e) {
      _logger.error('Registration error: $e');
      return false;
    }
  }

  // Login user
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await loginUser(username: username, password: password);

      // Save tokens
      await TokenService.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userId: response.accessToken, // We'll extract user ID from token later
      );

      return true;
    } catch (e) {
      _logger.error('Login error: $e');
      return false;
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await TokenService.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      final response = await refreshUserToken(refreshToken: refreshToken);

      // Save new tokens
      await TokenService.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userId: response.accessToken, // We'll extract user ID from token later
      );

      return true;
    } catch (e) {
      _logger.error('Token refresh error: $e');
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    await TokenService.clearTokens();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await TokenService.isLoggedIn();
  }
}
