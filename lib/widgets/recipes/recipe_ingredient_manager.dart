import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:shopping_list_manager/widgets/common/error_state_widget.dart';
import '../common/empty_state_widget.dart';
import '../common/loading_widget.dart';
import '../add_product_dialog.dart';
import '../../models/recipe.dart';
import '../../models/recipe_ingredient.dart';
import '../../providers/recipes_provider.dart';
import 'dart:io';

class RecipeIngredientManager extends ConsumerWidget {
  final Recipe recipe;

  const RecipeIngredientManager({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredientsState = ref.watch(recipeIngredientsProvider(recipe.id!));

    return Scaffold(
      appBar: AppBar(
        title: Text('Ingredienti - ${recipe.name}'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: AppColors.textOnPrimary(context),
        actions: [
          IconButton(
            onPressed: () => _showAddProductDialog(context, ref),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ingredientsState.when(
        data: (ingredients) => _buildIngredientsList(context, ref, ingredients),
        loading: () =>
            const LoadingWidget(message: 'Caricamento ingredienti...'),
        error: (error, stack) => ErrorStateWidget(
          message: 'Errore nel caricamento degli ingredienti: $error',
          onRetry: () => ref.invalidate(recipeIngredientsProvider(recipe.id!)),
        ),
      ),
    );
  }

  Widget _buildIngredientsList(
    BuildContext context,
    WidgetRef ref,
    List<RecipeIngredient> ingredients,
  ) {
    if (ingredients.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.restaurant,
        title: 'Nessun ingrediente',
        subtitle: 'Aggiungi ingredienti con il pulsante +',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        return _buildIngredientTile(context, ref, ingredient);
      },
    );
  }

  Widget _buildIngredientTile(
    BuildContext context,
    WidgetRef ref,
    RecipeIngredient ingredient,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingS),
      child: ListTile(
        leading: _buildProductImage(context, ingredient.productImagePath),
        title: Text(ingredient.productName ?? 'Prodotto'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ingredient.departmentName != null)
              Text(ingredient.departmentName!),
            if (ingredient.quantity != null && ingredient.quantity!.isNotEmpty)
              Text('Quantità: ${ingredient.quantity}'),
            if (ingredient.notes != null && ingredient.notes!.isNotEmpty)
              Text('Note: ${ingredient.notes}'),
          ],
        ),
        trailing: PopupMenuButton(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditIngredientDialog(context, ref, ingredient);
                break;
              case 'delete':
                _deleteIngredient(ref, ingredient);
                break;
            }
          },
          itemBuilder: (context) => [
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
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: AppConstants.spacingS),
                  Text('Rimuovi', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context, String? imagePath) {
    return Container(
      width: 50,
      height: 50,
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
                cacheWidth: 50,
                cacheHeight: 50,
              )
            : Icon(
                Icons.inventory_2,
                size: AppConstants.iconM,
                color: AppColors.primary,
              ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddProductDialog(
        onProductSelected: (productId) async {
          await ref
              .read(recipesWithIngredientsProvider.notifier)
              .addProductToRecipe(recipe.id!, productId);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ingrediente aggiunto!')),
            );
          }
        },
      ),
    );
  }

  void _showEditIngredientDialog(
    BuildContext context,
    WidgetRef ref,
    RecipeIngredient ingredient,
  ) {
    final quantityController = TextEditingController(
      text: ingredient.quantity ?? '',
    );
    final notesController = TextEditingController(text: ingredient.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifica ${ingredient.productName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantità',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedIngredient = ingredient.copyWith(
                quantity: quantityController.text.trim().isEmpty
                    ? null
                    : quantityController.text.trim(),
                notes: notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
              );

              await ref
                  .read(recipesWithIngredientsProvider.notifier)
                  .updateRecipeIngredient(updatedIngredient);

              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingrediente modificato!')),
                );
              }
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  void _deleteIngredient(WidgetRef ref, RecipeIngredient ingredient) {
    ref
        .read(recipesWithIngredientsProvider.notifier)
        .removeProductFromRecipe(recipe.id!, ingredient.productId);
  }
}
