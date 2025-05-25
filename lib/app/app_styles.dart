import 'package:flutter/material.dart';

class AppStyles {
  // Темная тема
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4DB6AC), // мягкий бирюзовый
        secondary: Color(0xFF78909C), // мягкий синий-серый
        surface: Color(0xFF1E1E1E),
        background: Color(0xFF121212),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white70,
        onBackground: Colors.white70,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w300,
          color: Colors.white54,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      ),

      iconTheme: const IconThemeData(color: Colors.white70, size: 24.0),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF263238), // глубокий синий-серый
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4DB6AC),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1E1E1E),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF4DB6AC), width: 2),
        ),
        labelStyle: TextStyle(color: Colors.white70),
      ),

      cardTheme: CardTheme(
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }

  // Светлая тема
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF546E7A), // тёмный blueGrey
        secondary: Color(0xFF009688), // тёмный бирюзовый
        surface: Color(0xFFF5F5F5), // мягкий серо-белый
        background: Color(0xFFF0F0F0), // фон чуть темнее белого
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
        onBackground: Colors.black87,
      ),
      scaffoldBackgroundColor: const Color(0xFFF0F0F0),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.black54,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w300,
          color: Colors.black38,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
      ),

      iconTheme: const IconThemeData(color: Colors.black54, size: 24.0),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF546E7A), // blueGrey 700
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF009688), // бирюзовый
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF009688), width: 2),
        ),
        labelStyle: TextStyle(color: Colors.black54),
      ),

      cardTheme: CardTheme(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shadowColor: Colors.black12,
      ),
    );
  }
}
