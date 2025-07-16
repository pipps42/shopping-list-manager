import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import '../../models/department.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';

class DeleteDepartmentDialog extends StatelessWidget {
  final Department department;
  final VoidCallback onConfirmDelete;

  const DeleteDepartmentDialog({
    super.key,
    required this.department,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Elimina Reparto'),
      content: Text(
        'Sei sicuro di voler eliminare "${department.name}"?\n\nTutti i prodotti associati verranno eliminati.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirmDelete();
            Navigator.pop(context);

            // Mostra snackbar di conferma nel context parent
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reparto "${department.name}" eliminato'),
                  backgroundColor: AppColors.success,
                ),
              );
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.textOnPrimary,
          ),
          child: Text(AppStrings.delete),
        ),
      ],
    );
  }
}
