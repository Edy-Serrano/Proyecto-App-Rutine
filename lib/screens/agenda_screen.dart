import 'package:flutter/material.dart';
import 'package:rutine/theme/app_theme.dart';
import 'package:rutine/models/task_model.dart';
import 'package:rutine/providers/task_provider.dart';
import 'package:rutine/screens/add_task_sheet.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/services.dart';
import 'package:rutine/widgets/time_log_dialog.dart';

class AgendaScreen extends StatefulWidget {
  final TaskProvider provider;
  const AgendaScreen({super.key, required this.provider});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final tasksForDay = widget.provider.tasksForDate(_selectedDay);
    final rate = widget.provider.completionRateForDate(_selectedDay);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Agenda'),
        backgroundColor: AppTheme.bgDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded, color: AppTheme.neonCyan),
            onPressed: () => setState(() {
              _focusedMonth = DateTime.now();
              _selectedDay = DateTime.now();
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          // === HEADER CALENDARIO ===
          _buildCalendarHeader(),
          // === GRID DE DÍAS ===
          _buildCalendarGrid(),
          const SizedBox(height: 8),
          // === MINI STAT DEL DÍA ===
          if (tasksForDay.isNotEmpty) _buildDayStatBar(rate, tasksForDay.length),
          // === LISTA DE TAREAS DEL DÍA ===
          Expanded(
            child: tasksForDay.isEmpty
                ? _buildEmptyDay()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: tasksForDay.length,
                    itemBuilder: (context, i) =>
                        _buildCompactTaskTile(tasksForDay[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTask(),
        backgroundColor: AppTheme.neonPurple,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left_rounded,
                color: AppTheme.textSecondary),
            onPressed: () => setState(() {
              _focusedMonth = DateTime(
                  _focusedMonth.year, _focusedMonth.month - 1);
            }),
          ),
          Text(
            '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right_rounded,
                color: AppTheme.textSecondary),
            onPressed: () => setState(() {
              _focusedMonth = DateTime(
                  _focusedMonth.year, _focusedMonth.month + 1);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    const dayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    // Offset: 0=Lun, 6=Dom
    final startOffset = (firstDay.weekday - 1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Cabecera de días
          Row(
            children: dayLabels
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Grid de días
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startOffset) return const SizedBox();
              final day = index - startOffset + 1;
              final date =
                  DateTime(_focusedMonth.year, _focusedMonth.month, day);
              final isSelected = _isSameDay(date, _selectedDay);
              final isToday = _isSameDay(date, DateTime.now());
              final hasTasks =
                  widget.provider.tasksForDate(date).isNotEmpty;
              final allDone = hasTasks &&
                  widget.provider.completionRateForDate(date) == 1.0;

              return GestureDetector(
                onTap: () => setState(() => _selectedDay = date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppTheme.neonPurple
                        : isToday
                            ? AppTheme.neonPurple.withOpacity(0.15)
                            : Colors.transparent,
                    border: isToday && !isSelected
                        ? Border.all(
                            color: AppTheme.neonPurple.withOpacity(0.5),
                            width: 1.5)
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? AppTheme.neonPurple
                                  : AppTheme.textPrimary,
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                      if (hasTasks && !isSelected)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: allDone
                                  ? AppTheme.neonGreen
                                  : AppTheme.neonCyan,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayStatBar(double rate, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.neonPurple.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return LinearPercentIndicator(
                    width: constraints.maxWidth,
                    lineHeight: 6,
                    percent: rate,
                    progressColor: AppTheme.neonCyan,
                    backgroundColor: AppTheme.bgSurface,
                    barRadius: const Radius.circular(3),
                    padding: EdgeInsets.zero,
                    animation: true,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${(rate * 100).toInt()}% · $total tareas',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactTaskTile(Task task) {
    return GestureDetector(
      onTap: () => _showTaskDetails(context, task),
      onLongPress: () {
        HapticFeedback.mediumImpact();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => AddTaskSheet(
            provider: widget.provider,
            taskToEdit: task,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: task.isCompleted
              ? AppTheme.neonGreen.withOpacity(0.3)
              : task.category.color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              if (!task.isCompleted) {
                final result = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (context) => TimeLogDialog(title: '¡Tarea completada!'),
                );
                
                if (result != null) {
                  final minutes = result['minutes'] as int;
                  final note = result['note'] as String;
                  if (minutes > 0 || note.isNotEmpty) {
                    await widget.provider.addTimeLog(
                      task.id,
                      TimeLog(date: DateTime.now(), minutes: minutes, note: note),
                    );
                  }
                }
                
                await widget.provider.toggleTaskCompletion(task.id);
                if (mounted) setState(() {});
              }
            },
            onLongPress: () async {
              if (task.isCompleted) {
                HapticFeedback.heavyImpact();
                await widget.provider.toggleTaskCompletion(task.id);
                if (mounted) setState(() {});
              }
            },
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isCompleted ? AppTheme.neonGreen : task.category.color,
                  width: 2,
                ),
                color: task.isCompleted
                    ? AppTheme.neonGreen.withOpacity(0.2)
                    : Colors.transparent,
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 14, color: AppTheme.neonGreen)
                  : null,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    color: task.isCompleted
                        ? AppTheme.textMuted
                        : AppTheme.textPrimary,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (task.time != null)
                  Text(
                    '${task.time!.hour.toString().padLeft(2, '0')}:${task.time!.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                        color: task.category.color,
                        fontSize: 11),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: task.category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              task.category.label,
              style: TextStyle(
                  color: task.category.color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildEmptyDay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available_rounded,
              size: 56, color: AppTheme.neonPurple.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text(
            'Sin tareas para este día',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            'Toca + para agregar una',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
  void _showTaskDetails(BuildContext context, Task task) {
    int totalMinutes = 0;
    for (var log in task.history) {
      totalMinutes += log.minutes;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(task.category.icon, color: task.category.color),
            const SizedBox(width: 12),
            Expanded(child: Text(task.title, style: TextStyle(color: AppTheme.textPrimary))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.description?.isNotEmpty == true ? task.description! : 'Sin descripción',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              if (task.history.isNotEmpty) ...[
                const SizedBox(height: 16),
                Divider(color: AppTheme.bgSurface),
                const SizedBox(height: 8),
                const Text('Historial de Tiempo:', style: TextStyle(color: AppTheme.neonCyan, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...task.history.map((log) {
                  const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
                  final dayStr = days[log.date.weekday - 1];
                  final timeStr = log.minutes >= 60 
                      ? '${log.minutes ~/ 60}h ${log.minutes % 60}m' 
                      : '${log.minutes}m';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '$dayStr: $timeStr - "${log.note.isNotEmpty ? log.note : 'Sin nota'}"',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 8),
                Text(
                  'Total Invertido: ${totalMinutes >= 60 ? '${totalMinutes ~/ 60}h ${totalMinutes % 60}m' : '${totalMinutes}m'}',
                  style: const TextStyle(color: AppTheme.neonPurple, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: AppTheme.neonPurple)),
          ),
        ],
      ),
    );
  }

  void _openAddTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskSheet(
        provider: widget.provider,
        initialDate: _selectedDay,
      ),
    ).then((_) => setState(() {}));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
