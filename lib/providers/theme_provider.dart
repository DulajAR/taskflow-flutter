import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'taskflow_dark_mode';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final preferences = await SharedPreferences.getInstance();
    final isDark = preferences.getBool(_themeKey) ?? false;

    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_themeKey, isDark);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_themeKey, mode == ThemeMode.dark);
  }
}
