import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _darkModeKey = 'dark_mode';
  
  bool _isDarkMode = false;
  SharedPreferences? _prefs;
  bool _initialized = false;

  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs?.getBool(_darkModeKey) ?? false;
    _initialized = true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _prefs?.setBool(_darkModeKey, value);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    await setDarkMode(!_isDarkMode);
  }
}
