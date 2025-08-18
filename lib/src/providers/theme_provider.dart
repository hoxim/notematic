import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'simple_local_storage_provider.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, AsyncValue<ThemeMode>>((ref) {
  return ThemeModeNotifier(ref);
});

class ThemeModeNotifier extends StateNotifier<AsyncValue<ThemeMode>> {
  final Ref _ref;
  ThemeModeNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final storage = _ref.read(simpleLocalStorageProvider);
      final value = await storage.getString('themeMode') ?? 'system';
      state = AsyncValue.data(_stringToTheme(value));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final storage = _ref.read(simpleLocalStorageProvider);
      await storage.setString('themeMode', _themeToString(mode));
      state = AsyncValue.data(mode);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  String _themeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode _stringToTheme(String v) {
    switch (v) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
