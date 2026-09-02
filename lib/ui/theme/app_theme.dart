import 'package:flutter/material.dart';


class AppTheme {
  static const Color primarySeed = Color.fromARGB(255, 255, 60, 0); // Un color de Ejemplo.
  static const Color boardBaseColor = Color (0xFFD7CCC8);
  static const Color emptyHoleColor = Color (0xFFB71C1C);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeed,
        brightness: Brightness.light,
        surfaceContainerHighest: const Color(0xFFF5F2EB),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F2EB),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primarySeed,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontFamily: 'ArianaVioleta',
          fontSize: 20,
          fontWeight:FontWeight.bold, 
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}