import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';

  Locale _currentLocale = const Locale('tr');

  Locale get currentLocale => _currentLocale;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'tr';
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    if (_currentLocale.languageCode == languageCode) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);

    _currentLocale = Locale(languageCode);
    notifyListeners();
  }

  String getLocalizedText(Map<String, String> textMap) {
    return textMap[_currentLocale.languageCode] ?? textMap['tr'] ?? '';
  }
}
