import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rutine/theme/app_theme.dart';
import 'package:rutine/providers/task_provider.dart';
import 'package:rutine/providers/theme_provider.dart';
import 'package:rutine/services/hive_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rutine/models/task_model.dart';
import 'package:rutine/repositories/challenge_repository.dart';

class ProfileScreen extends StatefulWidget {
  final TaskProvider provider;
  final ThemeProvider themeProvider;

  const ProfileScreen({super.key, required this.provider, required this.themeProvider});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.provider.userName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveName() {
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty) {
      widget.provider.updateUserName(newName);
    } else {
      _nameController.text = widget.provider.userName;
    }
    setState(() => _isEditing = false);
  }

  String _getGamificationTitle(int streak) {
    if (streak < 3) return "🌱 Principiante";
    if (streak < 7) return "🔥 Constante";
    if (streak < 14) return "⚡ Avanzado";
    if (streak < 30) return "👑 Maestro de Rutinas";
    return "🚀 Leyenda Imparable";
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        widget.provider.updateUserImage(pickedFile.path);
        setState(() {}); // Forzar redibujo de la imagen
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppTheme.neonCyan),
                title: Text('Tomar foto', style: TextStyle(color: AppTheme.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppTheme.neonPurple),
                title: Text('Elegir de la galería', style: TextStyle(color: AppTheme.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (widget.provider.userImagePath != null)
                ListTile(
                  leading: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                  title: Text('Eliminar foto', style: TextStyle(color: AppTheme.textPrimary)),
                  onTap: () {
                    Navigator.pop(context);
                    widget.provider.updateUserImage(''); // Enviar vacío o manejar null
                    setState(() {});
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // === AVATAR Y NOMBRE ===
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonPurple.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      image: widget.provider.userImagePath != null && widget.provider.userImagePath!.isNotEmpty
                          ? DecorationImage(
                              image: FileImage(File(widget.provider.userImagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: widget.provider.userImagePath == null || widget.provider.userImagePath!.isEmpty
                        ? const Center(
                            child: Icon(Icons.person_rounded, size: 60, color: Colors.white),
                          )
                        : null,
                  ),
                  GestureDetector(
                    onTap: _showPhotoOptions,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.bgSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.bgDark, width: 3),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, size: 16, color: AppTheme.neonCyan),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // === CAMPO DE NOMBRE ===
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isEditing
                  ? Row(
                      key: const ValueKey('editing'),
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            style: TextStyle(color: AppTheme.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Tu nombre',
                              labelStyle: TextStyle(color: AppTheme.textSecondary),
                              filled: true,
                              fillColor: AppTheme.bgCard,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppTheme.neonPurple, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.check_rounded, color: Colors.white),
                            onPressed: _saveName,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      key: const ValueKey('display'),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.provider.userName,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => setState(() => _isEditing = true),
                              child: Icon(Icons.edit_rounded, color: AppTheme.textMuted, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getGamificationTitle(widget.provider.currentStreak),
                          style: const TextStyle(color: AppTheme.neonCyan, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Racha de Confort: ${HiveService.getChallengeStreak()} 🔥',
                          style: TextStyle(color: AppTheme.neonPink.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 48),

            // === AJUSTES DE LA APLICACIÓN ===
            _buildSectionTitle('Ajustes Generales'),
            const SizedBox(height: 16),
            _buildSettingsTile(
              icon: Icons.notifications_active_rounded,
              iconColor: AppTheme.neonPink,
              title: 'Notificaciones locales',
              subtitle: widget.themeProvider.notificationsEnabled ? 'Activadas' : 'Desactivadas',
              trailing: Switch(
                value: widget.themeProvider.notificationsEnabled,
                onChanged: (v) => widget.themeProvider.toggleNotifications(v),
                activeColor: AppTheme.neonPink,
              ),
            ),
            _buildSettingsTile(
              icon: Icons.palette_rounded,
              iconColor: AppTheme.neonCyan,
              title: 'Tema Visual',
              subtitle: widget.themeProvider.isDarkMode ? 'Modo Oscuro' : 'Modo Claro',
              onTap: () => widget.themeProvider.toggleTheme(),
            ),
            _buildSettingsTile(
              icon: Icons.backup_rounded,
              iconColor: AppTheme.catWork,
              title: 'Copia de seguridad',
              subtitle: 'Exportar datos cifrados',
              onTap: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Generando respaldo cifrado...')),
                );
                final file = await HiveService.exportSecureBackup();
                await Share.shareXFiles([XFile(file.path)], text: 'Respaldo de Rutine (Cifrado)');
              },
            ),
            _buildSettingsTile(
              icon: Icons.insert_chart_outlined_rounded,
              iconColor: Colors.green,
              title: 'Exportar Estadísticas',
              subtitle: 'Descargar datos en formato CSV',
              onTap: () => _showExportDialog(context),
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Acerca de'),
            const SizedBox(height: 16),
            _buildSettingsTile(
              icon: Icons.info_outline_rounded,
              iconColor: AppTheme.textMuted,
              title: 'Versión de la App',
              subtitle: '1.1.0',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.bgSurface),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
      ),
    );
  }

  Future<void> _showExportDialog(BuildContext context) async {
    final tasks = widget.provider.tasks;
    final Set<String> uniqueMonths = {};
    
    // Recopilar meses con actividad
    for (var t in tasks) {
      final history = widget.provider.getFullHistory(t);
      for (var log in history) {
        uniqueMonths.add('${log.date.year}-${log.date.month.toString().padLeft(2, '0')}');
      }
    }

    final List<DateTime> months = uniqueMonths.map((m) {
      final parts = m.split('-');
      return DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
    }).toList();

    // Ordenar de más reciente a más antiguo
    months.sort((a, b) => b.compareTo(a));

    const monthNames = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Exportar Estadísticas', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (months.isEmpty) ...[
                Text('Aún no tienes tareas con tiempo registrado.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 16),
              ] else ...[
                Text('Selecciona el mes a exportar:', style: TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 16),
                ...months.map((d) {
                  return ListTile(
                    title: Text('${monthNames[d.month - 1]} ${d.year}', style: const TextStyle(color: Colors.white)),
                    trailing: const Icon(Icons.download_rounded, color: Colors.green),
                    onTap: () {
                      Navigator.pop(ctx);
                      _generateAndShareCSV(d);
                    },
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Evita que Excel interprete textos que inician con -, +, = o @ como fórmulas
  String _sanitizeExcel(String text) {
    if (text.isEmpty) return text;
    if (text.startsWith('=') || text.startsWith('+') || text.startsWith('-') || text.startsWith('@')) {
      return ' ' + text;
    }
    return text;
  }

  Future<void> _generateAndShareCSV(DateTime date) async {
    try {
      final tasks = widget.provider.tasks.toList();
      tasks.sort((a, b) => a.date.compareTo(b.date)); // Ordenar tareas por fecha (más antiguas primero)
      
      // Añadimos el BOM (\uFEFF) para que Excel reconozca correctamente el UTF-8 (Tildes, ñ, Emojis)
      String tasksCsv = "\uFEFFTarea,Descripcion,Categoria,Estado,Motivo_Cancelacion,Minutos_Mes,Notas_Tiempo,Fecha_Creacion\n";

      for (var t in tasks) {
        int minutes = 0;
        List<String> notesList = [];
        final history = widget.provider.getFullHistory(t);
        for (var log in history) {
          if (log.date.month == date.month && log.date.year == date.year) {
            minutes += log.minutes;
            if (log.note.isNotEmpty) notesList.add(log.note.replaceAll('"', '""'));
          }
        }
        
        if ((t.date.month == date.month && t.date.year == date.year) || minutes > 0) {
          String status = t.isCancelled ? 'Cancelada' : (t.isCompleted ? 'Completada' : 'Pendiente');
          String desc = _sanitizeExcel((t.description ?? '').replaceAll('"', '""'));
          String title = _sanitizeExcel(t.title.replaceAll('"', '""'));
          String cancelReason = _sanitizeExcel((t.cancelReason ?? '').replaceAll('"', '""'));
          String allNotes = _sanitizeExcel(notesList.join(" | "));
          
          tasksCsv += '"$title","$desc","${t.category.label}","$status","$cancelReason",$minutes,"$allNotes","${t.date.toIso8601String()}"\n';
        }
      }

      // Añadimos el BOM (\uFEFF) para que Excel reconozca correctamente el UTF-8
      String challengesCsv = "\uFEFFFecha,Nivel,Reto,Resultado,Comentario\n";
      int daysInMonth = DateTime(date.year, date.month + 1, 0).day;
      final now = DateTime.now();
      
      int legacyCount = 0;

      // Ordenar retos por fecha (más antiguas primero)
      for (int i = 1; i <= daysInMonth; i++) {
        final day = DateTime(date.year, date.month, i);
        if (day.isAfter(now)) break;
        
        final dateStr = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
        
        if (HiveService.getHasCompletedChallengeToday(dateStr)) {
           bool? success = HiveService.getChallengeSuccessToday(dateStr);
           
           // Corrección para los 3 primeros registros legacy sin 'success' definido
           if (success == null) {
             legacyCount++;
             // Como el bucle va de más antiguo a más reciente:
             // legacyCount == 1 y 2 son los más antiguos (los que cumplió)
             // legacyCount == 3 es el más reciente (el que no realizó)
             if (legacyCount <= 2) {
               success = true;
               HiveService.setChallengeSuccessToday(dateStr, true); // Guardar para el futuro
             } else {
               success = false;
               HiveService.setChallengeSuccessToday(dateStr, false);
             }
           }
           
           final note = HiveService.getChallengeNoteToday(dateStr) ?? "";
           
           final int? pastChallengeId = HiveService.getChallengeIdToday(dateStr);
           Challenge challenge;
           if (pastChallengeId != null) {
             challenge = ChallengeRepository.allChallenges.firstWhere((c) => c.id == pastChallengeId, orElse: () => ChallengeRepository.allChallenges.first);
           } else {
             // Fallback para días pasados antes de implementar el guardado de IDs
             final completedIds = HiveService.getCompletedChallengeIds();
             challenge = ChallengeRepository.getDailyChallenge(day, completedIds);
           }
           
           String resultStr = success == true ? 'Lo cumplí' : (success == false ? 'No me atreví' : 'Sin respuesta');
           String noteStr = _sanitizeExcel(note.replaceAll('"', '""'));
           String textStr = _sanitizeExcel(challenge.text.replaceAll('"', '""'));
           
           challengesCsv += '"$dateStr",${challenge.level},"$textStr","$resultStr","$noteStr"\n';
        }
      }

      final dir = await Directory.systemTemp.createTemp();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      final tasksFile = File('${dir.path}/tareas_y_eventos_${date.month}_${date.year}_$timestamp.csv');
      await tasksFile.writeAsString(tasksCsv);
      
      final challengesFile = File('${dir.path}/retos_diarios_${date.month}_${date.year}_$timestamp.csv');
      await challengesFile.writeAsString(challengesCsv);
      
      await Share.shareXFiles([XFile(tasksFile.path), XFile(challengesFile.path)], text: 'Estadísticas Integrales de Rutine - Mes ${date.month}/${date.year}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar: $e')),
      );
    }
  }
}
