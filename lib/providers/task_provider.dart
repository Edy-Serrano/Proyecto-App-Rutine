import 'package:flutter/material.dart';
import 'package:rutine/models/task_model.dart';
import 'package:rutine/services/hive_service.dart';

/// Proveedor central de estado con persistencia local mediante Hive.
class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  String _userName = 'Usuario';

  TaskProvider() {
    _loadTasks();
  }

  void _loadTasks() {
    _tasks = HiveService.getTasks();
    _userName = HiveService.getUserName();
    notifyListeners();
  }

  List<Task> get tasks => List.unmodifiable(_tasks);
  String get userName => _userName;

  // ─── CONSULTAS ──────────────────────────────────────────────────────────────

  /// Tareas asignadas a un día específico (incluye recurrentes)
  List<Task> tasksForDate(DateTime date) {
    return _tasks.where((t) {
      final sameDay = _isSameDay(t.date, date);
      final isRecurringToday =
          t.isRecurring && t.recurringDays.contains(date.weekday);
      return sameDay || isRecurringToday;
    }).toList()
      ..sort((a, b) {
        if (a.time == null && b.time == null) return 0;
        if (a.time == null) return 1;
        if (b.time == null) return -1;
        return (a.time!.hour * 60 + a.time!.minute)
            .compareTo(b.time!.hour * 60 + b.time!.minute);
      });
  }

  /// % de completitud de un día (0.0 - 1.0)
  double completionRateForDate(DateTime date) {
    final dayTasks = tasksForDate(date);
    if (dayTasks.isEmpty) return 0.0;
    return dayTasks.where((t) => t.isCompleted).length / dayTasks.length;
  }

  /// % de completitud de la semana actual (promedio de días con tareas)
  double weeklyCompletionRate() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    double total = 0;
    int days = 0;
    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      if (tasksForDate(day).isNotEmpty) {
        total += completionRateForDate(day);
        days++;
      }
    }
    return days == 0 ? 0.0 : total / days;
  }

  /// % de completitud del mes actual
  double monthlyCompletionRate() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    double total = 0;
    int days = 0;
    for (int i = 1; i <= daysInMonth; i++) {
      final day = DateTime(now.year, now.month, i);
      if (day.isAfter(now)) break;
      if (tasksForDate(day).isNotEmpty) {
        total += completionRateForDate(day);
        days++;
      }
    }
    return days == 0 ? 0.0 : total / days;
  }

  /// Racha actual de días consecutivos con 100% de completitud
  int get currentStreak {
    int streak = 0;
    DateTime day = DateTime.now();
    // Si hoy no está 100% completo, empieza desde ayer
    if (completionRateForDate(day) < 1.0 && tasksForDate(day).isNotEmpty) {
      day = day.subtract(const Duration(days: 1));
    }
    while (true) {
      final dayTasks = tasksForDate(day);
      if (dayTasks.isEmpty || completionRateForDate(day) < 1.0) break;
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Mejor racha histórica
  int get bestStreak {
    if (_tasks.isEmpty) return 0;
    final dates = _tasks.map((t) => t.date).toList();
    dates.sort();
    final earliest = dates.first;
    final now = DateTime.now();
    int best = 0;
    int current = 0;
    DateTime day = earliest;
    while (!day.isAfter(now)) {
      final dayTasks = tasksForDate(day);
      if (dayTasks.isNotEmpty && completionRateForDate(day) == 1.0) {
        current++;
        if (current > best) best = current;
      } else {
        current = 0;
      }
      day = day.add(const Duration(days: 1));
    }
    return best;
  }

  /// Completadas por categoría (para el pie chart)
  Map<TaskCategory, int> completedByCategory() {
    final map = <TaskCategory, int>{};
    for (final task in _tasks.where((t) => t.isCompleted)) {
      map[task.category] = (map[task.category] ?? 0) + 1;
    }
    return map;
  }

  /// Total de tareas por categoría (para la barra de progreso por categoría)
  Map<TaskCategory, int> totalByCategory() {
    final map = <TaskCategory, int>{};
    for (final task in _tasks) {
      map[task.category] = (map[task.category] ?? 0) + 1;
    }
    return map;
  }

  /// Datos de completitud por día para los últimos 7 días (para el bar chart)
  List<DailyStats> getLast7DaysStats() {
    final result = <DailyStats>[];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      result.add(DailyStats(
        date: day,
        completionRate: completionRateForDate(day),
        totalTasks: tasksForDate(day).length,
        completedTasks: tasksForDate(day).where((t) => t.isCompleted).length,
      ));
    }
    return result;
  }

  // ─── MUTACIONES ─────────────────────────────────────────────────────────────

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await HiveService.addTask(task);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
      await HiveService.updateTask(_tasks[index]);
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    await HiveService.deleteTask(taskId);
    notifyListeners();
  }

  Future<void> updateTask(Task updated) async {
    final index = _tasks.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _tasks[index] = updated;
      await HiveService.updateTask(updated);
      notifyListeners();
    }
  }

  Future<void> updateUserName(String newName) async {
    _userName = newName;
    await HiveService.setUserName(newName);
    notifyListeners();
  }

  // ─── HELPERS ────────────────────────────────────────────────────────────────

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Modelo de datos para las estadísticas diarias (usado en los gráficos)
class DailyStats {
  final DateTime date;
  final double completionRate;
  final int totalTasks;
  final int completedTasks;

  const DailyStats({
    required this.date,
    required this.completionRate,
    required this.totalTasks,
    required this.completedTasks,
  });
}
