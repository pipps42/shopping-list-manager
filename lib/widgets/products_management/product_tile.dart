import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../models/department.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import '../common/universal_icon.dart';

class ProductTileWidget extends StatelessWidget {
  final Product product;
  final Department department;
  final VoidCallback onEdit;
  final VoidCallback onMove;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const ProductTileWidget({
    super.key,
    required this.product,
    required this.department,
    required this.onEdit,
    required this.onMove,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.paddingXS),
      child: ListTile(
        leading: _buildProductImage(),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              department.name,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: AppConstants.fontM,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'move':
                onMove();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: AppConstants.spacingS),
                  Text(AppStrings.edit),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'move',
              child: Row(
                children: [
                  Icon(Icons.swap_horiz),
                  SizedBox(width: AppConstants.spacingS),
                  Text(AppStrings.moveProduct),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.error),
                  SizedBox(width: AppConstants.spacingS),
                  Text(
                    AppStrings.delete,
                    style: TextStyle(color: AppColors.error),
                  ),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap ?? onEdit,
      ),
    );
  }

  Widget _buildProductImage() {
    return UniversalIcon(
      iconType: product.iconType,
      iconValue: product.iconValue,
      size: AppConstants.imageL,
      fallbackIcon: Icons.shopping_basket,
    );
  }
}
