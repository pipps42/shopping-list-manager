import 'package:shopping_list_manager/utils/constants.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../models/department.dart';

class DepartmentProductTile extends StatelessWidget {
  final Product product;
  final Department department;
  final VoidCallback onEdit;
  final VoidCallback onMove;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const DepartmentProductTile({
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
        subtitle: Text(
          'Reparto:  {department.name}',
          style: TextStyle(color: Colors.grey[600], fontSize: AppConstants.fontM),
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
                  Text('Sposta reparto'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: AppConstants.spacingS),
                  Text(AppStrings.delete, style: TextStyle(color: Colors.red)),
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
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: const Icon(Icons.shopping_basket, size: AppConstants.iconM, color: Colors.green),
    );
  }
}
