import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import 'package:shopping_list_manager/widgets/common/app_image_uploader.dart';
import '../../models/recipe.dart';

class RecipeFormDialog extends ConsumerStatefulWidget {
  final Recipe? recipe;
  final Function(Recipe) onSave;

  const RecipeFormDialog({super.key, this.recipe, required this.onSave});

  @override
  ConsumerState<RecipeFormDialog> createState() => _RecipeFormDialogState();
}

class _RecipeFormDialogState extends ConsumerState<RecipeFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String? _selectedImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.recipe?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.recipe?.description ?? '',
    );
    _selectedImagePath = widget.recipe?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recipe != null;

    return AlertDialog(
      title: Text(
        isEditing ? AppStrings.editRecipe : AppStrings.newRecipe,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nome ricetta
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.recipeName,
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppConstants.spacingM),

            // Descrizione
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: AppStrings.recipeDescription,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppConstants.spacingM),

            // Sezione immagine
            AppImageUploader(
              imagePath: _selectedImagePath,
              onImageSelected: (path) =>
                  setState(() => _selectedImagePath = path),
              onImageRemoved: () => setState(() => _selectedImagePath = null),
              title: 'Immagine della ricetta',
              fallbackIcon: Icons.restaurant,
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
        const SnackBar(content: Text(AppStrings.recipeNameRequired)),
      );
      return;
    }

    final recipe = Recipe(
      id: widget.recipe?.id,
      name: name,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      imagePath: _selectedImagePath,
      createdAt:
          widget.recipe?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
    );

    widget.onSave(recipe);
    Navigator.pop(context);
  }
}
