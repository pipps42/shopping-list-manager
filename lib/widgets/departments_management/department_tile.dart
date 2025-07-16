import 'package:shopping_list_manager/utils/constants.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/department.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';

class DepartmentTileWidget extends StatelessWidget {
  final Department department;
  final int index;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const DepartmentTileWidget({
    super.key,
    required this.department,
    required this.index,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('dept_${department.id}'),
      margin: const EdgeInsets.symmetric(
        vertical: AppConstants.paddingXS,
        horizontal: AppConstants.paddingS,
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle per drag
            Icon(Icons.drag_handle, color: AppColors.textSecondary),
            const SizedBox(width: AppConstants.spacingS),
            // Immagine reparto
            _buildDepartmentImage(),
          ],
        ),
        title: Text(
          department.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Posizione: ${index + 1}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'view':
                onView();
                break;
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: AppConstants.spacingS),
                  Text(AppStrings.viewProducts),
                ],
              ),
            ),
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
        onTap: onTap ?? onView,
      ),
    );
  }

  Widget _buildDepartmentImage() {
    if (department.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Image.file(
          File(department.imagePath!),
          width: AppConstants.imageL,
          height: AppConstants.imageL,
          fit: BoxFit.cover,
          cacheWidth: AppConstants.imageCacheWidth,
          cacheHeight: AppConstants.imageCacheHeight,
          errorBuilder: (context, error, stackTrace) =>
              _buildDefaultDepartmentIcon(),
        ),
      );
    }
    return _buildDefaultDepartmentIcon();
  }

  Widget _buildDefaultDepartmentIcon() {
    return Container(
      width: AppConstants.imageL,
      height: AppConstants.imageL,
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Icon(
        Icons.store,
        size: AppConstants.iconM,
        color: AppColors.secondary,
      ),
    );
  }
}
