import 'package:flutter/material.dart';
import 'package:rutine/theme/app_theme.dart';

class TimeLogDialog extends StatefulWidget {
  final String title;

  const TimeLogDialog({Key? key, required this.title}) : super(key: key);

  @override
  State<TimeLogDialog> createState() => _TimeLogDialogState();
}

class _TimeLogDialogState extends State<TimeLogDialog> {
  int _hours = 0;
  int _minutes = 0;
  final TextEditingController _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        widget.title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textPrimary),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "¿Cuánto tiempo invertiste hoy?",
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNumberPicker(
                  label: "Horas",
                  value: _hours,
                  max: 23,
                  onChanged: (val) => setState(() => _hours = val),
                ),
                Text(":", style: TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                _buildNumberPicker(
                  label: "Min",
                  value: _minutes,
                  max: 59,
                  onChanged: (val) => setState(() => _minutes = val),
                  step: 5,
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _noteController,
              style: TextStyle(color: AppTheme.textPrimary),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: '¿Algún avance o nota? (Opcional)',
                hintStyle: TextStyle(color: AppTheme.textMuted),
                filled: true,
                fillColor: AppTheme.bgSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text('Omitir', style: TextStyle(color: AppTheme.textMuted)),
        ),
        ElevatedButton(
          onPressed: () {
            final totalMinutes = (_hours * 60) + _minutes;
            Navigator.pop(context, {
              'minutes': totalMinutes,
              'note': _noteController.text.trim(),
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.neonPurple,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildNumberPicker({
    required String label,
    required int value,
    required int max,
    required ValueChanged<int> onChanged,
    int step = 1,
  }) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.remove, color: AppTheme.textPrimary, size: 18),
                onPressed: () {
                  if (value - step >= 0) onChanged(value - step);
                },
              ),
              Text(
                value.toString().padLeft(2, '0'),
                style: const TextStyle(color: AppTheme.neonCyan, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.add, color: AppTheme.textPrimary, size: 18),
                onPressed: () {
                  if (value + step <= max) onChanged(value + step);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
