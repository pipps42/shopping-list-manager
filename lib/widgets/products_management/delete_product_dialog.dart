import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import '../../models/product.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';

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
    return AlertDialog(
      title: const Text('Elimina Prodotto'),
      content: Text('Sei sicuro di voler eliminare "${product.name}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirmDelete();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.textOnPrimary(context),
          ),
          child: Text(AppStrings.delete),
        ),
      ],
    );
  }
}
