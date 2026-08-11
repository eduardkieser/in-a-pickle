import 'package:flutter/material.dart';

class AppColors {
  static const ocean = Color(0xFF0F3B52);
  static const sand = Color(0xFFF6F1E7);
  static const pickle = Color(0xFF3E7C4F);
  static const coral = Color(0xFFC2544A);
  static const card = Colors.white;
  static const onPickle = Colors.white;
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.pickle,
      primary: AppColors.pickle,
      onPrimary: AppColors.onPickle,
      secondary: AppColors.ocean,
      surface: AppColors.sand,
    ),
    scaffoldBackgroundColor: AppColors.sand,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.sand,
      foregroundColor: AppColors.ocean,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.ocean,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        color: AppColors.ocean,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      titleLarge: TextStyle(
        color: AppColors.ocean,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColors.ocean,
        fontSize: 20,
        height: 1.4,
      ),
      bodyMedium: TextStyle(
        color: AppColors.ocean,
        fontSize: 18,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        color: AppColors.ocean,
        fontSize: 16,
        height: 1.3,
      ),
      labelLarge: TextStyle(
        color: AppColors.ocean,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  final scheme = base.colorScheme;
  return base.copyWith(
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(64),
        textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        backgroundColor: AppColors.pickle,
        foregroundColor: AppColors.onPickle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(64),
        textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        foregroundColor: AppColors.ocean,
        side: const BorderSide(color: AppColors.ocean, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.ocean, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.ocean, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.coral, width: 2),
      ),
      contentPadding: const EdgeInsets.all(20),
      hintStyle: const TextStyle(fontSize: 18, color: Color(0xFF6B7A82)),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStatePropertyAll(scheme.primary),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => AppColors.pickle,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.pickle
            : const Color(0xFFB8C0C0),
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
  );
}