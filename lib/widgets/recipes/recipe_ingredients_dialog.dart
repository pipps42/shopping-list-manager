import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/providers/list_type_provider.dart';
import 'package:shopping_list_manager/providers/current_list_provider.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:shopping_list_manager/widgets/common/empty_state_widget.dart';
import 'package:shopping_list_manager/widgets/common/loading_widget.dart';
import '../../models/recipe_with_ingredients.dart';
import '../../models/recipe_ingredient.dart';
import 'dart:io';

class RecipeIngredientsDialog extends ConsumerStatefulWidget {
  final RecipeWithIngredients recipeWithIngredients;
  final Function(int productId, String listType) onProductSelected;
  final Function(int productId, String listType)? onProductRemoved;

  const RecipeIngredientsDialog({
    super.key,
    required this.recipeWithIngredients,
    required this.onProductSelected,
    this.onProductRemoved,
  });

  @override
  ConsumerState<RecipeIngredientsDialog> createState() =>
      _RecipeIngredientsDialogState();
}

class _RecipeIngredientsDialogState
    extends ConsumerState<RecipeIngredientsDialog> {
  String _selectedListType = 'weekly';

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipeWithIngredients.recipe;
    final ingredients = widget.recipeWithIngredients.ingredients;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context, recipe),
            const SizedBox(height: AppConstants.spacingM),

            // Contenuto
            Expanded(
              child: _buildIngredientsList(ingredients),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prima riga: Icona ricetta + Nome + Bottone chiudi
        Row(
          children: [
            // Icona/Immagine ricetta
            Container(
              width: AppConstants.imageM,
              height: AppConstants.imageM,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                child: recipe.imagePath != null && File(recipe.imagePath!).existsSync()
                    ? Image.file(
                        File(recipe.imagePath!),
                        fit: BoxFit.cover,
                        cacheWidth: AppConstants.imageCacheWidth,
                        cacheHeight: AppConstants.imageCacheHeight,
                      )
                    : Icon(
                        Icons.restaurant_menu,
                        size: AppConstants.iconM,
                        color: AppColors.primary,
                      ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            
            // Nome ricetta
            Expanded(
              child: Text(
                recipe.name,
                style: const TextStyle(
                  fontSize: AppConstants.fontXXXL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Bottone chiudi
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        
        const SizedBox(height: AppConstants.spacingS),
        
        // Seconda riga: Descrizione
        Text(
          'Aggiungi ingredienti alla lista selezionata',
          style: TextStyle(
            fontSize: AppConstants.fontM,
            color: AppColors.textSecondary(context),
          ),
        ),
        
        const SizedBox(height: AppConstants.spacingM),
        
        // Terza riga: Dropdown selezione lista
        _buildListSelector(),
      ],
    );
  }

  Widget _buildIngredientsList(List<RecipeIngredient> ingredients) {
    if (ingredients.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.restaurant,
        title: 'Nessun ingrediente',
        subtitle: 'Questa ricetta non ha ingredienti configurati',
        iconSize: AppConstants.iconXL,
      );
    }

    // Watch del provider per la lista specifica selezionata
    final listProductIds = ref.watch(listProductIdsProvider(_selectedListType));

    return listProductIds.when(
      data: (_) => ListView.builder(
        itemCount: ingredients.length,
        itemBuilder: (context, index) {
          final ingredient = ingredients[index];
          return _buildIngredientTile(ingredient);
        },
      ),
      loading: () => const LoadingWidget(message: 'Caricamento ingredienti...'),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: AppColors.error),
            const SizedBox(height: AppConstants.spacingM),
            Text('Errore nel caricamento: $error'),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientTile(RecipeIngredient ingredient) {
    final listProductIds = ref.watch(listProductIdsProvider(_selectedListType));

    return listProductIds.when(
      data: (productIds) {
        final isInList = productIds.contains(ingredient.productId);

        if (isInList) {
          return _buildCheckedIngredientTile(ingredient);
        } else {
          return _buildUncheckedIngredientTile(ingredient);
        }
      },
      loading: () => _buildLoadingTile(ingredient),
      error: (error, stack) => _buildErrorTile(ingredient, error),
    );
  }

  Widget _buildUncheckedIngredientTile(RecipeIngredient ingredient) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1.0),
      child: ListTile(
        leading: _buildProductImage(ingredient.productImagePath),
        title: Text(ingredient.productName ?? 'Prodotto sconosciuto'),
        subtitle: _buildIngredientSubtitle(ingredient),
        trailing: const Icon(Icons.add_circle_outline),
        onTap: () => _addIngredientToList(ingredient, _selectedListType),
      ),
    );
  }

  Widget _buildCheckedIngredientTile(RecipeIngredient ingredient) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1.0),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: ListTile(
        leading: _buildProductImage(ingredient.productImagePath),
        title: Text(
          ingredient.productName ?? 'Prodotto sconosciuto',
          style: TextStyle(
            color: AppColors.textSecondary(context),
          ),
        ),
        subtitle: _buildIngredientSubtitle(ingredient),
        trailing: widget.onProductRemoved != null
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  onTap: () => widget.onProductRemoved!(ingredient.productId, _selectedListType),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.remove_circle_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildLoadingTile(RecipeIngredient ingredient) {
    return ListTile(
      leading: _buildProductImage(ingredient.productImagePath),
      title: Text(ingredient.productName ?? 'Prodotto sconosciuto'),
      subtitle: _buildIngredientSubtitle(ingredient),
      trailing: const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorTile(RecipeIngredient ingredient, Object error) {
    return ListTile(
      leading: _buildProductImage(ingredient.productImagePath),
      title: Text(ingredient.productName ?? 'Prodotto sconosciuto'),
      subtitle: Text('Errore: $error'),
      trailing: const Icon(Icons.error, color: AppColors.error),
    );
  }

  Widget _buildIngredientSubtitle(RecipeIngredient ingredient) {
    final subtitleParts = <String>[];
    
    if (ingredient.departmentName != null) {
      subtitleParts.add(ingredient.departmentName!);
    }
    if (ingredient.quantity != null && ingredient.quantity!.isNotEmpty) {
      subtitleParts.add('Qtà: ${ingredient.quantity}');
    }
    if (ingredient.notes != null && ingredient.notes!.isNotEmpty) {
      subtitleParts.add('Note: ${ingredient.notes}');
    }

    return Text(
      subtitleParts.join(' • '),
      style: TextStyle(
        fontSize: 12,
        color: AppColors.textDisabled(context),
      ),
    );
  }

  Widget _buildProductImage(String? imagePath) {
    if (imagePath != null && File(imagePath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Image.file(
          File(imagePath),
          width: AppConstants.imageM,
          height: AppConstants.imageM,
          fit: BoxFit.cover,
          cacheWidth: AppConstants.imageCacheWidth,
          cacheHeight: AppConstants.imageCacheHeight,
          errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
        ),
      );
    }
    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Container(
      width: AppConstants.imageM,
      height: AppConstants.imageM,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Icon(
        Icons.shopping_basket,
        size: AppConstants.iconM,
        color: AppColors.primary,
      ),
    );
  }


  Widget _buildListSelector() {
    const listTypes = ['weekly', 'monthly', 'occasional'];
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: AppConstants.paddingS,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedListType,
          icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
          dropdownColor: AppColors.surface(context),
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: AppConstants.fontM,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedListType = newValue;
              });
// Niente da ricaricare, i provider si aggiornano automaticamente
            }
          },
          items: listTypes.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    getListTypeIcon(value),
                    size: AppConstants.iconS,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppConstants.spacingS),
                  Text(getListTypeName(value)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _addIngredientToList(RecipeIngredient ingredient, String listType) {
    widget.onProductSelected(ingredient.productId, listType);
  }
}
