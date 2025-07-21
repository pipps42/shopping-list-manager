import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list_manager/widgets/common/app_image_uploader.dart';
import '../../models/department.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';

class DepartmentFormDialog extends ConsumerStatefulWidget {
  final Department? department;
  final Function(String name, String? imagePath) onSave;

  const DepartmentFormDialog({
    super.key,
    this.department,
    required this.onSave,
  });

  @override
  ConsumerState<DepartmentFormDialog> createState() =>
      _DepartmentFormDialogState();
}

class _DepartmentFormDialogState extends ConsumerState<DepartmentFormDialog> {
  late TextEditingController _nameController;
  String? _selectedImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.department?.name ?? '',
    );
    _selectedImagePath = widget.department?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.department != null;

    return AlertDialog(
      title: Text(
        isEditing ? AppStrings.editDepartment : AppStrings.addDepartment,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nome reparto
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: AppStrings.departmentNamePlaceholder,
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: AppConstants.spacingM),

          // Sezione immagine
          AppImageUploader(
            imagePath: _selectedImagePath,
            onImageSelected: (path) =>
                setState(() => _selectedImagePath = path),
            onImageRemoved: () => setState(() => _selectedImagePath = null),
            title: 'Icona del reparto',
            fallbackIcon: Icons.store,
            previewHeight: 100,
            previewWidth: 100,
            buttonsLayout: ButtonsLayout.beside,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppStrings.cancel),
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
        const SnackBar(content: Text(AppStrings.departmentNameRequired)),
      );
      return;
    }

    widget.onSave(name, _selectedImagePath);
    Navigator.pop(context);
  }
}
