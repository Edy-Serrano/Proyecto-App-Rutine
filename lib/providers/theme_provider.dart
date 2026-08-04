import 'package:flutter/material.dart';
import 'package:rutine/services/hive_service.dart';
import 'package:rutine/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  bool _notificationsEnabled = false;

  ThemeProvider() {
    _loadSettings();
  }

  void _loadSettings() {
    _isDarkMode = HiveService.getIsDarkMode();
    _notificationsEnabled = HiveService.getNotificationsEnabled();
    AppTheme.isDarkMode = _isDarkMode;
    notifyListeners();
  }

  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    AppTheme.isDarkMode = _isDarkMode;
    await HiveService.setIsDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    await HiveService.setNotificationsEnabled(value);
    notifyListeners();
  }
}
