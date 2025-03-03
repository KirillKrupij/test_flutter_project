// файл стилей

import 'package:flutter/material.dart';

class AppStyles {
  // Тема приложения
  static ThemeData get appTheme {
    return ThemeData(
      // Основные цвета
      primarySwatch: Colors.deepPurple,
      scaffoldBackgroundColor: Colors.white,

      // Стили текста
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87, // Цвет текста
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

      // Стили для AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.deepPurple,
        titleTextStyle: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Стили для Drawer
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Убираем скругление
        ),
      ),
    );
  }

  // Дополнительные стили для SideMenuItem
  static const sideMenuItemPadding = EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0);
  static const sideMenuItemIconSize = 24.0;
  static const sideMenuItemIconColor = Colors.black87;
  static const sideMenuItemHoverColor = Colors.grey;

  // Дополнительные стили для SideMenuSection
  static const sideMenuSectionPadding = EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0);
  static const sideMenuSectionTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14.0,
    color: Colors.grey,
  );
}