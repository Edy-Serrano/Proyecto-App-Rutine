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

  Future<void> _loadTasks() async {
    _tasks = await HiveService.getTasks();
    
    // Limpieza: Eliminar TimeLogs en tareas no completadas con recurringGroupId
    // para prevenir datos fantasma (se ejecuta solo en background)
    _cleanupGhostLogs();

    _userName = HiveService.getUserName();
    _userImagePath = HiveService.getUserImagePath();
    notifyListeners();
  }

  /// Limpia logs huerófanos en background sin bloquear la UI
  Future<void> _cleanupGhostLogs() async {
    bool changed = false;
    for (var task in _tasks) {
      // Limpiar logs de tareas recurrentes que no correspondan a su fecha
      if (task.recurringGroupId != null && task.history.isNotEmpty) {
        final before = task.history.length;
        task.history.retainWhere((log) =>
            log.date.year == task.date.year &&
            log.date.month == task.date.month &&
            log.date.day == task.date.day);
        if (task.history.length != before) {
          await HiveService.updateTask(task);
          changed = true;
        }
      }
    }
    if (changed) notifyListeners();
  }

  List<Task> get tasks => List.unmodifiable(_tasks);
  String get userName => _userName;
  String? get userImagePath => _userImagePath;

  // ─── CONSULTAS ──────────────────────────────────────────────────────────────

  /// Tareas asignadas a un día específico (incluye recurrentes)
  List<Task> tasksForDate(DateTime date) {
    return _tasks.where((t) {
      final sameDay = _isSameDay(t.date, date);
      final isLegacyRecurringToday =
          t.isRecurring && t.recurringGroupId == null && t.recurringDays.contains(date.weekday);
      return sameDay || isLegacyRecurringToday;
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
  double weeklyCompletionRate(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
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

  /// % de completitud del mes (según la fecha seleccionada)
  double monthlyCompletionRate(DateTime date) {
    final now = DateTime.now();
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    double total = 0;
    int days = 0;
    for (int i = 1; i <= daysInMonth; i++) {
      final day = DateTime(date.year, date.month, i);
      // Si el mes es el actual, no calculamos días futuros. Si es un mes pasado, calculamos todo el mes.
      if (day.year == now.year && day.month == now.month && day.isAfter(now)) break;
      if (tasksForDate(day).isNotEmpty) {
        total += completionRateForDate(day);
        days++;
      }
    }
    return days == 0 ? 0.0 : total / days;
  }

  /// % de completitud semanal por categoría
  Map<TaskCategory, double> weeklyCompletionRateByCategory(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    final Map<TaskCategory, double> totals = {};
    final Map<TaskCategory, int> daysCount = {};

    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      final allTasks = tasksForDate(day);
      
      for (var cat in TaskCategory.values) {
        final catTasks = allTasks.where((t) => t.category == cat).toList();
        if (catTasks.isNotEmpty) {
          final completed = catTasks.where((t) => t.isCompleted).length;
          final rate = completed / catTasks.length;
          totals[cat] = (totals[cat] ?? 0.0) + rate;
          daysCount[cat] = (daysCount[cat] ?? 0) + 1;
        }
      }
    }

    final result = <TaskCategory, double>{};
    for (var cat in totals.keys) {
      result[cat] = totals[cat]! / daysCount[cat]!;
    }
    return result;
  }

  /// % de completitud mensual por categoría
  Map<TaskCategory, double> monthlyCompletionRateByCategory(DateTime date) {
    final now = DateTime.now();
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    final Map<TaskCategory, double> totals = {};
    final Map<TaskCategory, int> daysCount = {};

    for (int i = 1; i <= daysInMonth; i++) {
      final day = DateTime(date.year, date.month, i);
      if (day.year == now.year && day.month == now.month && day.isAfter(now)) break;
      
      final allTasks = tasksForDate(day);
      for (var cat in TaskCategory.values) {
        final catTasks = allTasks.where((t) => t.category == cat).toList();
        if (catTasks.isNotEmpty) {
          final completed = catTasks.where((t) => t.isCompleted).length;
          final rate = completed / catTasks.length;
          totals[cat] = (totals[cat] ?? 0.0) + rate;
          daysCount[cat] = (daysCount[cat] ?? 0) + 1;
        }
      }
    }

    final result = <TaskCategory, double>{};
    for (var cat in totals.keys) {
      result[cat] = totals[cat]! / daysCount[cat]!;
    }
    return result;
  }

  /// Racha actual de días consecutivos con 100% de completitud
  int get currentStreak {
    if (_tasks.isEmpty) return 0;
    
    int streak = 0;
    DateTime day = DateTime.now();
    
    // Si hoy no está 100% completo, empieza desde ayer
    if (completionRateForDate(day) < 1.0 && tasksForDate(day).isNotEmpty) {
      day = day.subtract(const Duration(days: 1));
    }
    
    final dates = _tasks.map((t) => t.date).toList();
    dates.sort();
    final earliest = dates.first;

    while (day.isAfter(earliest) || _isSameDay(day, earliest)) {
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

  Map<TaskCategory, int> timeInvestedByCategoryMonthly(DateTime date) {
    final Map<TaskCategory, int> result = {};
    for (var cat in TaskCategory.values) {
      result[cat] = 0;
    }
    for (var task in _tasks) {
      for (var log in task.history) {
        if (log.date.year == date.year && log.date.month == date.month) {
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

  /// Completadas por categoría del día (para el pie chart diario)
  Map<TaskCategory, int> completedByCategoryDaily(DateTime date) {
    final map = <TaskCategory, int>{};
    for (final task in tasksForDate(date).where((t) => t.isCompleted)) {
      map[task.category] = (map[task.category] ?? 0) + 1;
    }
    return map;
  }

  /// Completadas por categoría del mes (para el pie chart mensual)
  Map<TaskCategory, int> completedByCategoryMonthly(DateTime date) {
    final map = <TaskCategory, int>{};
    for (final task in _tasks.where((t) => t.isCompleted && t.date.year == date.year && t.date.month == date.month)) {
      map[task.category] = (map[task.category] ?? 0) + 1;
    }
    return map;
  }

  /// Total de tareas por categoría (histórico general, útil para otras métricas)
  Map<TaskCategory, int> totalByCategory() {
    final map = <TaskCategory, int>{};
    for (final task in _tasks) {
      map[task.category] = (map[task.category] ?? 0) + 1;
    }
    return map;
  }

  /// Completadas por nombre de tarea (en el mes seleccionado)
  Map<String, int> completedByTaskName(DateTime date) {
    final map = <String, int>{};
    for (final task in _tasks.where((t) => t.isCompleted && t.date.year == date.year && t.date.month == date.month)) {
      final name = task.title.trim();
      map[name] = (map[name] ?? 0) + 1;
    }
    return map;
  }

  /// Total de tareas por nombre de tarea (en el mes seleccionado)
  Map<String, int> totalByTaskName(DateTime date) {
    final map = <String, int>{};
    for (final task in _tasks.where((t) => t.date.year == date.year && t.date.month == date.month)) {
      final name = task.title.trim();
      map[name] = (map[name] ?? 0) + 1;
    }
    return map;
  }

  /// Datos de completitud por día para los últimos 7 días terminando en la fecha seleccionada
  List<DailyStats> getLast7DaysStats(DateTime date) {
    final result = <DailyStats>[];
    for (int i = 6; i >= 0; i--) {
      final day = date.subtract(Duration(days: i));
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
    if (task.isRecurring && task.recurringEndDate != null) {
      final groupId = task.recurringGroupId ?? 'grp_${DateTime.now().millisecondsSinceEpoch}';
      
      DateTime current = task.date;
      while (!current.isAfter(task.recurringEndDate!)) {
        if (task.recurringDays.contains(current.weekday)) {
          final newTask = task.copyWith(
            id: 'task_${DateTime.now().microsecondsSinceEpoch}_${current.millisecondsSinceEpoch}',
            date: current,
            recurringGroupId: groupId,
            history: [],
          );
          _tasks.add(newTask);
          await HiveService.addTask(newTask);
          _scheduleNotificationIfNeeded(newTask);
        }
        current = current.add(const Duration(days: 1));
      }
    } else {
      _tasks.add(task);
      await HiveService.addTask(task);
      _scheduleNotificationIfNeeded(task);
    }
    notifyListeners();
  }

  Future<void> addTimeLog(String id, TimeLog log) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].history.add(log);
      await HiveService.updateTask(_tasks[index]);
      notifyListeners();
    }
  }

  /// Completa una tarea: guarda el TimeLog y la marca en UNA sola escritura a Hive
  Future<void> completeTask(String id, {int minutes = 0, String note = ''}) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      if (minutes > 0 || note.isNotEmpty) {
        task.history.add(TimeLog(date: DateTime.now(), minutes: minutes, note: note));
      }
      task.isCompleted = true;
      await HiveService.updateTask(task);
      await NotificationService.cancelNotification(task.id.hashCode);
      notifyListeners();
    }
  }

  /// Posterga una tarea:
  /// 1. Marca la original como completada + postergada (queda en su día con "Continúa →")
  /// 2. Crea una nueva tarea en la fecha futura heredando el historial acumulado
  Future<void> postponeTask(Task original, DateTime newDate, {int minutes = 0, String note = ''}) async {
    // ── Paso 1: Actualizar la tarea original ──────────────────────────────────
    final origIndex = _tasks.indexWhere((t) => t.id == original.id);
    if (origIndex == -1) return;

    final origTask = _tasks[origIndex];

    // Registrar el tiempo de hoy en la tarea original
    if (minutes > 0 || note.isNotEmpty) {
      origTask.history.add(TimeLog(date: DateTime.now(), minutes: minutes, note: note));
    }
    origTask.isCompleted = true;
    origTask.isPostponed = true;
    await HiveService.updateTask(origTask);
    await NotificationService.cancelNotification(origTask.id.hashCode);

    // ── Paso 2: Crear la tarea continuación en la nueva fecha ─────────────────
    // NO copiar el historial para evitar doble conteo. Se calculará dinámicamente con getFullHistory.
    final continuation = Task(
      id: 'task_${DateTime.now().microsecondsSinceEpoch}',
      title: original.title,
      description: original.description,
      category: original.category,
      date: DateTime(newDate.year, newDate.month, newDate.day),
      time: original.time,
      isCompleted: false,
      isPostponed: false,
      postponedFromId: original.id,  // enlace a la predecesora
      isRecurring: false,            // la continuación no hereda recurrencia
      recurringDays: [],
      notificationMinutes: original.notificationMinutes,
      history: [],
      foodMetadata: original.foodMetadata != null
          ? Map<String, dynamic>.from(original.foodMetadata!)
          : null,
    );

    _tasks.add(continuation);
    await HiveService.addTask(continuation);
    _scheduleNotificationIfNeeded(continuation);

    notifyListeners();
  }

  Future<void> toggleTask(String id) async {
    int index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      task.isCompleted = !task.isCompleted;
      
      // Si el usuario desmarca la tarea, limpiar el historial del día
      if (!task.isCompleted) {
        final now = DateTime.now();
        task.history.removeWhere((log) =>
          log.date.year == now.year && log.date.month == now.month && log.date.day == now.day);
      }
      
      await HiveService.updateTask(task);
      if (task.isCompleted) {
        await NotificationService.cancelNotification(task.id.hashCode);
      } else {
        _scheduleNotificationIfNeeded(task);
      }
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    final taskToDeleteIndex = _tasks.indexWhere((t) => t.id == taskId);
    
    // Si la tarea a eliminar tiene hijos que fueron postergados desde ella, 
    // enlazarlos al padre de la tarea eliminada para no romper la cadena.
    if (taskToDeleteIndex != -1) {
      final taskToDelete = _tasks[taskToDeleteIndex];
      for (var t in _tasks) {
        if (t.postponedFromId == taskId) {
          t.postponedFromId = taskToDelete.postponedFromId;
          await HiveService.updateTask(t);
        }
      }
    }

    _tasks.removeWhere((t) => t.id == taskId);
    await HiveService.deleteTask(taskId);
    await NotificationService.cancelNotification(taskId.hashCode);
    notifyListeners();
  }

  /// Recupera el historial completo de la tarea recorriendo sus predecesoras hacia atrás
  List<TimeLog> getFullHistory(Task task) {
    List<TimeLog> fullHistory = [...task.history];
    String? currentId = task.postponedFromId;
    
    // Evitar bucles infinitos por si acaso (máximo 365 días de postergación seguidos)
    int safetyCounter = 0;
    while (currentId != null && safetyCounter < 365) {
      final predecessor = _tasks.firstWhere(
        (t) => t.id == currentId, 
        orElse: () => Task(id: '', title: '', category: TaskCategory.custom, date: DateTime.now()) // Dummy falso
      );
      
      if (predecessor.id.isNotEmpty) {
        fullHistory.insertAll(0, predecessor.history);
        currentId = predecessor.postponedFromId;
      } else {
        break; // predecesora ya no existe
      }
      safetyCounter++;
    }
    
    return fullHistory;
  }

  Future<void> deleteRecurringFutureTasks(Task template) async {
    final groupId = template.recurringGroupId;
    if (groupId == null) return;
    
    // Eliminar esta tarea y todas las futuras que pertenezcan al mismo grupo
    final futureTasks = _tasks.where((t) => 
      t.recurringGroupId == groupId && 
      !t.date.isBefore(template.date)
    ).toList();

    for (var t in futureTasks) {
      _tasks.removeWhere((task) => task.id == t.id);
      await HiveService.deleteTask(t.id);
      await NotificationService.cancelNotification(t.id.hashCode);
    }
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

  Future<void> updateRecurringFutureTasks(Task updatedTemplate) async {
    final groupId = updatedTemplate.recurringGroupId;
    if (groupId == null) return;
    
    // Solo actualizar tareas a partir de la fecha de la tarea original que se editó
    final fromDate = DateTime(updatedTemplate.date.year, updatedTemplate.date.month, updatedTemplate.date.day);
    
    bool changed = false;
    for (int i = 0; i < _tasks.length; i++) {
      final t = _tasks[i];
      if (t.recurringGroupId == groupId) {
        final tDate = DateTime(t.date.year, t.date.month, t.date.day);
        if (tDate.isAfter(fromDate) || tDate.isAtSameMomentAs(fromDate)) {
          // Copiar propiedades (pero mantener su propia fecha e historial de log, isCompleted, id)
          final newTask = t.copyWith(
            title: updatedTemplate.title,
            description: updatedTemplate.description,
            category: updatedTemplate.category,
            time: updatedTemplate.time,
            isRecurring: updatedTemplate.isRecurring,
            recurringDays: updatedTemplate.recurringDays,
            recurringEndDate: updatedTemplate.recurringEndDate,
            notificationMinutes: updatedTemplate.notificationMinutes,
            foodMetadata: updatedTemplate.foodMetadata,
          );
          _tasks[i] = newTask;
          await HiveService.updateTask(newTask);
          await NotificationService.cancelNotification(newTask.id.hashCode);
          if (!newTask.isCompleted) {
            _scheduleNotificationIfNeeded(newTask);
          }
          changed = true;
        }
      }
    }
    if (changed) notifyListeners();
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
          ? 'En ${task.notificationMinutes} min: ¡Tu actividad!'
          : '¡Hora de tu actividad!';
      await NotificationService.scheduleTaskNotification(
        id: task.id.hashCode,
        title: title,
        body: task.title,
        scheduledDate: scheduled,
        color: task.category.color,
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
