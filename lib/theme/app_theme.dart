import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ThemePhase { morning, afternoon, evening, night }

class AppTheme {
  static bool isDarkMode = true;
  static bool useCircadian = true;
  static ThemePhase currentPhase = ThemePhase.morning;

  static void updateCircadianPhase() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      currentPhase = ThemePhase.morning;
      isDarkMode = false;
    } else if (hour >= 12 && hour < 18) {
      currentPhase = ThemePhase.afternoon;
      isDarkMode = false;
    } else if (hour >= 18 && hour < 21) {
      currentPhase = ThemePhase.evening;
      isDarkMode = true; // El atardecer ya es modo oscuro suave
    } else {
      currentPhase = ThemePhase.night;
      isDarkMode = true;
    }
  }

  // === PALETA DE COLORES DINÁMICA ===
  static Color get bgDark {
    if (!useCircadian) return isDarkMode ? const Color(0xFF0D0D14) : const Color(0xFFE0F7FA);
    switch (currentPhase) {
      case ThemePhase.morning: return const Color(0xFFE0F7FA); // Cian claro brillante
      case ThemePhase.afternoon: return const Color(0xFFF1F5F9); // Neutro productivo
      case ThemePhase.evening: return const Color(0xFF2C1810); // Ámbar oscuro (Sunset)
      case ThemePhase.night: return const Color(0xFF0A0A0A); // Negro puro zen
    }
  }

  static Color get bgCard {
    if (!useCircadian) return isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFFFFFFF);
    switch (currentPhase) {
      case ThemePhase.morning: return const Color(0xFFFFFFFF);
      case ThemePhase.afternoon: return const Color(0xFFFFFFFF);
      case ThemePhase.evening: return const Color(0xFF3E2723); // Marrón cálido
      case ThemePhase.night: return const Color(0xFF121212); // Gris muy oscuro
    }
  }

  static Color get bgSurface {
    if (!useCircadian) return isDarkMode ? const Color(0xFF16213E) : const Color(0xFFF3E8FF);
    switch (currentPhase) {
      case ThemePhase.morning: return const Color(0xFFB2EBF2);
      case ThemePhase.afternoon: return const Color(0xFFE2E8F0);
      case ThemePhase.evening: return const Color(0xFF4E342E);
      case ThemePhase.night: return const Color(0xFF1C1C1C);
    }
  }

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
  static Color get textPrimary {
    if (!useCircadian) return isDarkMode ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    switch (currentPhase) {
      case ThemePhase.morning: return const Color(0xFF0F172A);
      case ThemePhase.afternoon: return const Color(0xFF1E293B);
      case ThemePhase.evening: return const Color(0xFFFDE68A); // Amarillo suave
      case ThemePhase.night: return const Color(0xFFCBD5E1); // Gris azulado claro
    }
  }

  static Color get textSecondary {
    if (!useCircadian) return isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    switch (currentPhase) {
      case ThemePhase.morning: return const Color(0xFF475569);
      case ThemePhase.afternoon: return const Color(0xFF475569);
      case ThemePhase.evening: return const Color(0xFFD97706); // Naranja suave
      case ThemePhase.night: return const Color(0xFF64748B); // Gris más oscuro
    }
  }

  static Color get textMuted {
    if (!useCircadian) return isDarkMode ? const Color(0xFF475569) : const Color(0xFF94A3B8);
    switch (currentPhase) {
      case ThemePhase.morning: return const Color(0xFF94A3B8);
      case ThemePhase.afternoon: return const Color(0xFF94A3B8);
      case ThemePhase.evening: return const Color(0xFF92400E); // Marrón naranja tenue
      case ThemePhase.night: return const Color(0xFF334155); // Gris muy oscuro
    }
  }

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
