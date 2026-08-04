import 'package:hive_flutter/hive_flutter.dart';
import 'package:rutine/models/task_model.dart';

class HiveService {
  static const String _tasksBoxName = 'tasksBox';
  static const String _prefsBoxName = 'prefsBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_tasksBoxName);
    await Hive.openBox(_prefsBoxName);
  }

  static Box get _box => Hive.box(_tasksBoxName);
  static Box get _prefsBox => Hive.box(_prefsBoxName);

  static List<Task> getTasks() {
    final List<Task> tasks = [];
    for (var i = 0; i < _box.length; i++) {
      final map = _box.getAt(i) as Map<dynamic, dynamic>?;
      if (map != null) {
        tasks.add(Task.fromMap(map));
      }
    }
    return tasks;
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    await _box.clear();
    await _box.addAll(tasks.map((t) => t.toMap()).toList());
  }

  static Future<void> addTask(Task task) async {
    await _box.add(task.toMap());
  }

  static Future<void> updateTask(Task task) async {
    final index = getTasks().indexWhere((t) => t.id == task.id);
    if (index != -1) {
      await _box.putAt(index, task.toMap());
    }
  }

  static Future<void> deleteTask(String taskId) async {
    final index = getTasks().indexWhere((t) => t.id == taskId);
    if (index != -1) {
      await _box.deleteAt(index);
    }
  }

  // ─── PREFERENCIAS ─────────────────────────────────────────────────────────

  static String getUserName() {
    return _prefsBox.get('userName', defaultValue: 'Usuario');
  }

  static Future<void> setUserName(String name) async {
    await _prefsBox.put('userName', name);
  }

  static String? getUserImagePath() {
    return _prefsBox.get('userImagePath');
  }

  static Future<void> setUserImagePath(String path) async {
    await _prefsBox.put('userImagePath', path);
  }

  static bool getIsDarkMode() {
    return _prefsBox.get('isDarkMode', defaultValue: true);
  }

  static Future<void> setIsDarkMode(bool isDark) async {
    await _prefsBox.put('isDarkMode', isDark);
  }

  static bool getNotificationsEnabled() {
    return _prefsBox.get('notificationsEnabled', defaultValue: false);
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefsBox.put('notificationsEnabled', enabled);
  }
}
