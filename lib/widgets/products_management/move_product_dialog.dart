import 'package:shopping_list_manager/utils/constants.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../models/department.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';

class MoveProductDialog extends StatelessWidget {
  final Product product;
  final List<Department> departments;
  final Function(Department department) onMoveProduct;

  const MoveProductDialog({
    super.key,
    required this.product,
    required this.departments,
    required this.onMoveProduct,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.moveProduct),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sposta "${product.name}" in:'),
          const SizedBox(height: AppConstants.spacingM),
          SizedBox(
            height: 200,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: departments.length,
              itemBuilder: (context, index) {
                final dept = departments[index];
                final isCurrentDept = dept.id == product.departmentId;

                return ListTile(
                  leading: _buildDepartmentImage(dept),
                  title: Text(dept.name),
                  trailing: isCurrentDept
                      ? const Icon(Icons.check, color: AppColors.success)
                      : null,
                  enabled: !isCurrentDept,
                  onTap: isCurrentDept
                      ? null
                      : () {
                          onMoveProduct(dept);
                          Navigator.pop(context);

                          // Mostra snackbar di conferma
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product.name} spostato in ${dept.name}',
                              ),
                            ),
                          );
                        },
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
      ],
    );
  }

  Widget _buildDepartmentImage(Department department) {
    if (department.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        child: Image.file(
          File(department.imagePath!),
          width: AppConstants.imageM,
          height: AppConstants.imageM,
          fit: BoxFit.cover,
          cacheWidth: AppConstants.imageCacheWidth,
          cacheHeight: AppConstants.imageCacheHeight,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.store, size: AppConstants.iconL),
        ),
      );
    }
    return const Icon(Icons.store, size: AppConstants.iconL);
  }
}
