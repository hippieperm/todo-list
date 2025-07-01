import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  // 항상 다크 모드만 사용
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => ThemeMode.dark;

  bool get isDarkMode => true;

  ThemeViewModel();
}
