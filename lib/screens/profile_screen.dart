import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rutine/theme/app_theme.dart';
import 'package:rutine/providers/task_provider.dart';
import 'package:rutine/providers/theme_provider.dart';

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
                          '${widget.provider.tasks.length} tareas registradas',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
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
              subtitle: 'Guardar datos localmente',
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
}
