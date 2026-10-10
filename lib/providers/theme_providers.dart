// lib/theme_provider.dart

import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  bool get isDarkMode => _mode == ThemeMode.dark;

  void toggle(bool isOn) {
    _mode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
