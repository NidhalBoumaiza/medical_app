import 'package:flutter/material.dart';
import 'app_colors.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData getTheme() {
    return _isDarkMode
        ? ThemeData.dark().copyWith(
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryColor,
        secondary: AppColors.primaryColor,
        surface: Colors.grey[600]!,
        background: Colors.grey[900],
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.whiteColor,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteColor,
      ),
      cardTheme: CardTheme(
        color: Colors.grey[800],
      ),
    )
        : ThemeData.light().copyWith(
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.primaryColor,
        surface: Colors.white,
        background: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.whiteColor,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteColor,
      ),
      cardTheme: const CardTheme(
        color: Colors.white,
      ),
    );
  }
}