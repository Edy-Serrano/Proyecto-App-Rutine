import 'package:flutter/material.dart';
import 'package:rutine/theme/app_theme.dart';

enum TaskCategory { hygiene, university, work, shopping, leisure, sports, food, custom, ocio, reading, research, gaming, meditation }

enum TaskPriority { normal, important, strict }

extension TaskPriorityExtension on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.normal: return 'Normal';
      case TaskPriority.important: return 'Importante';
      case TaskPriority.strict: return 'Estricta';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.normal: return Colors.grey;
      case TaskPriority.important: return Colors.orange;
      case TaskPriority.strict: return Colors.red;
    }
  }
}
extension TaskCategoryExtension on TaskCategory {
  static List<TaskCategory> get uiOrder {
    final list = TaskCategory.values.toList();
    list.remove(TaskCategory.custom);
    list.add(TaskCategory.custom);
    return list;
  }

  String get label {
    switch (this) {
      case TaskCategory.hygiene:     return 'Higiene';
      case TaskCategory.university:  return 'Universidad';
      case TaskCategory.work:        return 'Trabajo';
      case TaskCategory.shopping:    return 'Compras';
      case TaskCategory.leisure:     return 'Paseo';
      case TaskCategory.sports:      return 'Deporte';
      case TaskCategory.food:        return 'Comida';
      case TaskCategory.custom:      return 'Otro';
      case TaskCategory.ocio:        return 'Entretenimiento';
      case TaskCategory.reading:     return 'Leer';
      case TaskCategory.research:    return 'Investigar';
      case TaskCategory.gaming:      return 'Gaming';
      case TaskCategory.meditation:  return 'Meditación';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskCategory.hygiene:     return Icons.shower_rounded;
      case TaskCategory.university:  return Icons.school_rounded;
      case TaskCategory.work:        return Icons.work_rounded;
      case TaskCategory.shopping:    return Icons.shopping_bag_rounded;
      case TaskCategory.leisure:     return Icons.directions_walk_rounded;
      case TaskCategory.sports:      return Icons.fitness_center_rounded;
      case TaskCategory.food:        return Icons.restaurant_rounded;
      case TaskCategory.custom:      return Icons.tag_rounded;
      case TaskCategory.ocio:        return Icons.local_movies_rounded;
      case TaskCategory.reading:     return Icons.menu_book_rounded;
      case TaskCategory.research:    return Icons.science_rounded;
      case TaskCategory.gaming:      return Icons.videogame_asset_rounded;
      case TaskCategory.meditation:  return Icons.self_improvement_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TaskCategory.hygiene:     return AppTheme.catHygiene;
      case TaskCategory.university:  return AppTheme.catUniversity;
      case TaskCategory.work:        return AppTheme.catWork;
      case TaskCategory.shopping:    return AppTheme.catShopping;
      case TaskCategory.leisure:     return AppTheme.catLeisure;
      case TaskCategory.sports:      return AppTheme.catSports;
      case TaskCategory.food:        return AppTheme.catFood;
      case TaskCategory.custom:      return AppTheme.catCustom;
      case TaskCategory.ocio:        return AppTheme.catOcio;
      case TaskCategory.reading:     return AppTheme.catReading;
      case TaskCategory.research:    return AppTheme.catResearch;
      case TaskCategory.gaming:      return AppTheme.catGaming;
      case TaskCategory.meditation:  return AppTheme.catMeditation;
    }
  }
}

class TimeLog {
  final DateTime date;
  final int minutes;
  final String note;

  TimeLog({required this.date, required this.minutes, this.note = ''});

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'minutes': minutes,
      'note': note,
    };
  }

  factory TimeLog.fromMap(Map<dynamic, dynamic> map) {
    return TimeLog(
      date: DateTime.parse(map['date'] as String),
      minutes: map['minutes'] as int,
      note: map['note'] as String? ?? '',
    );
  }
}

class Task {
  final String id;
  String title;
  String? description;
  TaskCategory category;
  DateTime date;
  TimeOfDay? time;
  TimeOfDay? endTime;
  TaskPriority priority;
  bool isCompleted;
  bool isCancelled;
  String? cancelReason;
  bool isPostponed;        // true si fue postergada (queda en el día original con check)
  String? postponedFromId; // id de la tarea predecesora si esta es una continuación
  bool isRecurring;
  List<int> recurringDays;
  DateTime? recurringEndDate;
  String? recurringGroupId;
  int? notificationMinutes;
  List<TimeLog> history;
  Map<String, dynamic>? foodMetadata;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.date,
    this.time,
    this.endTime,
    this.priority = TaskPriority.normal,
    this.isCompleted = false,
    this.isCancelled = false,
    this.cancelReason,
    this.isPostponed = false,
    this.postponedFromId,
    this.isRecurring = false,
    this.recurringDays = const [],
    this.recurringEndDate,
    this.recurringGroupId,
    this.notificationMinutes,
    List<TimeLog>? history,
    this.foodMetadata,
  }) : history = history ?? [];

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    DateTime? date,
    TimeOfDay? time,
    TimeOfDay? endTime,
    TaskPriority? priority,
    bool? isCompleted,
    bool? isCancelled,
    String? cancelReason,
    bool? isPostponed,
    String? postponedFromId,
    bool? isRecurring,
    List<int>? recurringDays,
    DateTime? recurringEndDate,
    String? recurringGroupId,
    int? notificationMinutes,
    List<TimeLog>? history,
    Map<String, dynamic>? foodMetadata,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      time: time ?? this.time,
      endTime: endTime ?? this.endTime,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      isCancelled: isCancelled ?? this.isCancelled,
      cancelReason: cancelReason ?? this.cancelReason,
      isPostponed: isPostponed ?? this.isPostponed,
      postponedFromId: postponedFromId ?? this.postponedFromId,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringDays: recurringDays ?? this.recurringDays,
      recurringEndDate: recurringEndDate ?? this.recurringEndDate,
      recurringGroupId: recurringGroupId ?? this.recurringGroupId,
      notificationMinutes: notificationMinutes ?? this.notificationMinutes,
      history: history ?? this.history.map((e) => TimeLog(date: e.date, minutes: e.minutes, note: e.note)).toList(),
      foodMetadata: foodMetadata ?? (this.foodMetadata != null ? Map<String, dynamic>.from(this.foodMetadata!) : null),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.index,
      'date': date.toIso8601String(),
      'timeHour': time?.hour,
      'timeMinute': time?.minute,
      'endTimeHour': endTime?.hour,
      'endTimeMinute': endTime?.minute,
      'priority': priority.index,
      'isCompleted': isCompleted,
      'isCancelled': isCancelled,
      'cancelReason': cancelReason,
      'isPostponed': isPostponed,
      'postponedFromId': postponedFromId,
      'isRecurring': isRecurring,
      'recurringDays': recurringDays,
      'recurringEndDate': recurringEndDate?.toIso8601String(),
      'recurringGroupId': recurringGroupId,
      'notificationMinutes': notificationMinutes,
      'history': history.map((e) => e.toMap()).toList(),
      'foodMetadata': foodMetadata,
    };
  }

  factory Task.fromMap(Map<dynamic, dynamic> map) {
    TimeOfDay? t;
    if (map['timeHour'] != null && map['timeMinute'] != null) {
      t = TimeOfDay(hour: map['timeHour'] as int, minute: map['timeMinute'] as int);
    }
    TimeOfDay? eT;
    if (map['endTimeHour'] != null && map['endTimeMinute'] != null) {
      eT = TimeOfDay(hour: map['endTimeHour'] as int, minute: map['endTimeMinute'] as int);
    }
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      category: TaskCategory.values[map['category'] as int? ?? 0],
      date: DateTime.parse(map['date'] as String),
      time: t,
      endTime: eT,
      priority: TaskPriority.values[map['priority'] as int? ?? 0],
      isCompleted: map['isCompleted'] as bool? ?? false,
      isCancelled: map['isCancelled'] as bool? ?? false,
      cancelReason: map['cancelReason'] as String?,
      isPostponed: map['isPostponed'] as bool? ?? false,
      postponedFromId: map['postponedFromId'] as String?,
      isRecurring: map['isRecurring'] as bool? ?? false,
      recurringDays: (map['recurringDays'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      recurringEndDate: map['recurringEndDate'] != null ? DateTime.parse(map['recurringEndDate'] as String) : null,
      recurringGroupId: map['recurringGroupId'] as String?,
      notificationMinutes: map['notificationMinutes'] as int?,
      history: (map['history'] as List<dynamic>?)?.map((e) => TimeLog.fromMap(e as Map<dynamic, dynamic>)).toList() ?? [],
      foodMetadata: map['foodMetadata'] != null ? Map<String, dynamic>.from(map['foodMetadata'] as Map) : null,
    );
  }
}
