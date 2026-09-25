import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rutine/theme/app_theme.dart';
import 'package:rutine/screens/main_navigation.dart';
import 'package:rutine/services/hive_service.dart';
import 'package:rutine/services/notification_service.dart';
import 'package:rutine/providers/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuramos la barra de estado del teléfono para que sea transparente
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.bgCard,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const RutineApp());
}

class RutineApp extends StatefulWidget {
  const RutineApp({super.key});

  @override
  State<RutineApp> createState() => _RutineAppState();
}

class _RutineAppState extends State<RutineApp> {
  ThemeProvider? _themeProvider;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Inicializamos la base de datos local
    await HiveService.init();

    // Inicializamos las notificaciones locales
    await NotificationService.init();
    await NotificationService.requestPermissions();

    if (mounted) {
      setState(() {
        _themeProvider = ThemeProvider();
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized || _themeProvider == null) {
      return MaterialApp(
        title: 'Rutine',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.themeData,
        home: Scaffold(
          backgroundColor: AppTheme.bgDark,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, size: 80, color: AppTheme.neonPurple),
                const SizedBox(height: 32),
                const CircularProgressIndicator(color: AppTheme.neonCyan),
              ],
            ),
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _themeProvider!,
      builder: (context, _) {
        // Actualizar la barra de estado según el tema activo
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: AppTheme.isDarkMode ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: AppTheme.bgCard,
            systemNavigationBarIconBrightness: AppTheme.isDarkMode ? Brightness.light : Brightness.dark,
          ),
        );

        return MaterialApp(
          title: 'Rutine',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.themeData,
          home: MainNavigation(themeProvider: _themeProvider!),
        );
      },
    );
  }
}


