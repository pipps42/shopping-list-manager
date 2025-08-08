import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:shopping_list_manager/utils/icon_types.dart';
import 'package:shopping_list_manager/widgets/common/error_state_widget.dart';
import 'package:shopping_list_manager/widgets/common/universal_icon.dart';
import '../common/empty_state_widget.dart';
import '../common/loading_widget.dart';
import '../add_product_dialog.dart';
import '../../models/recipe.dart';
import '../../models/recipe_ingredient.dart';
import '../../providers/recipes_provider.dart';

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
        leading: UniversalIcon(
          iconType: ingredient.productIconType ?? IconType.asset,
          iconValue: ingredient.productIconValue,
        ),
        title: Text(ingredient.productName ?? 'Prodotto'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ingredient.departmentName != null)
              Text(ingredient.departmentName!),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddProductDialog.forRecipeIngredientManagement(
        onProductSelected: (productId) async {
          await ref
              .read(recipesWithIngredientsProvider.notifier)
              .addProductToRecipe(recipe.id!, productId);
        },
        recipeName: recipe.name,
        recipeId: recipe.id!,
      ),
    );
  }
}
