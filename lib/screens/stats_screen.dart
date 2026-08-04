import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:rutine/theme/app_theme.dart';
import 'package:rutine/models/task_model.dart';
import 'package:rutine/providers/task_provider.dart';

class StatsScreen extends StatefulWidget {
  final TaskProvider provider;
  const StatsScreen({super.key, required this.provider});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final weeklyRate = widget.provider.weeklyCompletionRate();
    final monthlyRate = widget.provider.monthlyCompletionRate();
    final streak = widget.provider.currentStreak;
    final bestStreak = widget.provider.bestStreak;
    final last7 = widget.provider.getLast7DaysStats();
    
    // Tareas completadas (para el pie chart global si se desea, o lo cambiamos a tiempo)
    final byCategory = widget.provider.completedByCategory();
    
    // TIEMPO INVERTIDO
    final timeInvested = widget.provider.timeInvestedByCategory(_selectedDate);
    final totalTime = widget.provider.totalTimeInvested(_selectedDate);
    
    // ESTADÍSTICAS FOOD
    final foodData = widget.provider.foodStats(_selectedDate);
    
    final byTaskName = widget.provider.completedByTaskName();
    final totalByTaskName = widget.provider.totalByTaskName();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Estadísticas'),
        backgroundColor: AppTheme.bgDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded, color: AppTheme.neonCyan),
            onPressed: () => setState(() => _selectedDate = DateTime.now()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === SELECTOR DE FECHA ===
            _buildDateSelector(),
            const SizedBox(height: 20),

            // === TIEMPO INVERTIDO POR CATEGORÍA (Día Seleccionado) ===
            _buildSectionTitle(context, '⏳ Tiempo invertido hoy'),
            const SizedBox(height: 8),
            Text(
              'Total: ${totalTime >= 60 ? '${totalTime ~/ 60}h ${totalTime % 60}m' : '${totalTime}m'}',
              style: const TextStyle(color: AppTheme.neonPurple, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (timeInvested.isEmpty)
              Text('No hay tiempo registrado para este día.', style: TextStyle(color: AppTheme.textMuted))
            else
              ...timeInvested.entries.map((entry) {
                return _buildTimeInvestedRow(context, entry.key, entry.value, totalTime);
              }),
            const SizedBox(height: 32),

            // === ESTADÍSTICAS DE NUTRICIÓN (FOOD) ===
            _buildSectionTitle(context, '🥗 Nutrición de Hoy'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFoodStatCard(context, 'Agua', '${foodData['water']} vasos', Icons.water_drop_rounded, AppTheme.neonCyan),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFoodStatCard(context, 'Proteínas', '${foodData['protein']}g', Icons.fitness_center_rounded, AppTheme.neonPink),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFoodStatCard(context, 'Carbs', '${foodData['carbs']}g', Icons.breakfast_dining_rounded, AppTheme.catFood),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // === TARJETAS DE RESUMEN ===
            _buildSectionTitle(context, '📈 Resumen Semanal/Mensual'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.local_fire_department_rounded,
                    iconColor: AppTheme.neonPink,
                    value: '$streak',
                    label: 'Racha actual',
                    suffix: streak == 1 ? 'día' : 'días',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.emoji_events_rounded,
                    iconColor: AppTheme.catWork,
                    value: '$bestStreak',
                    label: 'Mejor racha',
                    suffix: bestStreak == 1 ? 'día' : 'días',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.calendar_view_week_rounded,
                    iconColor: AppTheme.neonCyan,
                    value: '${(weeklyRate * 100).toInt()}%',
                    label: 'Esta semana',
                    suffix: 'completado',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.calendar_month_rounded,
                    iconColor: AppTheme.neonPurple,
                    value: '${(monthlyRate * 100).toInt()}%',
                    label: 'Este mes',
                    suffix: 'completado',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // === PROGRESO POR TAREA ESPECÍFICA ===
            _buildSectionTitle(context, '🎯 Por tarea específica'),
            const SizedBox(height: 12),
            if (totalByTaskName.isEmpty)
              Text('No hay tareas registradas', style: TextStyle(color: AppTheme.textMuted))
            else
              ...totalByTaskName.entries.map((entry) {
                final taskName = entry.key;
                final total = entry.value;
                final completed = byTaskName[taskName] ?? 0;
                return _buildTaskNameRow(context, taskName, completed, total);
              }),

            // === PIE CHART ===
            if (byCategory.isNotEmpty) ...[
              const SizedBox(height: 28),
              _buildSectionTitle(context, '🥧 Distribución de tareas'),
              const SizedBox(height: 16),
              _buildPieChart(context, byCategory),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left_rounded, color: AppTheme.textSecondary),
          onPressed: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
        ),
        Text(
          _formattedDate(_selectedDate),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
          onPressed: () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))),
        ),
      ],
    );
  }

  String _formattedDate(DateTime date) {
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    if (date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day) {
      return 'Hoy';
    }
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildTimeInvestedRow(BuildContext context, TaskCategory cat, int minutes, int totalMinutes) {
    final rate = totalMinutes == 0 ? 0.0 : minutes / totalMinutes;
    final timeStr = minutes >= 60 ? '${minutes ~/ 60}h ${minutes % 60}m' : '${minutes}m';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(cat.icon, color: cat.color, size: 16),
                  const SizedBox(width: 8),
                  Text(cat.label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary)),
                ],
              ),
              Text(timeStr, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cat.color, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rate,
              backgroundColor: AppTheme.bgSurface,
              valueColor: AlwaysStoppedAnimation<Color>(cat.color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
          ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required String suffix,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.w800,
                ),
          ),
          Text(
            suffix,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rate,
              backgroundColor: AppTheme.bgSurface,
              valueColor: AlwaysStoppedAnimation<Color>(cat.color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(
      BuildContext context, Map<TaskCategory, int> byCategory) {
    final entries = byCategory.entries.toList();
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);

    return Row(
      children: [
        SizedBox(
          height: 180,
          width: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 40,
              sections: entries.map((e) {
                final percent = (e.value / total * 100).toInt();
                return PieChartSectionData(
                  color: e.key.color,
                  value: e.value.toDouble(),
                  title: '$percent%',
                  radius: 55,
                  titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                );
              }).toList(),
            ),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: e.key.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.key.label,
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${e.value}',
                      style: TextStyle(
                          color: e.key.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildTaskNameRow(
    BuildContext context,
    String taskName,
    int completed,
    int total,
  ) {
    final double percentage = total > 0 ? (completed / total) : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: AppTheme.neonPurple, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  taskName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Text(
                '$completed / $total',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppTheme.bgSurface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.neonPurple),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
