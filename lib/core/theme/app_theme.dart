import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,

    scaffoldBackgroundColor: AppColors.lightBackground,

    colorScheme: const ColorScheme.light(
      surface: AppColors.lightCard,
      onSurface: AppColors.lightText,
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: AppColors.lightText,
      ),
    ),

    iconTheme: const IconThemeData(
      color: AppColors.lightText,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppColors.darkBackground,

    colorScheme: const ColorScheme.dark(
      surface: AppColors.darkCard,
      onSurface: AppColors.darkText,
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: AppColors.darkText,
      ),
    ),

    iconTheme: const IconThemeData(
      color: AppColors.darkText,
    ),
  );
}