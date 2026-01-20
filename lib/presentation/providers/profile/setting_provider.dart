import 'package:flutter/material.dart';
import 'dart:developer' show log;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repositories/auth_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  final AuthRepository _authRepository;

  SettingsProvider({
    required SharedPreferences prefs,
    required AuthRepository authRepository,
  })  : _prefs = prefs,
        _authRepository = authRepository {
    _loadSettings();
  }

  ThemeMode _themeMode = ThemeMode.system;
  String _language = 'en';
  bool _isLoggingOut = false;

  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguage = 'language';

  ThemeMode get themeMode => _themeMode;
  String get language => _language;
  bool get isLoggingOut => _isLoggingOut;

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;



  void _loadSettings() {
    log('📥 Loading settings');

    // Theme mode
    final themeModeStr = _prefs.getString(_keyThemeMode) ?? 'system';
    _themeMode = _parseThemeMode(themeModeStr);

    log('✅ Settings loaded - Theme: $_themeMode, Language: $_language');
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_keyThemeMode, _themeModeToString(mode));
    log('🎨 Theme mode set to: $mode');
    notifyListeners();
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  Future<bool> logout() async {
    _isLoggingOut = true;
    notifyListeners();

    try {
      log('🚪 Logging out...');
      await _authRepository.signOut();


      log('✅ Logout successful');
      _isLoggingOut = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      log('❌ Logout failed: $e');
      _isLoggingOut = false;
      notifyListeners();
      
      return false;
    }
  }

  Future<void> resetToDefaults() async {
    _themeMode = ThemeMode.system;
    _language = 'en';

    await _prefs.remove(_keyThemeMode);
    await _prefs.remove(_keyLanguage);

    log('🔄 Settings reset to defaults');
    notifyListeners();
  }
}