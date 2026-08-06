import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static bool isDarkMode = true;

  // === PALETA DE COLORES ===
  static Color get bgDark => isDarkMode ? const Color(0xFF0D0D14) : const Color(0xFFE0F7FA); // Fondo oscuro o Cian claro
  static Color get bgCard => isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFFFFFFF); // Tarjetas
  static Color get bgSurface => isDarkMode ? const Color(0xFF16213E) : const Color(0xFFF3E8FF); // Superficies (Morado claro)

  // Colores de acento Neón (se mantienen vibrantes en ambos modos)
  static const Color neonPurple = Color(0xFF7C3AED);
  static const Color neonCyan = Color(0xFF06B6D4);
  static const Color neonPink = Color(0xFFEC4899);
  static const Color neonGreen = Color(0xFF10B981);

  // Colores por Categoría
  static const Color catHygiene = Color(0xFF06B6D4);
  static const Color catUniversity = Color(0xFFF43F5E); // Rojo-rosado
  static const Color catWork = Color(0xFFF59E0B);
  static const Color catShopping = Color(0xFF10B981);
  static const Color catLeisure = Color(0xFFEC4899); // Será usado para Paseo
  static const Color catSports = Color(0xFFEF4444);
  static const Color catFood = Color(0xFFF97316); 
  static const Color catOcio = Color(0xFFD946EF); // Fuchsia para Ocio
  static const Color catReading = Color(0xFF3B82F6); // Blue para Leer
  static const Color catResearch = Color(0xFF6366F1); // Indigo para Investigar
  static const Color catGaming = Color(0xFF8B5CF6); // Violeta para Gaming
  static const Color catMeditation = Color(0xFF14B8A6); // Teal para Meditación
  static const Color catCustom = Color(0xFF64748B); // Gris Pizarra para Otros

  // Textos
  static Color get textPrimary => isDarkMode ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
  static Color get textSecondary => isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  static Color get textMuted => isDarkMode ? const Color(0xFF475569) : const Color(0xFF94A3B8);

  // === GRADIENTES ===
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [neonPurple, neonCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get cardGradient => LinearGradient(
    colors: [bgCard, bgSurface],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // === TEMA PRINCIPAL ===
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bgDark,
      colorScheme: ColorScheme(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primary: neonPurple,
        secondary: neonCyan,
        surface: bgCard,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        error: Colors.redAccent,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        TextTheme(
          displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textSecondary),
          labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bgCard,
        selectedItemColor: neonPurple,
        unselectedItemColor: textMuted,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: neonPurple,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: CircleBorder(),
      ),
    );
  }
}
