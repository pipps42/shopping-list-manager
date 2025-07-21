import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/providers/database_provider.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:shopping_list_manager/widgets/common/empty_state_widget.dart';
import 'package:shopping_list_manager/widgets/common/loading_widget.dart';
import '../../models/recipe_with_ingredients.dart';
import '../../models/recipe_ingredient.dart';
import 'dart:io';

class RecipeIngredientsDialog extends ConsumerStatefulWidget {
  final RecipeWithIngredients recipeWithIngredients;
  final Function(int productId) onProductSelected;

  const RecipeIngredientsDialog({
    super.key,
    required this.recipeWithIngredients,
    required this.onProductSelected,
  });

  @override
  ConsumerState<RecipeIngredientsDialog> createState() =>
      _RecipeIngredientsDialogState();
}

class _RecipeIngredientsDialogState
    extends ConsumerState<RecipeIngredientsDialog> {
  Set<int> _productsInCurrentList = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProductsInCurrentList();
  }

  Future<void> _loadProductsInCurrentList() async {
    try {
      final databaseService = ref.read(databaseServiceProvider);
      final productIds = widget.recipeWithIngredients.productIds;
      final inCurrentList = await databaseService.getProductIdsInCurrentList(
        productIds,
      );

      if (mounted) {
        setState(() {
          _productsInCurrentList = inCurrentList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipeWithIngredients.recipe;
    final ingredients = widget.recipeWithIngredients.ingredients;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header
            _buildHeader(context, recipe),

            // Contenuto
            Expanded(
              child: _isLoading
                  ? const LoadingWidget(message: 'Caricamento ingredienti...')
                  : _buildIngredientsList(ingredients),
            ),

            // Footer con azioni
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, recipe) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstants.borderRadius),
          topRight: Radius.circular(AppConstants.borderRadius),
        ),
      ),
      child: Row(
        children: [
          // Immagine ricetta
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              color: Colors.white.withOpacity(0.2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              child:
                  recipe.imagePath != null &&
                      File(recipe.imagePath!).existsSync()
                  ? Image.file(
                      File(recipe.imagePath!),
                      fit: BoxFit.cover,
                      cacheWidth: 50,
                      cacheHeight: 50,
                    )
                  : Icon(
                      Icons.restaurant_menu,
                      size: AppConstants.iconM,
                      color: Colors.white,
                    ),
            ),
          ),

          const SizedBox(width: AppConstants.spacingM),

          // Titolo e sottotitolo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXS),
                Text(
                  'Tocca gli ingredienti per aggiungerli alla lista',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Pulsante chiudi
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList(List<RecipeIngredient> ingredients) {
    if (ingredients.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.restaurant,
        title: 'Nessun ingrediente',
        subtitle: 'Questa ricetta non ha ingredienti configurati',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        return _buildIngredientTile(ingredient);
      },
    );
  }

  Widget _buildIngredientTile(RecipeIngredient ingredient) {
    final isInCurrentList = _productsInCurrentList.contains(
      ingredient.productId,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingS),
      child: ListTile(
        leading: _buildProductImage(ingredient.productImagePath),
        title: Text(
          ingredient.productName ?? 'Prodotto sconosciuto',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isInCurrentList ? AppColors.textSecondary(context) : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ingredient.departmentName != null)
              Text(
                ingredient.departmentName!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            if (ingredient.quantity != null && ingredient.quantity!.isNotEmpty)
              Text(
                'Quantità: ${ingredient.quantity}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (ingredient.notes != null && ingredient.notes!.isNotEmpty)
              Text(
                'Note: ${ingredient.notes}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
          ],
        ),
        trailing: isInCurrentList
            ? Icon(Icons.check_circle, color: AppColors.success)
            : const Icon(Icons.add_circle_outline),
        onTap: isInCurrentList ? null : () => _addIngredientToList(ingredient),
      ),
    );
  }

  Widget _buildProductImage(String? imagePath) {
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

  Widget _buildFooter(BuildContext context) {
    final totalIngredients = widget.recipeWithIngredients.ingredients.length;
    final ingredientsInList = _productsInCurrentList.length;
    final remainingIngredients = totalIngredients - ingredientsInList;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppConstants.borderRadius),
          bottomRight: Radius.circular(AppConstants.borderRadius),
        ),
      ),
      child: Row(
        children: [
          // Statistiche
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$ingredientsInList di $totalIngredients nella lista',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                if (remainingIngredients > 0)
                  Text(
                    '$remainingIngredients ingredienti mancanti',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
              ],
            ),
          ),

          // Pulsante aggiungi tutti
          if (remainingIngredients > 0)
            ElevatedButton.icon(
              onPressed: _addAllIngredientsToList,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Aggiungi tutti'),
            ),
        ],
      ),
    );
  }

  void _addIngredientToList(RecipeIngredient ingredient) async {
    try {
      await widget.onProductSelected(ingredient.productId);

      // Aggiorna lo stato locale
      setState(() {
        _productsInCurrentList.add(ingredient.productId);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nell\'aggiungere l\'ingrediente: $e')),
        );
      }
    }
  }

  void _addAllIngredientsToList() async {
    final ingredients = widget.recipeWithIngredients.ingredients
        .where(
          (ingredient) =>
              !_productsInCurrentList.contains(ingredient.productId),
        )
        .toList();

    for (final ingredient in ingredients) {
      try {
        await widget.onProductSelected(ingredient.productId);

        // Aggiorna lo stato locale
        setState(() {
          _productsInCurrentList.add(ingredient.productId);
        });
      } catch (e) {
        // Continua con gli altri ingredienti anche se uno fallisce
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingredienti aggiunti alla lista!')),
      );
    }
  }
}
