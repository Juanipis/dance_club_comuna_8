import 'package:flutter/material.dart';

final ThemeData customTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFFF4081), // Rosa como color semilla
    brightness: Brightness.light,
  ).copyWith(
    secondary: const Color.fromARGB(255, 211, 148, 12), // Amarillo
    tertiary: const Color(0xFFFFAB40), // Naranja
    error: const Color(0xFFE57373), // Rojo suave
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onTertiary: Colors.black,
    onError: Colors.white,
    // Reemplazamos background y onBackground con surface y onSurface
    surface: Colors.white,
    onSurface: Colors.black87,
  ),
  typography: Typography.material2021(),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
        fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
    displayMedium: TextStyle(
        fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
    displaySmall: TextStyle(
        fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
    headlineMedium: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
    headlineSmall: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
    titleLarge: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
    bodySmall: TextStyle(fontSize: 12, color: Colors.black54),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF4081),
      brightness: Brightness.light,
    ).primary,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xFFFF4081), // Rosa
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFFFD54F), // Amarillo
    foregroundColor: Colors.black,
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[100],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFFF4081)), // Rosa
    ),
  ),
);
