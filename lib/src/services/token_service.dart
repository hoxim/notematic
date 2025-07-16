import 'api_service.dart';

/// TokenService is a thin static wrapper for HTTP API session/token functions.
class TokenService {
  static final ApiService _api = ApiService();

  /// Returns true if the user is logged in (calls ApiService)
  static Future<bool> isLoggedIn() async => await _api.isLoggedIn();

  /// Logs out the user (clears tokens from memory)
  static Future<void> clearTokens() async => _api.logout();

  /// Gets the user id from the current session (JWT sub)
  static Future<String?> getUserId() async => _api.getUserId();
}
