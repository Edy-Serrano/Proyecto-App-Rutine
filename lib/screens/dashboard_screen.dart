import 'package:flutter/material.dart';
import 'package:rutine/theme/app_theme.dart';
import 'package:rutine/models/task_model.dart';
import 'package:rutine/providers/task_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/services.dart';
import 'package:rutine/screens/add_task_sheet.dart';
import 'package:rutine/repositories/challenge_repository.dart';
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
            expandedHeight: 180,
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
                padding: const EdgeInsets.fromLTRB(24, 85, 24, 8),
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

                  // === RETO DEL DÍA ===
                  _buildChallengeCard(context),

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
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await provider.toggleTask(task.id);
          return false;
        } else {
          return await _handleSwipeLeft(context, task, provider);
        }
      },
      child: GestureDetector(
        onTap: () => _showTaskDetails(context, task, provider),
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
                : task.isCancelled
                    ? AppTheme.bgCard.withOpacity(0.5)
                    : AppTheme.bgCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: task.isCompleted
                  ? AppTheme.neonGreen.withOpacity(0.3)
                  : task.isCancelled
                      ? AppTheme.neonPink.withOpacity(0.3)
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
                              (task.isCompleted || task.isCancelled) ? TextDecoration.lineThrough : null,
                          color: task.isCompleted
                              ? AppTheme.textMuted
                              : task.isCancelled
                                  ? AppTheme.neonPink.withOpacity(0.7)
                                  : AppTheme.textPrimary,
                        ),
                  ),
                  if (task.time != null || task.isPostponed) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (task.time != null) ...[
                          Text(
                            '${task.time!.hour.toString().padLeft(2, '0')}:${task.time!.minute.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: task.category.color,
                                  fontSize: 12,
                                ),
                          ),
                          if (task.isPostponed) const SizedBox(width: 8),
                        ],
                        if (task.isPostponed)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.orange.withOpacity(0.4)),
                            ),
                            child: const Text('Continúa →', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
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
                    await provider.completeTask(task.id, minutes: minutes, note: note);
                  }
                  if (mounted) setState(() {});
                }
              },
              onLongPress: () async {
                if (task.isCompleted) {
                  HapticFeedback.heavyImpact();
                  await provider.toggleTask(task.id);
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

  Future<bool> _handleSwipeLeft(BuildContext context, Task task, TaskProvider provider) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Opciones de tarea', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textPrimary)),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.cancel_rounded, color: Colors.orange),
                title: const Text('Cancelar Tarea', style: TextStyle(color: Colors.white, fontSize: 16)),
                subtitle: Text('Requiere un motivo. Contará como fallada.', style: TextStyle(color: AppTheme.textMuted)),
                onTap: () => Navigator.pop(ctx, 'cancel_task'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: AppTheme.bgSurface,
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.delete_forever_rounded, color: AppTheme.neonPink),
                title: const Text('Eliminar Permanentemente', style: TextStyle(color: AppTheme.neonPink, fontSize: 16)),
                subtitle: Text('Desaparecerá de tu lista y estadísticas.', style: TextStyle(color: AppTheme.textMuted)),
                onTap: () => Navigator.pop(ctx, 'delete_task'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: AppTheme.bgSurface,
              ),
            ],
          ),
        ),
      ),
    );

    if (result == 'cancel_task') {
      final reasonController = TextEditingController();
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.bgCard,
          title: const Text('Motivo de Cancelación', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: reasonController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Ej. Llovió, no tuve tiempo...',
              hintStyle: TextStyle(color: AppTheme.textMuted),
              filled: true,
              fillColor: AppTheme.bgSurface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Atrás', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
            ),
          ],
        )
      );

      if (proceed == true) {
        await provider.cancelTask(task.id, reasonController.text.trim());
        return true;
      }
      return false;
    } else if (result == 'delete_task') {
      return await _confirmDelete(context, task, provider);
    }
    return false;
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
  void _showTaskDetails(BuildContext context, Task task, TaskProvider provider) {
    final fullHistory = provider.getFullHistory(task);
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
                  final hourStr = '${log.date.hour.toString().padLeft(2, '0')}:${log.date.minute.toString().padLeft(2, '0')}';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '$dayStr a las $hourStr: $timeStr - "${log.note.isNotEmpty ? log.note : 'Sin nota'}"',
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

  Widget _buildChallengeCard(BuildContext context) {
    final now = DateTime.now();
    final dayOfYear = int.parse("${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}");
    final challenge = ChallengeRepository.getDailyChallenge(dayOfYear);
    final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final hasCompleted = HiveService.getHasCompletedChallengeToday(dateStr);
    final streak = HiveService.getChallengeStreak();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: AppTheme.neonPurple),
                  const SizedBox(width: 8),
                  Text(
                    'Reto Diario',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.neonPurple),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.bgSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Nivel ${challenge.level}',
                  style: TextStyle(
                    color: challenge.level == 1 ? AppTheme.neonCyan :
                           challenge.level == 2 ? Colors.green :
                           challenge.level == 3 ? Colors.orange :
                           AppTheme.neonPink,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            challenge.text,
            style: TextStyle(color: AppTheme.textPrimary, fontStyle: FontStyle.italic, fontSize: 15),
          ),
          const SizedBox(height: 16),
          if (!hasCompleted)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await HiveService.setHasCompletedChallengeToday(dateStr, true);
                      await HiveService.setChallengeStreak(0); // Reiniciar racha
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No pasa nada, ¡mañana será otro día para intentarlo! 💪')),
                      );
                    },
                    icon: Icon(Icons.close_rounded, color: AppTheme.textMuted, size: 18),
                    label: Text('No me atreví', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.bgSurface),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await HiveService.setHasCompletedChallengeToday(dateStr, true);
                      await HiveService.setChallengeStreak(streak + 1);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('¡Increíble! Acabas de aumentar tu racha de retos a ${streak + 1} 🔥')),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                    label: const Text('¡Lo cumplí!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department_rounded, color: AppTheme.neonPurple, size: 20),
                const SizedBox(width: 8),
                Text('¡Reto marcado hoy! Racha actual: $streak', style: const TextStyle(color: AppTheme.neonPurple, fontWeight: FontWeight.bold)),
              ],
            ),
        ],
      ),
    );
  }
}
