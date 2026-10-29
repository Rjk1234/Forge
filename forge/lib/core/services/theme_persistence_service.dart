import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting theme preferences across app launches
class ThemePersistenceService {
  static const String _themeKey = 'app_theme_mode';

  final SharedPreferences _preferences;

  ThemePersistenceService({required SharedPreferences preferences})
    : _preferences = preferences;

  /// Save theme mode to persistent storage
  Future<void> saveThemeMode(ThemeMode mode) async {
    await _preferences.setString(_themeKey, mode.toString());
  }

  /// Load theme mode from persistent storage (defaults to light)
  ThemeMode loadThemeMode() {
    final String? savedMode = _preferences.getString(_themeKey);
    if (savedMode == null) return ThemeMode.light;
    return _parseThemeMode(savedMode);
  }

  ThemeMode _parseThemeMode(String modeString) {
    try {
      return ThemeMode.values.firstWhere(
        (mode) => mode.toString() == modeString,
        orElse: () => ThemeMode.light,
      );
    } catch (_) {
      return ThemeMode.light;
    }
  }
}
