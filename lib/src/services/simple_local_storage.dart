import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

/// Simple local storage service using SharedPreferences
/// Provides a simple interface for storing key-value pairs
class SimpleLocalStorage {
  final LoggerService _logger = LoggerService();

  /// Get boolean value
  Future<bool?> getBool(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key);
    } catch (e) {
      _logger.error('Failed to get bool for key $key: $e');
      return null;
    }
  }

  /// Set boolean value
  Future<bool> setBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(key, value);
    } catch (e) {
      _logger.error('Failed to set bool for key $key: $e');
      return false;
    }
  }

  /// Get string value
  Future<String?> getString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      _logger.error('Failed to get string for key $key: $e');
      return null;
    }
  }

  /// Set string value
  Future<bool> setString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(key, value);
    } catch (e) {
      _logger.error('Failed to set string for key $key: $e');
      return false;
    }
  }

  /// Get int value
  Future<int?> getInt(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(key);
    } catch (e) {
      _logger.error('Failed to get int for key $key: $e');
      return null;
    }
  }

  /// Set int value
  Future<bool> setInt(String key, int value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setInt(key, value);
    } catch (e) {
      _logger.error('Failed to set int for key $key: $e');
      return false;
    }
  }

  /// Get double value
  Future<double?> getDouble(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(key);
    } catch (e) {
      _logger.error('Failed to get double for key $key: $e');
      return null;
    }
  }

  /// Set double value
  Future<bool> setDouble(String key, double value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setDouble(key, value);
    } catch (e) {
      _logger.error('Failed to set double for key $key: $e');
      return false;
    }
  }

  /// Get string list
  Future<List<String>?> getStringList(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(key);
    } catch (e) {
      _logger.error('Failed to get string list for key $key: $e');
      return null;
    }
  }

  /// Set string list
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setStringList(key, value);
    } catch (e) {
      _logger.error('Failed to set string list for key $key: $e');
      return false;
    }
  }

  /// Remove key
  Future<bool> remove(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(key);
    } catch (e) {
      _logger.error('Failed to remove key $key: $e');
      return false;
    }
  }

  /// Clear all data
  Future<bool> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.clear();
    } catch (e) {
      _logger.error('Failed to clear all data: $e');
      return false;
    }
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(key);
    } catch (e) {
      _logger.error('Failed to check if key $key exists: $e');
      return false;
    }
  }

  /// Get all keys
  Future<Set<String>> getKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getKeys();
    } catch (e) {
      _logger.error('Failed to get all keys: $e');
      return {};
    }
  }
}
