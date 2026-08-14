import 'package:rutine/models/task_model.dart';

class MonthlyGoal {
  final String id;
  final TaskCategory category;
  final int targetMinutes;
  final int month;
  final int year;

  MonthlyGoal({
    required this.id,
    required this.category,
    required this.targetMinutes,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category.index,
      'targetMinutes': targetMinutes,
      'month': month,
      'year': year,
    };
  }

  factory MonthlyGoal.fromMap(Map<dynamic, dynamic> map) {
    return MonthlyGoal(
      id: map['id'] as String,
      category: TaskCategory.values[map['category'] as int? ?? 0],
      targetMinutes: map['targetMinutes'] as int? ?? 0,
      month: map['month'] as int,
      year: map['year'] as int,
    );
  }
}
