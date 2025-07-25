import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/widgets/common/app_image_uploader.dart';
import '../../models/product.dart';
import '../../models/department.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';

class ProductFormDialog extends ConsumerStatefulWidget {
  final Product? product;
  final List<Department> departments;
  final int? defaultDepartmentId;
  final Function(String name, int departmentId, String? imagePath) onSave;

  const ProductFormDialog({
    super.key,
    this.product,
    required this.departments,
    this.defaultDepartmentId,
    required this.onSave,
  });

  @override
  ConsumerState<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog> {
  late TextEditingController _nameController;
  int? _selectedDepartmentId;
  String? _selectedImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');

    _selectedDepartmentId =
        widget.product?.departmentId ?? // 1. Prodotto esistente
        widget.defaultDepartmentId ?? // 2. Reparto di default passato
        (widget.departments.isNotEmpty
            ? widget.departments.first.id
            : null); // 3. Fallback primo reparto

    _selectedImagePath = widget.product?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return AlertDialog(
      title: Text(isEditing ? AppStrings.editProduct : AppStrings.newProduct),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nome prodotto
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.productNamePlaceholder,
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppConstants.spacingM),

            // Selezione reparto
            DropdownButtonFormField<int>(
              value: _selectedDepartmentId,
              decoration: const InputDecoration(
                labelText: 'Reparto',
                border: OutlineInputBorder(),
              ),
              items: widget.departments
                  .map(
                    (dept) => DropdownMenuItem(
                      value: dept.id,
                      child: Text(dept.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDepartmentId = value;
                });
              },
            ),
            const SizedBox(height: AppConstants.spacingM),

            // Sezione immagine
            AppImageUploader(
              imagePath: _selectedImagePath,
              onImageSelected: (path) =>
                  setState(() => _selectedImagePath = path),
              onImageRemoved: () => setState(() => _selectedImagePath = null),
              title: 'Immagine del prodotto',
              fallbackIcon: Icons.shopping_basket,
              previewHeight: 100,
              previewWidth: 100,
              buttonsLayout: ButtonsLayout.beside,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary(context),
          ),
          onPressed: _isLoading ? null : _handleSave,
          child: Text(isEditing ? AppStrings.save : AppStrings.add),
        ),
      ],
    );
  }

  void _handleSave() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.productNameRequired)),
      );
      return;
    }

    if (_selectedDepartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.selectDepartment)),
      );
      return;
    }

    widget.onSave(name, _selectedDepartmentId!, _selectedImagePath);
    Navigator.pop(context);
  }
}
