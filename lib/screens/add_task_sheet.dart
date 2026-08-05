import 'package:flutter/material.dart';
import 'package:rutine/theme/app_theme.dart';
import 'package:rutine/models/task_model.dart';
import 'package:rutine/providers/task_provider.dart';
import 'package:rutine/widgets/time_log_dialog.dart';

class AddTaskSheet extends StatefulWidget {
  final TaskProvider provider;
  final DateTime? initialDate;
  final Task? taskToEdit;

  const AddTaskSheet({super.key, required this.provider, this.initialDate, this.taskToEdit});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  TaskCategory _selectedCategory = TaskCategory.hygiene;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  bool _isRecurring = false;
  DateTime? _recurringEndDate;
  final Set<int> _recurringDays = {}; // 1=Lun ... 7=Dom
  final _notifController = TextEditingController();

  // Nutrición
  int _waterGlasses = 0;
  int _proteinGrams = 0;
  int _carbsGrams = 0;

  static const List<String> _dayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      final t = widget.taskToEdit!;
      _titleController.text = t.title;
      _descController.text = t.description ?? '';
      _selectedCategory = t.category;
      _selectedDate = t.date;
      _selectedTime = t.time;
      _isRecurring = t.isRecurring;
      _recurringEndDate = t.recurringEndDate;
      _recurringDays.addAll(t.recurringDays);
      if (t.notificationMinutes != null) {
        _notifController.text = t.notificationMinutes.toString();
      }
      if (t.foodMetadata != null) {
        _waterGlasses = t.foodMetadata!['water'] as int? ?? 0;
        _proteinGrams = t.foodMetadata!['protein'] as int? ?? 0;
        _carbsGrams = t.foodMetadata!['carbs'] as int? ?? 0;
      }
    } else if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _notifController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('El título no puede estar vacío'),
          backgroundColor: AppTheme.neonPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (_isRecurring && _recurringEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes seleccionar una fecha de "Repetir hasta"'),
          backgroundColor: AppTheme.neonPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (_isRecurring && _recurringDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes seleccionar al menos un día para repetir'),
          backgroundColor: AppTheme.neonPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    int? notifMins = int.tryParse(_notifController.text.trim());

    if (widget.taskToEdit != null) {
      final updated = widget.taskToEdit!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        category: _selectedCategory,
        date: _selectedDate,
        time: _selectedTime,
        isRecurring: _isRecurring,
        recurringDays: _isRecurring ? _recurringDays.toList() : [],
        notificationMinutes: notifMins,
        foodMetadata: _selectedCategory == TaskCategory.food ? {
          'water': _waterGlasses,
          'protein': _proteinGrams,
          'carbs': _carbsGrams,
        } : null,
      );
      
      if (updated.recurringGroupId != null) {
        showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.bgCard,
            title: const Text('Actualizar Tarea Recurrente', style: TextStyle(color: Colors.white)),
            content: Text('¿Deseas actualizar solo esta tarea, o esta y todas las futuras de la misma rutina?', style: TextStyle(color: AppTheme.textSecondary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'single'),
                child: Text('Solo esta', style: TextStyle(color: AppTheme.neonCyan)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'future'),
                child: Text('Esta y futuras', style: TextStyle(color: AppTheme.neonPurple)),
              ),
            ],
          ),
        ).then((choice) {
          if (choice == 'single') {
            widget.provider.updateTask(updated);
          } else if (choice == 'future') {
            widget.provider.updateRecurringFutureTasks(updated);
          }
          Navigator.pop(context);
        });
        return; // wait for dialog
      } else {
        widget.provider.updateTask(updated);
      }
    } else {
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        category: _selectedCategory,
        date: _selectedDate,
        time: _selectedTime,
        isRecurring: _isRecurring,
        recurringDays: _isRecurring ? _recurringDays.toList() : [],
        recurringEndDate: _isRecurring ? _recurringEndDate : null,
        notificationMinutes: notifMins,
        foodMetadata: _selectedCategory == TaskCategory.food ? {
          'water': _waterGlasses,
          'protein': _proteinGrams,
          'carbs': _carbsGrams,
        } : null,
      );
      widget.provider.addTask(task);
    }
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppTheme.neonPurple,
            onPrimary: Colors.white,
            surface: AppTheme.bgCard,
            onSurface: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickRecurringEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _recurringEndDate ?? _selectedDate.add(const Duration(days: 7)),
      firstDate: _selectedDate,
      lastDate: _selectedDate.add(const Duration(days: 365 * 5)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppTheme.neonPurple,
            onPrimary: Colors.white,
            surface: AppTheme.bgCard,
            onSurface: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _recurringEndDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppTheme.neonPurple,
            onPrimary: Colors.white,
            surface: AppTheme.bgCard,
            onSurface: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Título del modal
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.primaryGradient.createShader(bounds),
              child: Text(
                widget.taskToEdit == null ? 'Nueva Tarea' : 'Editar Tarea',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(height: 24),

            // === CATEGORÍAS ===
            Text('Categoría',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: AppTheme.textSecondary)),
            const SizedBox(height: 10),
            _buildCategorySelector(),
            const SizedBox(height: 20),

            // === TÍTULO ===
            _buildTextField(
              controller: _titleController,
              label: 'Título de la tarea',
              icon: Icons.edit_rounded,
            ),
            const SizedBox(height: 14),

            // === DESCRIPCIÓN ===
            _buildTextField(
              controller: _descController,
              label: 'Descripción (opcional)',
              icon: Icons.notes_rounded,
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            // === FECHA Y HORA ===
            Text('Fecha y hora',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: AppTheme.textSecondary)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildChip(
                  icon: Icons.calendar_today_rounded,
                  label: _formatDate(_selectedDate),
                  color: AppTheme.neonPurple,
                  onTap: _pickDate,
                )),
                const SizedBox(width: 10),
                Expanded(child: _buildChip(
                  icon: Icons.schedule_rounded,
                  label: _selectedTime == null
                      ? 'Sin hora'
                      : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                  color: AppTheme.neonCyan,
                  onTap: _pickTime,
                )),
              ],
            ),
            const SizedBox(height: 20),

            // === RECURRENTE ===
            _buildRecurringSection(),
            const SizedBox(height: 20),

            // === RECORDATORIO ===
            _buildTextField(
              controller: _notifController,
              label: 'Recordatorio (minutos antes)',
              icon: Icons.notifications_active_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 28),

            // === SECCIÓN FOOD ===
            if (_selectedCategory == TaskCategory.food) ...[
              _buildFoodSection(),
              const SizedBox(height: 28),
            ],

            // === BOTÓN GUARDAR ===
            SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonPurple.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    widget.taskToEdit == null ? '✅  Crear Tarea' : '✅  Guardar Cambios',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
            ),
            if (widget.taskToEdit != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: TextButton.icon(
                  onPressed: _postponeTask,
                  icon: const Icon(Icons.next_plan_rounded, color: AppTheme.neonCyan),
                  label: const Text('Posponer a otro día', style: TextStyle(color: AppTheme.neonCyan, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.neonCyan.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: TaskCategory.values.map((cat) {
          final isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? cat.color.withOpacity(0.2)
                    : AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? cat.color : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat.icon,
                      color: isSelected ? cat.color : AppTheme.textMuted,
                      size: 22),
                  const SizedBox(height: 4),
                  Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? cat.color : AppTheme.textMuted,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.textSecondary),
        prefixIcon: Icon(icon, color: AppTheme.neonPurple, size: 20),
        filled: true,
        fillColor: AppTheme.bgSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.neonPurple, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Flexible(
              child: Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurringSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tarea Recurrente',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: AppTheme.textSecondary)),
                Text('Se repetirá en los días elegidos',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
            Switch(
              value: _isRecurring,
              onChanged: (v) => setState(() => _isRecurring = v),
              activeColor: AppTheme.neonPurple,
              activeTrackColor: AppTheme.neonPurple.withOpacity(0.3),
              inactiveTrackColor: AppTheme.bgSurface,
              inactiveThumbColor: AppTheme.textMuted,
            ),
          ],
        ),
        if (_isRecurring) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final day = i + 1;
              final isSelected = _recurringDays.contains(day);
              return GestureDetector(
                onTap: () => setState(() {
                  if (isSelected) {
                    _recurringDays.remove(day);
                  } else {
                    _recurringDays.add(day);
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppTheme.neonPurple
                        : AppTheme.bgSurface,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.neonPurple
                          : AppTheme.textMuted.withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _dayLabels[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),
              );

            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Repetir hasta: ', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: _pickRecurringEndDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _recurringEndDate == null ? AppTheme.neonPink.withOpacity(0.5) : AppTheme.neonPurple.withOpacity(0.5)),
                    ),
                    child: Text(
                      _recurringEndDate == null ? 'Seleccionar fecha (Obligatorio)' : _formatDate(_recurringEndDate!),
                      style: TextStyle(color: _recurringEndDate == null ? AppTheme.neonPink : AppTheme.neonCyan, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Información Nutricional',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.catFood)),
        const SizedBox(height: 12),
        _buildCounter('Vasos de Agua', _waterGlasses, (v) => setState(() => _waterGlasses = v)),
        const SizedBox(height: 12),
        _buildCounter('Proteínas (g)', _proteinGrams, (v) => setState(() => _proteinGrams = v), step: 5),
        const SizedBox(height: 12),
        _buildCounter('Carbohidratos (g)', _carbsGrams, (v) => setState(() => _carbsGrams = v), step: 5),
      ],
    );
  }

  Widget _buildCounter(String label, int value, ValueChanged<int> onChanged, {int step = 1}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle_outline, color: AppTheme.textMuted),
              onPressed: value > 0 ? () => onChanged(value - step < 0 ? 0 : value - step) : null,
            ),
            SizedBox(
              width: 40,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.neonPurple, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: AppTheme.textMuted),
              onPressed: () => onChanged(value + step),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _postponeTask() async {
    final DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate.add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.neonCyan,
              onPrimary: Colors.black,
              surface: AppTheme.bgCard,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (newDate != null && mounted) {
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => const TimeLogDialog(title: 'Tarea Postergada'),
      );

      if (result != null) {
        final minutes = result['minutes'] as int;
        final note = result['note'] as String;
        
        // Creamos una plantilla con los datos del formulario (por si el usuario cambió el título, etc.)
        final updatedTemplate = widget.taskToEdit!.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
          category: _selectedCategory,
          time: _selectedTime,
          notificationMinutes: int.tryParse(_notifController.text.trim()),
        );
        
        await widget.provider.postponeTask(
          updatedTemplate, 
          newDate, 
          minutes: minutes, 
          note: note,
        );
        
        if (mounted) {
          Navigator.pop(context);
        }
      }
    }
  }
}
