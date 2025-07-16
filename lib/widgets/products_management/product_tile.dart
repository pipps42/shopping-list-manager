import 'package:shopping_list_manager/utils/constants.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../models/department.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';

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
                color: AppColors.textSecondary,
                fontSize: AppConstants.fontM,
              ),
            ),
            /* Text(
              'ID: ${product.id}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppConstants.fontS,
              ),
            ), */
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
    if (product.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Image.file(
          File(product.imagePath!),
          width: AppConstants.imageL,
          height: AppConstants.imageL,
          fit: BoxFit.cover,
          cacheWidth: AppConstants.imageCacheWidth,
          cacheHeight: AppConstants.imageCacheHeight,
          errorBuilder: (context, error, stackTrace) =>
              _buildDefaultProductIcon(),
        ),
      );
    }
    return _buildDefaultProductIcon();
  }

  Widget _buildDefaultProductIcon() {
    return Container(
      width: AppConstants.imageL,
      height: AppConstants.imageL,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2), // ✅ Brand primary
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Icon(
        Icons.shopping_basket,
        size: AppConstants.iconM,
        color: AppColors.primary, // ✅ Brand primary
      ),
    );
  }
}
