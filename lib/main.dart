import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rutine/theme/app_theme.dart';
import 'package:rutine/screens/main_navigation.dart';
import 'package:rutine/services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos la base de datos local
  await HiveService.init();

  // Configuramos la barra de estado del teléfono para que sea transparente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.bgCard,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const RutineApp());
}

class RutineApp extends StatelessWidget {
  const RutineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rutine',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigation(),
    );
  }
}
