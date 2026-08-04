import 'package:flutter/material.dart';
import 'package:rutine/theme/app_theme.dart';
import 'package:rutine/models/task_model.dart';
import 'package:rutine/providers/task_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/services.dart';
import 'package:rutine/screens/add_task_sheet.dart';
import 'package:rutine/utils/quotes_repository.dart';
import 'package:rutine/services/hive_service.dart';
import 'package:rutine/widgets/time_log_dialog.dart';

class DashboardScreen extends StatefulWidget {
  final TaskProvider provider;
  const DashboardScreen({super.key, required this.provider});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _selectedDate = DateTime.now();

  String _greeting(String name) {
    final hour = DateTime.now().hour;
    if (hour < 12) return '¡Buenos días, $name! ☀️';
    if (hour < 19) return '¡Buenas tardes, $name! 🌤️';
    return '¡Buenas noches, $name! 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final todayTasks = provider.tasksForDate(_selectedDate);
    final completionRate = provider.completionRateForDate(_selectedDate);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          // === APP BAR ===
          SliverAppBar(
            expandedHeight: 155,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.bgDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.neonPurple.withOpacity(0.1),
                      AppTheme.bgDark,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 85, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(provider.userName),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formattedDate(_selectedDate),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            title: const Text(
              'Rutine',
              style: TextStyle(
                color: AppTheme.neonPurple,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // === FRASE DEL DÍA ===
                  _buildQuoteCard(context),

                  const SizedBox(height: 20),

                  // === TARJETA DE PROGRESO DEL DÍA ===
                  _buildProgressCard(context, completionRate, todayTasks.length,
                      todayTasks.where((t) => t.isCompleted).length),

                  const SizedBox(height: 28),

                  // === TÍTULO LISTA DE TAREAS ===
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tareas de hoy',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${todayTasks.where((t) => t.isCompleted).length}/${todayTasks.length}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.neonCyan,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // === LISTA DE TAREAS O ESTADO VACÍO ===
                  todayTasks.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: todayTasks.length,
                          itemBuilder: (context, index) {
                            return _buildTaskCard(context, todayTasks[index], provider);
                          },
                        ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
      BuildContext context, double rate, int total, int completed) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E0050), Color(0xFF0A1628)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.neonPurple.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonPurple.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 55,
            lineWidth: 8,
            percent: rate,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(rate * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.neonCyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                ),
                Text(
                  'hoy',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
            progressColor: AppTheme.neonCyan,
            backgroundColor: AppTheme.bgSurface,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  total == 0 ? 'Sin tareas aún' : completed == total ? '¡Día completado! 🎉' : 'Sigue así, ¡tú puedes!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                _buildStatRow(context, '✅ Completadas', '$completed'),
                _buildStatRow(context, '⏳ Pendientes', '${total - completed}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.neonPurple, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task, TaskProvider provider) {
    return Dismissible(
      key: Key(task.id),
      background: _swipeBackground(true),
      secondaryBackground: _swipeBackground(false),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          provider.toggleTaskCompletion(task.id);
        } else {
          provider.deleteTask(task.id);
        }
      },
      child: GestureDetector(
        onTap: () => _showTaskDetails(context, task),
        onLongPress: () {
          HapticFeedback.mediumImpact();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddTaskSheet(
              provider: provider,
              taskToEdit: task,
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: task.isCompleted
                ? AppTheme.bgSurface.withOpacity(0.5)
                : AppTheme.bgCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: task.isCompleted
                  ? AppTheme.neonGreen.withOpacity(0.3)
                  : task.category.color.withOpacity(0.25),
              width: 1,
            ),
          ),
        child: Row(
          children: [
            // Icono de categoría
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: task.category.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(task.category.icon,
                  color: task.isCompleted
                      ? AppTheme.textMuted
                      : task.category.color,
                  size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration:
                              task.isCompleted ? TextDecoration.lineThrough : null,
                          color: task.isCompleted
                              ? AppTheme.textMuted
                              : AppTheme.textPrimary,
                        ),
                  ),
                  if (task.time != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${task.time!.hour.toString().padLeft(2, '0')}:${task.time!.minute.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: task.category.color,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            // Checkbox animado
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
                      await provider.addTimeLog(
                        task.id,
                        TimeLog(date: DateTime.now(), minutes: minutes, note: note),
                      );
                    }
                  }
                  
                  await provider.toggleTaskCompletion(task.id);
                  if (mounted) setState(() {});
                }
              },
              onLongPress: () async {
                if (task.isCompleted) {
                  HapticFeedback.heavyImpact();
                  await provider.toggleTaskCompletion(task.id);
                  if (mounted) setState(() {});
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted
                      ? AppTheme.neonGreen
                      : Colors.transparent,
                  border: Border.all(
                    color: task.isCompleted
                        ? AppTheme.neonGreen
                        : AppTheme.textMuted,
                    width: 2,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check_rounded,
                        size: 16, color: Colors.white)
                    : null,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _swipeBackground(bool isComplete) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isComplete
            ? AppTheme.neonGreen.withOpacity(0.2)
            : AppTheme.neonPink.withOpacity(0.2),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment:
          isComplete ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(
        isComplete ? Icons.check_circle_rounded : Icons.delete_rounded,
        color: isComplete ? AppTheme.neonGreen : AppTheme.neonPink,
        size: 28,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.rocket_launch_rounded,
              size: 64, color: AppTheme.neonPurple.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            '¡Sin tareas para hoy!',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el botón + para agregar tu primera tarea',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.textMuted),
            textAlign: TextAlign.center,
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

  String _formattedDate(DateTime date) {
    const days = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
    ];
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${days[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  Widget _buildQuoteCard(BuildContext context) {
    final now = DateTime.now();
    final quote = QuotesRepository.getDailyQuote();
    final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final hasChecked = HiveService.getHasCheckedQuoteToday(dateStr);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonCyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_quote_rounded, color: AppTheme.neonCyan),
              const SizedBox(width: 8),
              Text(
                'Frase del Día',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.neonCyan),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"$quote"',
            style: TextStyle(color: AppTheme.textPrimary, fontStyle: FontStyle.italic, fontSize: 14),
          ),
          const SizedBox(height: 16),
          if (!hasChecked)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await HiveService.setHasCheckedQuoteToday(dateStr, true);
                  // widget.provider.incrementStreakWithQuoteBonus(); // if exists
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('¡Excelente! Has ganado un bonus de racha. 🔥')),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, color: Colors.black),
                label: const Text('¿Pusiste a prueba la frase?', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonCyan,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department_rounded, color: AppTheme.neonPink, size: 20),
                const SizedBox(width: 8),
                const Text('¡Frase superada hoy!', style: TextStyle(color: AppTheme.neonPink, fontWeight: FontWeight.bold)),
              ],
            ),
        ],
      ),
    );
  }
}
