import 'package:flutter/material.dart';

import '../../../data/entities/task.dart';
import '../../../shared/enum/task_status.dart';
import '../../../style/app_colors.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final void Function(int taskId)? onTapDeleteTask;
  final void Function(Task oldTask)? onTapEditTask;

  const TaskCard({required this.task, super.key, this.onTapDeleteTask, this.onTapEditTask});

  @override
  Widget build(BuildContext context) {
    final status = TaskStatus.values.where((status) {
      return status.label == task.status;
    }).firstOrNull;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.white,
        border: Border.all(color: AppColors.black.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Visibility(
                    visible: status != null,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: status?.color,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 4,
                              children: [
                                Icon(status?.icon, size: 16),
                                Text(
                                  status?.label ?? '',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(task.description ?? '', style: TextStyle(fontSize: 14)),
                  Visibility(
                    visible: task.category?.name.isNotEmpty ?? false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.accentColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            child: Text(
                              task.category?.name ?? '',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            ElevatedButton(
              onPressed: () => onTapEditTask?.call(task),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(8),
                textStyle: TextStyle(fontSize: 12),
              ),
              child: Text('Editar'),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => onTapDeleteTask?.call(task.id),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(8),
                textStyle: TextStyle(fontSize: 12),
                backgroundColor: AppColors.errorColor,
              ),
              child: Text('Excluir'),
            ),
          ],
        ),
      ),
    );
  }
}
