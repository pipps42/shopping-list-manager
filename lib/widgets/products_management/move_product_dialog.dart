import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../models/department.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import '../common/universal_icon.dart';

class MoveProductDialog extends StatelessWidget {
  final Product product;
  final List<Department> departments;
  final Function(Department department) onMoveProduct;
  final bool isSelection;

  const MoveProductDialog({
    super.key,
    required this.product,
    required this.departments,
    required this.onMoveProduct,
    this.isSelection = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isSelection ? 'Seleziona reparto' : AppStrings.moveProduct),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isSelection
                ? 'Seleziona il reparto per "${product.name}":'
                : 'Sposta "${product.name}" in:',
          ),
          const SizedBox(height: AppConstants.spacingM),
          SizedBox(
            height: 400,
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
    return UniversalIcon(
      iconType: department.iconType,
      iconValue: department.iconValue,
      size: AppConstants.imageM,
      fallbackIcon: Icons.store,
      fallbackColor: AppColors.secondary,
    );
  }
}
