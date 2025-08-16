import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:shopping_list_manager/widgets/common/app_image_uploader.dart';
import 'package:shopping_list_manager/widgets/common/base_dialog.dart';
import 'package:shopping_list_manager/widgets/common/validated_text_field.dart';
import '../../models/recipe.dart';

class RecipeFormDialog extends ConsumerStatefulWidget {
  final Recipe? recipe;
  final Function(Recipe) onSave;

  const RecipeFormDialog({super.key, this.recipe, required this.onSave});

  @override
  ConsumerState<RecipeFormDialog> createState() => _RecipeFormDialogState();
}

class _RecipeFormDialogState extends ConsumerState<RecipeFormDialog> {
  String? _selectedImagePath;
  bool _isLoading = false;
  final GlobalKey<ValidatedTextFieldState> _nameFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.recipe?.imagePath;
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
            ValidatedTextField(
              key: _nameFieldKey,
              labelText: AppStrings.recipeName,
              initialValue: widget.recipe?.name ?? '',
              isRequired: true,
              requiredMessage: AppStrings.recipeNameRequired,
              requireMinThreeLetters: true,
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
    final nameFieldState = _nameFieldKey.currentState;
    
    // Valida il campo nome
    if (nameFieldState == null || !nameFieldState.validate()) {
      return;
    }

    final name = nameFieldState.text.trim();

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
