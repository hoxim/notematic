import 'api_service.dart';
import 'logger_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  final _logger = LoggerService();
  final _api = ApiService();

  /// Registers a new user using HTTP API. Returns true on success.
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    try {
      return await _api.register(email: email, password: password);
    } catch (e) {
      _logger.error('Registration error: $e');
      return false;
    }
  }

  /// Logs in a user using HTTP API. Returns true on success.
  Future<bool> login({required String email, required String password}) async {
    try {
      return await _api.login(email: email, password: password);
    } catch (e) {
      _logger.error('Login error: $e');
      return false;
    }
  }

  /// Refreshes the session token using HTTP API. Returns true on success.
  Future<bool> refreshToken() async {
    try {
      return await _api.refreshToken();
    } catch (e) {
      _logger.error('Token refresh error: $e');
      return false;
    }
  }

  /// Logs out the user (clears tokens from memory).
  Future<void> logout() async {
    _api.logout();
  }

  /// Checks if the user is logged in (access token is present).
  Future<bool> isLoggedIn() async {
    return _api.isLoggedIn();
  }

  /// Gets the user id from the current session (JWT sub).
  Future<String?> getUserId() async {
    return _api.getUserId();
  }

  // Google login temporarily disabled.
}
