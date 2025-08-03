import 'package:flutter/material.dart';

import '../../../style/app_colors.dart';

class ConfirmDeleteTaskBottomSheet extends StatelessWidget {
  final VoidCallback? onTapConfirmDelete;

  const ConfirmDeleteTaskBottomSheet({super.key, this.onTapConfirmDelete});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Icon(
                  Icons.delete_outline,
                  size: 40,
                  color: AppColors.errorColor,
                ),
              ),
            ),
            Text(
              'Confirmar',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
            ),
            Text(
              'Deseja mesmo excluir a tarefa?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onTapConfirmDelete?.call();
              },
              child: Text('Excluir'),
            ),
          ],
        ),
      ),
    );
  }
}
