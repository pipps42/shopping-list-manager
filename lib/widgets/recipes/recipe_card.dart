import 'package:flutter/material.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import '../../models/recipe_with_ingredients.dart';
import 'dart:io';

class RecipeCard extends StatelessWidget {
  final RecipeWithIngredients recipeWithIngredients;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onManageIngredients;
  final VoidCallback? onAddToList;

  const RecipeCard({
    super.key,
    required this.recipeWithIngredients,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onManageIngredients,
    this.onAddToList,
  });

  @override
  Widget build(BuildContext context) {
    final recipe = recipeWithIngredients.recipe;
    final ingredientsCount = recipeWithIngredients.totalIngredients;

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingS),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Row(
            children: [
              // Immagine ricetta
              _buildRecipeImage(context, recipe.imagePath),

              const SizedBox(width: AppConstants.spacingM),

              // Informazioni ricetta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    if (recipe.description != null &&
                        recipe.description!.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.spacingXS),
                      Text(
                        recipe.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: AppConstants.spacingS),

                    // Contatore ingredienti
                    Row(
                      children: [
                        Icon(
                          Icons.restaurant,
                          size: AppConstants.iconS,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppConstants.spacingXS),
                        Text(
                          '$ingredientsCount ingredient${ingredientsCount != 1 ? 'i' : 'e'}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.textSecondary(context),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Menu azioni
              PopupMenuButton(
                onSelected: (value) {
                  switch (value) {
                    case 'manage_ingredients':
                      onManageIngredients?.call();
                      break;
                    case 'add_to_list':
                      onAddToList?.call();
                      break;
                    case 'edit':
                      onEdit();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (onManageIngredients != null)
                    const PopupMenuItem(
                      value: 'manage_ingredients',
                      child: Row(
                        children: [
                          Icon(Icons.edit_note),
                          SizedBox(width: AppConstants.spacingS),
                          Text('Gestisci Ingredienti'),
                        ],
                      ),
                    ),
                  if (onAddToList != null)
                    const PopupMenuItem(
                      value: 'add_to_list',
                      child: Row(
                        children: [
                          Icon(Icons.add_shopping_cart),
                          SizedBox(width: AppConstants.spacingS),
                          Text('Aggiungi alla Lista'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: AppConstants.spacingS),
                        Text('Modifica'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: AppColors.error),
                        SizedBox(width: AppConstants.spacingS),
                        Text(
                          'Elimina',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeImage(BuildContext context, String? imagePath) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        color: AppColors.surface(context),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: imagePath != null && File(imagePath).existsSync()
            ? Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                cacheWidth: 60,
                cacheHeight: 60,
              )
            : Icon(
                Icons.restaurant_menu,
                size: AppConstants.iconL,
                color: AppColors.primary,
              ),
      ),
    );
  }
}
