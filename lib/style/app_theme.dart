import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static final ThemeData defaultTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: StadiumBorder(),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.backgroundColor,
        textStyle: TextStyle(fontWeight: FontWeight.bold),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    ),
  );
}
