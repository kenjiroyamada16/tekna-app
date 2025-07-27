import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static final ThemeData defaultTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
  );
}
