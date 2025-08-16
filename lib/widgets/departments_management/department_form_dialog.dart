import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list_manager/widgets/common/app_image_uploader.dart';
import 'package:shopping_list_manager/widgets/common/base_dialog.dart';
import 'package:shopping_list_manager/widgets/common/validated_text_field.dart';
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
  IconType _selectedIconType = IconType.asset;
  String? _selectedIconValue;
  bool _isLoading = false;
  final GlobalKey<ValidatedTextFieldState> _nameFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedIconType = widget.department?.iconType ?? IconType.asset;
    _selectedIconValue = widget.department?.iconValue;
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
          ValidatedTextField(
            key: _nameFieldKey,
            labelText: AppStrings.departmentNamePlaceholder,
            initialValue: widget.department?.name ?? '',
            isRequired: true,
            requiredMessage: AppStrings.departmentNameRequired,
            requireMinThreeLetters: true,
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
    final nameFieldState = _nameFieldKey.currentState;
    
    // Valida il campo nome
    if (nameFieldState == null || !nameFieldState.validate()) {
      return;
    }

    final name = nameFieldState.text.trim();

    widget.onSave(name, _selectedIconType, _selectedIconValue);
    Navigator.pop(context);
  }
}
