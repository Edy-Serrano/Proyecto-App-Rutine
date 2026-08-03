import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:rutine/theme/app_theme.dart';
import 'package:rutine/models/task_model.dart';
import 'package:rutine/providers/task_provider.dart';

class StatsScreen extends StatelessWidget {
  final TaskProvider provider;
  const StatsScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final weeklyRate = provider.weeklyCompletionRate();
    final monthlyRate = provider.monthlyCompletionRate();
    final streak = provider.currentStreak;
    final bestStreak = provider.bestStreak;
    final last7 = provider.getLast7DaysStats();
    final byCategory = provider.completedByCategory();
    final totalByCategory = provider.totalByCategory();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Estadísticas'),
        backgroundColor: AppTheme.bgDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === TARJETAS DE RESUMEN ===
            _buildSectionTitle(context, '📈 Resumen'),
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

            // === GRÁFICO DE BARRAS (últimos 7 días) ===
            _buildSectionTitle(context, '📊 Últimos 7 días'),
            const SizedBox(height: 16),
            _buildBarChart(context, last7),
            const SizedBox(height: 28),

            // === MENSAJE MOTIVACIONAL ===
            _buildMotivationalCard(context, streak, weeklyRate),
            const SizedBox(height: 28),

            // === PROGRESO POR CATEGORÍA ===
            _buildSectionTitle(context, '🏷️ Por categoría'),
            const SizedBox(height: 12),
            ...TaskCategory.values.map((cat) {
              final completed = byCategory[cat] ?? 0;
              final total = totalByCategory[cat] ?? 0;
              if (total == 0) return const SizedBox.shrink();
              return _buildCategoryRow(context, cat, completed, total);
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

  Widget _buildBarChart(BuildContext context, List<DailyStats> stats) {
    const dayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.neonPurple.withOpacity(0.15)),
      ),
      child: BarChart(
        BarChartData(
          maxY: 1.0,
          minY: 0,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppTheme.bgSurface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final s = stats[groupIndex];
                return BarTooltipItem(
                  '${(s.completionRate * 100).toInt()}%\n${s.completedTasks}/${s.totalTasks}',
                  const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= stats.length) return const SizedBox();
                  final weekday = stats[idx].date.weekday - 1;
                  final isToday = _isSameDay(stats[idx].date, DateTime.now());
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      dayLabels[weekday],
                      style: TextStyle(
                        color: isToday
                            ? AppTheme.neonPurple
                            : AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  if (value == 0 || value == 0.5 || value == 1.0) {
                    return Text(
                      '${(value * 100).toInt()}%',
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 9),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppTheme.textMuted.withOpacity(0.1),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(stats.length, (i) {
            final s = stats[i];
            final isToday = _isSameDay(s.date, DateTime.now());
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: s.totalTasks == 0 ? 0 : s.completionRate,
                  width: 22,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8)),
                  gradient: LinearGradient(
                    colors: s.completionRate == 1.0
                        ? [AppTheme.neonGreen, AppTheme.neonCyan]
                        : isToday
                            ? [AppTheme.neonPurple, AppTheme.neonCyan]
                            : [
                                AppTheme.neonPurple.withOpacity(0.6),
                                AppTheme.neonPurple.withOpacity(0.3)
                              ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 1,
                    color: AppTheme.bgSurface,
                  ),
                ),
              ],
            );
          }),
        ),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      ),
    );
  }

  Widget _buildMotivationalCard(
      BuildContext context, int streak, double weeklyRate) {
    String message;
    IconData icon;
    Color color;

    if (streak >= 7) {
      message = '¡Increíble! Llevas $streak días seguidos completando tus tareas. ¡Eres imparable! 🔥';
      icon = Icons.local_fire_department_rounded;
      color = AppTheme.neonPink;
    } else if (streak >= 3) {
      message = '¡Vas muy bien! $streak días en racha. ¡Mantén el ritmo! 💪';
      icon = Icons.trending_up_rounded;
      color = AppTheme.neonCyan;
    } else if (weeklyRate >= 0.7) {
      message = 'Esta semana has completado el ${(weeklyRate * 100).toInt()}% de tus tareas. ¡Excelente rendimiento! ⭐';
      icon = Icons.star_rounded;
      color = AppTheme.catWork;
    } else if (weeklyRate > 0) {
      message = 'Sigue adelante, cada tarea completada cuenta. ¡Tú puedes! 🚀';
      icon = Icons.rocket_launch_rounded;
      color = AppTheme.neonPurple;
    } else {
      message = '¡Bienvenido! Empieza a registrar tus tareas para ver tus estadísticas aquí. ✨';
      icon = Icons.lightbulb_rounded;
      color = AppTheme.neonCyan;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), AppTheme.bgCard],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(
      BuildContext context, TaskCategory cat, int completed, int total) {
    final rate = total == 0 ? 0.0 : completed / total;
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
                  Text(cat.label,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppTheme.textPrimary)),
                ],
              ),
              Text(
                '$completed / $total',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cat.color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
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
                        style: const TextStyle(
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
}
