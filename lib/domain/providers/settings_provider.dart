import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:platia/data/models/app_settings.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _notificationsKey = 'notifications';

  late SharedPreferences _prefs;
  AppSettings? _settings;
  ThemeMode _themeMode = ThemeMode.light;

  AppSettings? get settings => _settings;
  ThemeMode get themeMode => _themeMode;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();

    // Load theme mode
    final themeModeString = _prefs.getString(_themeKey) ?? 'light';
    _themeMode = themeModeString == 'dark' ? ThemeMode.dark : ThemeMode.light;

    // Load other settings
    _settings = AppSettings(
      id: 'local',
      language: _prefs.getString(_languageKey) ?? 'tr',
      theme: themeModeString,
      pushNotifications: _prefs.getBool(_notificationsKey) ?? true,
      updatedAt: DateTime.now(),
    );

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(
      _themeKey,
      mode == ThemeMode.dark ? 'dark' : 'light',
    );

    if (_settings != null) {
      _settings = _settings!.copyWith(
        theme: mode == ThemeMode.dark ? 'dark' : 'light',
      );
    }

    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    await _prefs.setString(_languageKey, language);

    if (_settings != null) {
      _settings = _settings!.copyWith(language: language);
    }

    notifyListeners();
  }

  Future<void> setNotifications(bool enabled) async {
    await _prefs.setBool(_notificationsKey, enabled);

    if (_settings != null) {
      _settings = _settings!.copyWith(pushNotifications: enabled);
    }

    notifyListeners();
  }

  Future<void> updateSettings(AppSettings settings) async {
    _settings = settings;

    await _prefs.setString(_languageKey, settings.language);
    await _prefs.setString(_themeKey, settings.theme);
    await _prefs.setBool(_notificationsKey, settings.pushNotifications);

    _themeMode = settings.theme == 'dark' ? ThemeMode.dark : ThemeMode.light;

    notifyListeners();
  }
}
