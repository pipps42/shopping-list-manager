import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import '../../models/product.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import '../common/base_dialog.dart';

class DeleteProductDialog extends StatelessWidget {
  final Product product;
  final VoidCallback onConfirmDelete;

  const DeleteProductDialog({
    super.key,
    required this.product,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      title: 'Elimina Prodotto',
      message: 'Sei sicuro di voler eliminare "${product.name}"?',
      icon: Icons.delete_outline,
      iconColor: AppColors.error,
      confirmText: AppStrings.delete,
      confirmType: DialogActionType.delete,
      onConfirm: onConfirmDelete,
    );
  }
}
