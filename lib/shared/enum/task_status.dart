import 'package:flutter/material.dart';

import '../../style/app_colors.dart';

enum TaskStatus {
  todo('To Do', AppColors.grey, Icons.view_agenda),
  doing('In Progress', AppColors.accentColor, Icons.cached),
  done('Done', AppColors.successColor, Icons.check);

  final String label;
  final Color color;
  final IconData icon;

  const TaskStatus(this.label, this.color, this.icon);
}
