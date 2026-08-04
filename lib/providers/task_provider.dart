import 'package:flutter/material.dart';
import 'package:rutine/models/task_model.dart';
import 'package:rutine/services/hive_service.dart';
import 'package:rutine/services/notification_service.dart';

/// Proveedor central de estado con persistencia local mediante Hive.
class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  String _userName = 'Usuario';
  String? _userImagePath;

  TaskProvider() {
    _loadTasks();
  }

  void _loadTasks() {
    _tasks = HiveService.getTasks();
    _userName = HiveService.getUserName();
    _userImagePath = HiveService.getUserImagePath();
    notifyListeners();
  }

  List<Task> get tasks => List.unmodifiable(_tasks);
  String get userName => _userName;
  String? get userImagePath => _userImagePath;

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

  Map<TaskCategory, int> timeInvestedByCategory(DateTime date) {
    final Map<TaskCategory, int> result = {};
    for (var cat in TaskCategory.values) {
      result[cat] = 0;
    }
    for (var task in _tasks) {
      for (var log in task.history) {
        if (log.date.year == date.year && log.date.month == date.month && log.date.day == date.day) {
          result[task.category] = (result[task.category] ?? 0) + log.minutes;
        }
      }
    }
    result.removeWhere((key, value) => value == 0);
    return result;
  }

  int totalTimeInvested(DateTime date) {
    int total = 0;
    for (var task in _tasks) {
      for (var log in task.history) {
        if (log.date.year == date.year && log.date.month == date.month && log.date.day == date.day) {
          total += log.minutes;
        }
      }
    }
    return total;
  }

  Map<String, int> foodStats(DateTime date) {
    int water = 0;
    int protein = 0;
    int carbs = 0;
    
    for (var task in _tasks) {
      if (task.category == TaskCategory.food && task.foodMetadata != null && task.isCompleted) {
        // we can check if it was completed on the selected date by looking at the history logs,
        // or just by date. Since tasks are not specifically tied to date in terms of completion, 
        // we check if it has a log in that date, or if its `date` field is that date.
        bool hasLog = task.history.any((log) => 
            log.date.year == date.year && log.date.month == date.month && log.date.day == date.day);
            
        if (hasLog || (task.date.year == date.year && task.date.month == date.month && task.date.day == date.day)) {
          water += task.foodMetadata!['water'] as int? ?? 0;
          protein += task.foodMetadata!['protein'] as int? ?? 0;
          carbs += task.foodMetadata!['carbs'] as int? ?? 0;
        }
      }
    }
    return {'water': water, 'protein': protein, 'carbs': carbs};
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

  /// Completadas por nombre de tarea
  Map<String, int> completedByTaskName() {
    final map = <String, int>{};
    for (final task in _tasks.where((t) => t.isCompleted)) {
      final name = task.title.trim();
      map[name] = (map[name] ?? 0) + 1;
    }
    return map;
  }

  /// Total de tareas por nombre de tarea
  Map<String, int> totalByTaskName() {
    final map = <String, int>{};
    for (final task in _tasks) {
      final name = task.title.trim();
      map[name] = (map[name] ?? 0) + 1;
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
    _scheduleNotificationIfNeeded(task);
    notifyListeners();
  }

  Future<void> addTimeLog(String id, TimeLog log) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].history.add(log);
      await HiveService.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
      await HiveService.updateTask(_tasks[index]);
      
      if (_tasks[index].isCompleted) {
        await NotificationService.cancelNotification(_tasks[index].id.hashCode);
      } else {
        _scheduleNotificationIfNeeded(_tasks[index]);
      }
      
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    await HiveService.deleteTask(taskId);
    await NotificationService.cancelNotification(taskId.hashCode);
    notifyListeners();
  }

  Future<void> updateTask(Task updated) async {
    final index = _tasks.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _tasks[index] = updated;
      await HiveService.updateTask(updated);
      await NotificationService.cancelNotification(updated.id.hashCode);
      if (!updated.isCompleted) {
        _scheduleNotificationIfNeeded(updated);
      }
      notifyListeners();
    }
  }

  Future<void> _scheduleNotificationIfNeeded(Task task) async {
    if (task.time == null || task.isCompleted) return;
    
    DateTime scheduled = DateTime(
      task.date.year,
      task.date.month,
      task.date.day,
      task.time!.hour,
      task.time!.minute,
    );

    if (task.notificationMinutes != null) {
      scheduled = scheduled.subtract(Duration(minutes: task.notificationMinutes!));
    }

    if (scheduled.isAfter(DateTime.now())) {
      final title = task.notificationMinutes != null
          ? 'En ${task.notificationMinutes} min: ¡Tu tarea!'
          : '¡Hora de tu tarea!';
      await NotificationService.scheduleTaskNotification(
        id: task.id.hashCode,
        title: title,
        body: task.title,
        scheduledDate: scheduled,
      );
    }
  }

  Future<void> updateUserName(String name) async {
    _userName = name;
    await HiveService.setUserName(name);
    notifyListeners();
  }

  Future<void> updateUserImage(String path) async {
    _userImagePath = path;
    await HiveService.setUserImagePath(path);
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
