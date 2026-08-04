import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rutine/theme/app_theme.dart';
import 'package:rutine/screens/main_navigation.dart';
import 'package:rutine/services/hive_service.dart';
import 'package:rutine/services/notification_service.dart';
import 'package:rutine/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos la base de datos local
  await HiveService.init();

  // Inicializamos las notificaciones locales
  await NotificationService.init();
  await NotificationService.requestPermissions();

  // Configuramos la barra de estado del teléfono para que sea transparente
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.bgCard,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  final themeProvider = ThemeProvider();
  runApp(RutineApp(themeProvider: themeProvider));
}

class RutineApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  const RutineApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeProvider,
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
          home: MainNavigation(themeProvider: themeProvider),
        );
      },
    );
  }
}
