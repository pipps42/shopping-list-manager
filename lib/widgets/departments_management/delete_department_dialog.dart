import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import '../../models/department.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import '../common/base_dialog.dart';

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
    return ConfirmationDialog(
      title: 'Elimina Reparto',
      message: 'Sei sicuro di voler eliminare "${department.name}"?\n\nTutti i prodotti associati verranno eliminati.',
      icon: Icons.delete_outline,
      iconColor: AppColors.error,
      confirmText: AppStrings.delete,
      confirmType: DialogActionType.delete,
      onConfirm: () {
        onConfirmDelete();
        
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
    );
  }
}
