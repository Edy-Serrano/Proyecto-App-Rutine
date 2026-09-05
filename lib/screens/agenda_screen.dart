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
  bool _showTimeline = false;

  @override
  void initState() {
    super.initState();
    widget.provider.addListener(_onProviderChange);
  }

  @override
  void dispose() {
    widget.provider.removeListener(_onProviderChange);
    super.dispose();
  }

  void _onProviderChange() {
    if (mounted) setState(() {});
  }

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
            icon: Icon(
              _showTimeline ? Icons.calendar_month_rounded : Icons.calendar_view_week_rounded,
              color: AppTheme.neonPurple,
            ),
            onPressed: () {
              setState(() {
                _showTimeline = !_showTimeline;
                if (_showTimeline) {
                   _selectedDay = DateTime.now();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.today_rounded, color: AppTheme.neonCyan),
            onPressed: () => setState(() {
              _focusedMonth = DateTime.now();
              _selectedDay = DateTime.now();
            }),
          ),
        ],
      ),
      body: _showTimeline ? _buildTimelineWeekly() : Column(
        children: [
          // === HEADER CALENDARIO ===
          _buildCalendarHeader(),
          // === GRID DE DÍAS ===
          _buildCalendarGrid(),
          const SizedBox(height: 8),
          // === MINI STAT DEL DÍA ===
          if (tasksForDay.isNotEmpty) _buildDayStatBar(rate, tasksForDay.where((t) => !t.isCancelled).length),
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
          color: task.isCancelled
              ? Colors.redAccent.withOpacity(0.3)
              : task.isCompleted
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
                  await widget.provider.completeTask(task.id, minutes: minutes, note: note);
                  if (mounted) setState(() {});
                }
              } else {
                await widget.provider.toggleTask(task.id);
                if (mounted) setState(() {});
              }
            },
            onLongPress: () async {
              if (task.isCompleted) {
                HapticFeedback.heavyImpact();
                await widget.provider.toggleTask(task.id);
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
                  color: task.isCancelled
                      ? Colors.redAccent
                      : task.isCompleted
                          ? AppTheme.neonGreen
                          : task.category.color,
                  width: 2,
                ),
                color: task.isCancelled
                    ? Colors.redAccent
                    : task.isCompleted
                        ? AppTheme.neonGreen.withOpacity(0.2)
                        : Colors.transparent,
              ),
              child: task.isCancelled
                  ? const Icon(Icons.close, size: 14, color: Colors.white)
                  : task.isCompleted
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
                    color: (task.isCompleted || task.isCancelled)
                        ? AppTheme.textMuted
                        : AppTheme.textPrimary,
                    decoration: (task.isCompleted || task.isCancelled)
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: task.isCancelled ? Colors.redAccent : null,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (task.time != null || task.isPostponed)
                  Row(
                    children: [
                      if (task.time != null) ...[
                        Text(
                          '${task.time!.hour.toString().padLeft(2, '0')}:${task.time!.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                              color: task.category.color,
                              fontSize: 11),
                        ),
                        if (task.isPostponed) const SizedBox(width: 6),
                      ],
                      if (task.isPostponed)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.orange.withOpacity(0.4)),
                          ),
                          child: const Text('Continúa →', style: TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                    ],
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
    final fullHistory = widget.provider.getFullHistory(task);
    int totalMinutes = 0;
    for (var log in fullHistory) {
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
              if (task.isCancelled) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.neonPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.neonPink.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cancel_outlined, color: AppTheme.neonPink),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tarea Cancelada', style: TextStyle(color: AppTheme.neonPink, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Motivo: ${task.cancelReason ?? "No especificado"}', style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (fullHistory.isNotEmpty) ...[
                const SizedBox(height: 16),
                Divider(color: AppTheme.bgSurface),
                const SizedBox(height: 8),
                const Text('Historial de Tiempo:', style: TextStyle(color: AppTheme.neonCyan, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...fullHistory.map((log) {
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
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.neonPink),
            onPressed: () async {
              final deleted = await _confirmDelete(context, task, widget.provider);
              if (deleted) {
                if (mounted) Navigator.pop(context);
                setState(() {});
              }
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: AppTheme.neonPurple)),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, Task task, TaskProvider provider) async {
    if (task.recurringGroupId != null) {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.bgCard,
          title: Text('Eliminar tarea', style: TextStyle(color: AppTheme.textPrimary)),
          content: Text('¿Deseas eliminar solo esta tarea o también todas las futuras repeticiones de esta rutina?', style: TextStyle(color: AppTheme.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: Text('Cancelar', style: TextStyle(color: AppTheme.textMuted)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'only_this'),
              child: const Text('Solo esta', style: TextStyle(color: AppTheme.neonCyan)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'future'),
              child: const Text('Esta y futuras', style: TextStyle(color: AppTheme.neonPink)),
            ),
          ],
        ),
      );
      if (result == 'cancel' || result == null) return false;
      if (result == 'future') {
        await provider.deleteRecurringFutureTasks(task);
      } else {
        await provider.deleteTask(task.id);
      }
      return true;
    } else {
      await provider.deleteTask(task.id);
      return true;
    }
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

  Widget _buildTimelineWeekly() {
    final int weekday = _selectedDay.weekday; // 1 = Lunes, 7 = Domingo
    final DateTime startOfWeek = _selectedDay.subtract(Duration(days: weekday - 1));
    final List<DateTime> weekDays = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    
    final int startHour = 5;
    final int endHour = 23;
    final double hourHeight = 60.0;
    final int totalHours = endHour - startHour + 1;
    
    return Column(
      children: [
        // Cabecera con días
        Container(
           color: AppTheme.bgCard,
           padding: const EdgeInsets.only(left: 48, right: 8, top: 12, bottom: 12),
           child: Row(
             children: weekDays.map((d) {
               bool isToday = _isSameDay(d, DateTime.now());
               return Expanded(
                 child: Column(
                   children: [
                     Text(
                       ['Lun','Mar','Mie','Jue','Vie','Sab','Dom'][d.weekday - 1], 
                       style: TextStyle(color: isToday ? AppTheme.neonPurple : AppTheme.textSecondary, fontSize: 12, fontWeight: isToday ? FontWeight.bold : FontWeight.normal)
                     ),
                     const SizedBox(height: 6),
                     Container(
                       padding: const EdgeInsets.all(8),
                       decoration: BoxDecoration(
                         shape: BoxShape.circle,
                         color: isToday ? AppTheme.neonPurple : Colors.transparent,
                       ),
                       child: Text('${d.day}', style: TextStyle(color: isToday ? Colors.white : AppTheme.textPrimary, fontWeight: isToday ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                     ),
                   ],
                 ),
               );
             }).toList(),
           ),
        ),
        // Cuerpo de la línea de tiempo
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna de horas
                SizedBox(
                  width: 48,
                  child: Column(
                    children: List.generate(totalHours, (index) {
                      int hour = startHour + index;
                      return Container(
                        height: hourHeight,
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('${hour.toString().padLeft(2, '0')}:00', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      );
                    }),
                  ),
                ),
                // Grid de días y tareas
                Expanded(
                  child: Stack(
                    children: [
                      // Grid de fondo (filas)
                      Column(
                        children: List.generate(totalHours, (index) {
                          return Container(
                            height: hourHeight,
                            decoration: BoxDecoration(
                              border: Border(top: BorderSide(color: AppTheme.bgSurface, width: 1)),
                            ),
                          );
                        }),
                      ),
                      // Grid de fondo (columnas)
                      Row(
                         children: List.generate(7, (index) => Expanded(
                           child: Container(
                             decoration: BoxDecoration(border: Border(left: BorderSide(color: AppTheme.bgSurface, width: 1))), 
                             height: totalHours * hourHeight,
                           )
                         )),
                      ),
                      // Tareas superpuestas
                      ..._buildTimelineTasks(weekDays, startHour, hourHeight),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTimelineTasks(List<DateTime> weekDays, int startHour, double hourHeight) {
    List<Widget> taskWidgets = [];
    
    // Usamos LayoutBuilder indirecamente asumiendo ancho disponible: screen width - (48 de horas + 8 de padding derecho)
    // Para simplificar, calcularemos en base al screen size dentro de la función build
    // pero como no tenemos acceso directo aquí, usamos MediaQuery
    
    for (int dayIdx = 0; dayIdx < 7; dayIdx++) {
      DateTime day = weekDays[dayIdx];
      List<Task> dailyTasks = widget.provider.tasksForDate(day).where((t) => !t.isCancelled && t.time != null).toList();
      
      for (var task in dailyTasks) {
        if (task.time!.hour < startHour || task.time!.hour > 23) continue;
        
        double topOffset = ((task.time!.hour - startHour) + (task.time!.minute / 60.0)) * hourHeight;
        
        double durationHours = 1.0; // 1 hora por defecto como solicitó el usuario
        if (task.endTime != null) {
           double startVal = task.time!.hour + (task.time!.minute / 60.0);
           double endVal = task.endTime!.hour + (task.endTime!.minute / 60.0);
           if (endVal > startVal) {
             durationHours = endVal - startVal;
           }
        }
        
        double height = durationHours * hourHeight;
        
        taskWidgets.add(
          Builder(
            builder: (context) {
              final colWidth = (MediaQuery.of(context).size.width - 56) / 7;
              return Positioned(
                top: topOffset,
                left: dayIdx * colWidth,
                width: colWidth,
                height: height,
                child: GestureDetector(
                  onTap: () => _showTaskDetails(context, task),
                  child: Container(
                    margin: const EdgeInsets.only(left: 2, right: 2, top: 1, bottom: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: task.category.color.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: task.category.color, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title, 
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold), 
                          maxLines: 2, 
                          overflow: TextOverflow.ellipsis
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          )
        );
      }
    }
    return taskWidgets;
  }
}
