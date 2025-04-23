// theme_notifier.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeNotifier() {
    loadTheme();
  }

  void loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    notifyListeners();
  }

  void toggleTheme(bool isOn) async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = isOn;
    await prefs.setBool('darkMode', isOn);
    notifyListeners();
  }
}
