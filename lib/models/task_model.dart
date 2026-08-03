import 'package:flutter/material.dart';
import 'package:rutine/theme/app_theme.dart';

enum TaskCategory { hygiene, university, work, shopping, leisure, custom }

extension TaskCategoryExtension on TaskCategory {
  String get label {
    switch (this) {
      case TaskCategory.hygiene:     return 'Higiene';
      case TaskCategory.university:  return 'Universidad';
      case TaskCategory.work:        return 'Trabajo';
      case TaskCategory.shopping:    return 'Compras';
      case TaskCategory.leisure:     return 'Paseo / Ocio';
      case TaskCategory.custom:      return 'Otro';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskCategory.hygiene:     return Icons.shower_rounded;
      case TaskCategory.university:  return Icons.school_rounded;
      case TaskCategory.work:        return Icons.work_rounded;
      case TaskCategory.shopping:    return Icons.shopping_bag_rounded;
      case TaskCategory.leisure:     return Icons.directions_walk_rounded;
      case TaskCategory.custom:      return Icons.tag_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TaskCategory.hygiene:     return AppTheme.catHygiene;
      case TaskCategory.university:  return AppTheme.catUniversity;
      case TaskCategory.work:        return AppTheme.catWork;
      case TaskCategory.shopping:    return AppTheme.catShopping;
      case TaskCategory.leisure:     return AppTheme.catLeisure;
      case TaskCategory.custom:      return AppTheme.neonCyan;
    }
  }
}

class Task {
  final String id;
  String title;
  String? description;
  TaskCategory category;
  DateTime date;
  TimeOfDay? time;
  bool isCompleted;
  bool isRecurring;
  List<int> recurringDays; // 1=Lunes, 7=Domingo (basado en weekday de DateTime)

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.date,
    this.time,
    this.isCompleted = false,
    this.isRecurring = false,
    this.recurringDays = const [],
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    DateTime? date,
    TimeOfDay? time,
    bool? isCompleted,
    bool? isRecurring,
    List<int>? recurringDays,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringDays: recurringDays ?? this.recurringDays,
    );
  }
}
