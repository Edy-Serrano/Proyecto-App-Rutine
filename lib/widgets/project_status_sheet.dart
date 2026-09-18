import 'package:flutter/material.dart';
import 'package:rutine/models/task_model.dart';
import 'package:rutine/providers/task_provider.dart';
import 'package:rutine/theme/app_theme.dart';
import 'package:flutter/services.dart';

class ProjectStatusSheet extends StatefulWidget {
  final Task task;
  final TaskProvider provider;

  const ProjectStatusSheet({super.key, required this.task, required this.provider});

  @override
  State<ProjectStatusSheet> createState() => _ProjectStatusSheetState();
}

class _ProjectStatusSheetState extends State<ProjectStatusSheet> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _getPlantEmoji(int completed, int total) {
    if (total == 0) return '🌱';
    final fraction = completed / total;
    if (fraction == 0) return '🫘'; // Semilla
    if (fraction <= 0.33) return '🌱'; // Brote
    if (fraction <= 0.66) return '🌿'; // Planta
    if (fraction < 1.0) return '🌳'; // Árbol
    return '🍎'; // Fruto (Completado)
  }

  void _toggleStage(int index) {
    if (widget.task.projectStagesStatus == null || widget.task.projectStages == null) return;
    
    HapticFeedback.lightImpact();
    setState(() {
      widget.task.projectStagesStatus![index] = !widget.task.projectStagesStatus![index];
      
      // Evaluar si todas las etapas están completadas
      bool allDone = widget.task.projectStagesStatus!.every((status) => status == true);
      widget.task.isCompleted = allDone;
      
      if (allDone) {
        HapticFeedback.heavyImpact();
      }
      
      // Reiniciar animación para efecto de crecimiento
      _animController.reset();
      _animController.forward();
    });
    
    widget.provider.updateTask(widget.task);
  }

  @override
  Widget build(BuildContext context) {
    final stages = widget.task.projectStages ?? [];
    final statuses = widget.task.projectStagesStatus ?? [];
    int completedCount = statuses.where((s) => s).length;
    int totalCount = stages.length;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              widget.task.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$completedCount de $totalCount etapas completadas',
              style: TextStyle(color: AppTheme.neonCyan, fontSize: 14),
            ),
            const SizedBox(height: 30),
            
            // Visual de la Planta
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.bgDark,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonCyan.withOpacity(completedCount == totalCount && totalCount > 0 ? 0.6 : 0.2),
                      blurRadius: 30,
                      spreadRadius: completedCount == totalCount && totalCount > 0 ? 10 : 0,
                    ),
                  ],
                  border: Border.all(
                    color: AppTheme.neonCyan.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _getPlantEmoji(completedCount, totalCount),
                  style: const TextStyle(fontSize: 60),
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Lista de Etapas
            if (stages.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('No hay etapas definidas. Edita la tarea para añadir etapas.',
                  style: TextStyle(color: AppTheme.textMuted),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: List.generate(stages.length, (index) {
                    bool isDone = statuses[index];
                    return ListTile(
                      onTap: () => _toggleStage(index),
                      leading: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone ? AppTheme.neonCyan : Colors.transparent,
                          border: Border.all(
                            color: isDone ? AppTheme.neonCyan : AppTheme.textMuted,
                            width: 2,
                          ),
                        ),
                        child: isDone
                            ? Icon(Icons.check, size: 18, color: AppTheme.bgDark)
                            : null,
                      ),
                      title: Text(
                        stages[index],
                        style: TextStyle(
                          color: isDone ? AppTheme.textMuted : Colors.white,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          fontWeight: isDone ? FontWeight.normal : FontWeight.w500,
                        ),
                      ),
                      trailing: isDone 
                          ? const Icon(Icons.star_rounded, color: Colors.amber, size: 20)
                          : null,
                    );
                  }),
                ),
              ),
              
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonCyan.withOpacity(0.1),
                  foregroundColor: AppTheme.neonCyan,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
