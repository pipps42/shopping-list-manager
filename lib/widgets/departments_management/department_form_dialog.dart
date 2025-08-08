import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list_manager/widgets/common/app_image_uploader.dart';
import 'package:shopping_list_manager/widgets/common/base_dialog.dart';
import '../../models/department.dart';
import '../../utils/icon_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DepartmentFormDialog extends ConsumerStatefulWidget {
  final Department? department;
  final Function(String name, IconType iconType, String? iconValue) onSave;

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
  IconType _selectedIconType = IconType.asset;
  String? _selectedIconValue;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.department?.name ?? '',
    );
    _selectedIconType = widget.department?.iconType ?? IconType.asset;
    _selectedIconValue = widget.department?.iconValue;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.department != null;

    return BaseDialog(
      title: isEditing ? AppStrings.editDepartment : AppStrings.addDepartment,
      titleIcon: isEditing ? Icons.edit : Icons.store,
      hasColoredHeader: true,
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

          // Sezione icona
          AppImageUploader(
            mode: UploaderMode.emojiGallery,
            value: _selectedIconValue,
            iconType: _selectedIconType,
            onValueChanged: (value) =>
                setState(() => _selectedIconValue = value),
            onIconTypeChanged: (type) =>
                setState(() => _selectedIconType = type),
            onValueRemoved: () => setState(() {
              _selectedIconValue = null;
              _selectedIconType = IconType.asset;
            }),
            title: 'Icona del reparto',
            fallbackIcon: Icons.store,
            previewHeight: 100,
            previewWidth: 100,
          ),
        ],
      ),
      actions: [
        DialogAction.cancel(onPressed: () => Navigator.pop(context)),
        DialogAction.save(
          text: isEditing ? AppStrings.save : AppStrings.add,
          onPressed: _handleSave,
          isLoading: _isLoading,
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

    widget.onSave(name, _selectedIconType, _selectedIconValue);
    Navigator.pop(context);
  }
}
