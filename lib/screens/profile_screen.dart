import 'package:flutter/material.dart';
import 'package:rutine/theme/app_theme.dart';
import 'package:rutine/providers/task_provider.dart';

class ProfileScreen extends StatefulWidget {
  final TaskProvider provider;
  const ProfileScreen({super.key, required this.provider});

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
                    ),
                    child: const Center(
                      child: Icon(Icons.person_rounded, size: 60, color: Colors.white),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isEditing = true),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.bgSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.bgDark, width: 3),
                      ),
                      child: const Icon(Icons.edit_rounded, size: 16, color: AppTheme.neonCyan),
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
                            style: const TextStyle(color: AppTheme.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Tu nombre',
                              labelStyle: const TextStyle(color: AppTheme.textSecondary),
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
                        Text(
                          widget.provider.userName,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.provider.tasks.length} tareas registradas',
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
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
              subtitle: 'Fase 6: Próximamente',
              trailing: Switch(
                value: false,
                onChanged: (v) {},
                activeColor: AppTheme.neonPink,
              ),
            ),
            _buildSettingsTile(
              icon: Icons.palette_rounded,
              iconColor: AppTheme.neonCyan,
              title: 'Tema Visual',
              subtitle: 'Neón Oscuro',
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
              subtitle: '1.0.0 (Fase 5 Completada)',
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
  }) {
    return Container(
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
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
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
    );
  }
}
