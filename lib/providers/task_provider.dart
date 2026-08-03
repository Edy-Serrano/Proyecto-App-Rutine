import 'package:flutter/material.dart';
import 'package:rutine/models/task_model.dart';

/// Proveedor central de estado de la aplicación (gestión simple sin librerías externas).
/// En futuras fases, este provider se conectará a la base de datos local.
class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  /// Tareas asignadas a un día específico
  List<Task> tasksForDate(DateTime date) {
    return _tasks.where((t) {
      final sameDay = t.date.year == date.year &&
          t.date.month == date.month &&
          t.date.day == date.day;
      final isRecurringToday = t.isRecurring && t.recurringDays.contains(date.weekday);
      return sameDay || isRecurringToday;
    }).toList()
      ..sort((a, b) {
        if (a.time == null && b.time == null) return 0;
        if (a.time == null) return 1;
        if (b.time == null) return -1;
        final aMin = a.time!.hour * 60 + a.time!.minute;
        final bMin = b.time!.hour * 60 + b.time!.minute;
        return aMin.compareTo(bMin);
      });
  }

  /// Porcentaje de completitud de un día específico (0.0 - 1.0)
  double completionRateForDate(DateTime date) {
    final dayTasks = tasksForDate(date);
    if (dayTasks.isEmpty) return 0.0;
    final completed = dayTasks.where((t) => t.isCompleted).length;
    return completed / dayTasks.length;
  }

  /// Porcentaje de completitud de la semana actual
  double weeklyCompletionRate() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    double total = 0;
    int days = 0;
    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      final rate = completionRateForDate(day);
      if (tasksForDate(day).isNotEmpty) {
        total += rate;
        days++;
      }
    }
    return days == 0 ? 0.0 : total / days;
  }

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void toggleTaskCompletion(String taskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  void updateTask(Task updated) {
    final index = _tasks.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _tasks[index] = updated;
      notifyListeners();
    }
  }

  /// Stats por categoría para la pantalla de estadísticas
  Map<TaskCategory, int> completedByCategory() {
    final map = <TaskCategory, int>{};
    for (final task in _tasks.where((t) => t.isCompleted)) {
      map[task.category] = (map[task.category] ?? 0) + 1;
    }
    return map;
  }
}
