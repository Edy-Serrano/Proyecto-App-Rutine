import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rutine/services/hive_service.dart';
import 'package:rutine/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  bool _useCircadian = true;
  bool _notificationsEnabled = false;
  Timer? _circadianTimer;

  ThemeProvider() {
    _loadSettings();
    _startCircadianTimer();
  }

  @override
  void dispose() {
    _circadianTimer?.cancel();
    super.dispose();
  }

  void _startCircadianTimer() {
    // Revisa la hora cada 5 minutos por si hay que cambiar de fase
    _circadianTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_useCircadian) {
        final oldPhase = AppTheme.currentPhase;
        AppTheme.updateCircadianPhase();
        if (oldPhase != AppTheme.currentPhase) {
          _isDarkMode = AppTheme.isDarkMode;
          notifyListeners();
        }
      }
    });
  }

  void _loadSettings() {
    _isDarkMode = HiveService.getIsDarkMode();
    _useCircadian = HiveService.getUseCircadianTheme();
    _notificationsEnabled = HiveService.getNotificationsEnabled();
    
    AppTheme.useCircadian = _useCircadian;
    if (_useCircadian) {
      AppTheme.updateCircadianPhase();
      _isDarkMode = AppTheme.isDarkMode;
    } else {
      AppTheme.isDarkMode = _isDarkMode;
    }
    notifyListeners();
  }

  bool get isDarkMode => _isDarkMode;
  bool get useCircadian => _useCircadian;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> toggleTheme() async {
    if (_useCircadian) {
      // Si el usuario toca el botón de tema manualmente, desactiva el modo circadiano
      _useCircadian = false;
      AppTheme.useCircadian = false;
      await HiveService.setUseCircadianTheme(false);
    }
    _isDarkMode = !_isDarkMode;
    AppTheme.isDarkMode = _isDarkMode;
    await HiveService.setIsDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> toggleCircadian(bool value) async {
    _useCircadian = value;
    AppTheme.useCircadian = value;
    await HiveService.setUseCircadianTheme(value);
    
    if (value) {
      AppTheme.updateCircadianPhase();
      _isDarkMode = AppTheme.isDarkMode;
    }
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    await HiveService.setNotificationsEnabled(value);
    notifyListeners();
  }
}
