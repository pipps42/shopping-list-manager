import 'package:shopping_list_manager/utils/constants.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/department.dart';
import '../../providers/image_provider.dart';
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
          ),
          const SizedBox(height: AppConstants.spacingM),

          // Sezione immagine
          _buildImageSection(),
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

  Widget _buildImageSection() {
    return Row(
      children: [
        // Preview immagine
        if (_selectedImagePath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(_selectedImagePath!),
              width: AppConstants.imageXL,
              height: AppConstants.imageXL,
              fit: BoxFit.cover,
              cacheWidth: AppConstants.imageCacheWidth,
              cacheHeight: AppConstants.imageCacheHeight,
            ),
          )
        else
          Container(
            width: AppConstants.imageXL,
            height: AppConstants.imageXL,
            decoration: BoxDecoration(
              color: AppColors.border(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.store, size: AppConstants.iconL),
          ),
        const SizedBox(width: AppConstants.spacingM),

        // Bottoni gestione immagine
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
                onPressed: _isLoading ? null : _handlePickImage,
                icon: const Icon(Icons.camera_alt),
                label: Text(AppStrings.chooseImage),
              ),
              if (_selectedImagePath != null)
                TextButton.icon(
                  onPressed: _handleRemoveImage,
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  label: const Text(
                    AppStrings.removeImage,
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handlePickImage() async {
    setState(() => _isLoading = true);

    try {
      final imagePath = await ref.read(imageServiceProvider).pickAndSaveImage();

      if (imagePath != null) {
        setState(() {
          _selectedImagePath = imagePath;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nella selezione immagine: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleRemoveImage() {
    setState(() {
      _selectedImagePath = null;
    });
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
