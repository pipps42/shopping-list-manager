import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:shopping_list_manager/widgets/common/app_image_uploader.dart';
import 'package:shopping_list_manager/widgets/common/base_dialog.dart';
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
  String? _selectedImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.recipe?.name ?? '');
    _selectedImagePath = widget.recipe?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recipe != null;

    return BaseDialog(
      title: isEditing ? AppStrings.editRecipe : AppStrings.newRecipe,
      titleIcon: isEditing ? Icons.edit : Icons.restaurant_menu,
      hasColoredHeader: true,
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

            // Sezione immagine
            AppImageUploader(
              value: _selectedImagePath,
              onValueChanged: (path) =>
                  setState(() => _selectedImagePath = path),
              onValueRemoved: () => setState(() => _selectedImagePath = null),
              title: 'Immagine della ricetta',
              fallbackIcon: Icons.restaurant,
              previewHeight: 100,
              previewWidth: 100,
            ),
          ],
        ),
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
        const SnackBar(content: Text(AppStrings.recipeNameRequired)),
      );
      return;
    }

    final recipe = Recipe(
      id: widget.recipe?.id,
      name: name,
      imagePath: _selectedImagePath,
      createdAt:
          widget.recipe?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
    );

    widget.onSave(recipe);
    Navigator.pop(context);
  }
}
