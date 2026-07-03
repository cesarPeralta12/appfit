import 'package:flutter/material.dart';

/// Paleta de colores central de la app.
class AppColors {
  static const primary = Color(0xFF7B2CBF);
  static const primaryLight = Color(0xFF9D4EDD);
  static const primaryDark = Color(0xFF5A189A);

  static const ink = Color(0xFF14181F);
  static const slate = Color(0xFF4B5563);
  static const background = Color(0xFFF5F6F8);
  static const surface = Colors.white;

  static const success = Color(0xFF16A34A);
  static const info = Color(0xFF2563EB);
  static const violet = Color(0xFF7C3AED);
  static const danger = Color(0xFFDC2626);
  static const warning = Color(0xFFF59E0B);

  // Categorias de edad
  static const ageChild = Color(0xFF3B82F6);
  static const ageYouth = Color(0xFF7C3AED);
  static const ageAdult = Color(0xFF14181F);

  // Niveles de entrenamiento
  static const levelBeginner = success;
  static const levelIntermediate = info;
  static const levelAdvanced = violet;

  static const gradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static const primary = AppColors.primary;
  static const dark = AppColors.ink;

  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.ink,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.ink,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      elevation: 0,
      titleTextStyle: TextStyle(color: AppColors.ink, fontSize: 18, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: AppColors.ink),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      labelStyle: const TextStyle(fontSize: 12),
      side: BorderSide.none,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AppColors.primary.withValues(alpha: 0.15),
      labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
    ),
  );
}
