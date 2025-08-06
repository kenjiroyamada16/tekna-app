import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../data/entities/task.dart';
import '../../../shared/enum/task_status.dart';
import '../../../shared/utils/extensions/date_extensions.dart';
import '../../../style/app_colors.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final void Function(int taskId)? onTapDeleteTask;
  final void Function(Task oldTask)? onTapEditTask;

  const TaskCard({
    required this.task,
    super.key,
    this.onTapDeleteTask,
    this.onTapEditTask,
  });

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
        child: Column(
          children: [
            Row(
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
                      Text(
                        task.description ?? '',
                        style: TextStyle(fontSize: 14),
                      ),
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
                Column(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox.shrink(),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => onTapEditTask?.call(task),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(8),
                            textStyle: TextStyle(fontSize: 12),
                          ),
                          child: Text('Edit'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => onTapDeleteTask?.call(task.id),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(8),
                            textStyle: TextStyle(fontSize: 12),
                            backgroundColor: AppColors.errorColor,
                          ),
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: task.expiryDate != null,
                      child: Row(
                        spacing: 8,
                        children: [
                          Visibility(
                            visible:
                                task.expiryDate?.isAfter(DateTime.now()) ??
                                false,
                            child: Icon(
                              Icons.access_time_outlined,
                              color:
                                  (task.expiryDate
                                              ?.difference(DateTime.now())
                                              .inDays ??
                                          0) >
                                      7
                                  ? AppColors.secondaryColor
                                  : AppColors.errorColor,
                              size: 16,
                            ),
                          ),
                          _expiryDateLabelWidget,
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Visibility(
              visible: task.media != null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: task.media?.url ?? '',
                  fit: BoxFit.cover,
                  height: 200,
                  errorWidget: (_, __, ___) {
                    return Container(
                      color: AppColors.grey.withValues(alpha: 0.3),
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: AppColors.grey,
                      ),
                    );
                  },
                  progressIndicatorBuilder: (_, __, ___) {
                    return Center(
                      child: SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.secondaryColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _expiryDateLabelWidget {
    final expiryDate = task.expiryDate;

    if (expiryDate == null) {
      return const SizedBox.shrink();
    }

    if (expiryDate.isBefore(DateTime.now())) {
      return const Text(
        'Expired',
        style: TextStyle(fontSize: 12, color: AppColors.errorColor),
      );
    }

    final timeLeft = expiryDate.difference(DateTime.now());

    if (timeLeft.inDays <= 7 && timeLeft.inDays > 1) {
      return Text(
        'Expiring in ${timeLeft.inDays} days',
        style: TextStyle(fontSize: 12, color: AppColors.errorColor),
      );
    }

    if (timeLeft.inDays <= 1) {
      return Text(
        'Expiring in ${timeLeft.inHours} hours',
        style: TextStyle(fontSize: 12, color: AppColors.errorColor),
      );
    }

    if (timeLeft.inHours <= 1) {
      return Text(
        'Expiring in ${timeLeft.inMinutes} minutes',
        style: TextStyle(fontSize: 12, color: AppColors.errorColor),
      );
    }

    if (timeLeft.inMinutes <= 1) {
      return Text(
        'Expiring in under 1 minute',
        style: TextStyle(fontSize: 12, color: AppColors.errorColor),
      );
    }

    return Text(
      expiryDate.toFormattedDate(),
      style: const TextStyle(fontSize: 12, color: AppColors.secondaryColor),
    );
  }
}
