import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/providers/list_type_provider.dart';
import 'package:shopping_list_manager/providers/current_list_provider.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:shopping_list_manager/widgets/common/empty_state_widget.dart';
import 'package:shopping_list_manager/widgets/common/loading_widget.dart';
import 'package:shopping_list_manager/widgets/common/base_dialog.dart';
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

    return BaseDialog(
      title: recipe.name,
      subtitle: 'Aggiungi ingredienti alla lista selezionata',
      titleIcon: Icons.restaurant_menu,
      hasColoredHeader: true,
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.8,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown selezione lista
          _buildListSelector(),
          const SizedBox(height: AppConstants.spacingM),

          // Lista ingredienti
          Expanded(child: _buildIngredientsList(ingredients)),
        ],
      ),
      actions: [DialogAction.cancel(onPressed: () => Navigator.pop(context))],
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
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
        subtitle: _buildIngredientSubtitle(ingredient),
        trailing: widget.onProductRemoved != null
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  onTap: () => widget.onProductRemoved!(
                    ingredient.productId,
                    _selectedListType,
                  ),
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
      style: TextStyle(fontSize: 12, color: AppColors.textDisabled(context)),
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

    return DropdownMenu<String>(
      initialSelection: _selectedListType,
      enableFilter: false,
      enableSearch: false,
      requestFocusOnTap: false,
      leadingIcon: Icon(
        getListTypeIcon(_selectedListType),
        size: AppConstants.iconS,
        color: AppColors.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingS,
          vertical: AppConstants.paddingS,
        ),
      ),
      trailingIcon: Icon(
        Icons.arrow_drop_down,
        color: AppColors.primary,
        size: AppConstants.iconM,
      ),
      selectedTrailingIcon: Icon(
        Icons.arrow_drop_up,
        color: AppColors.primary,
        size: AppConstants.iconM,
      ),
      onSelected: (String? value) {
        if (value != null) {
          setState(() {
            _selectedListType = value;
          });
        }
      },
      dropdownMenuEntries: listTypes.map<DropdownMenuEntry<String>>((
        String value,
      ) {
        return DropdownMenuEntry<String>(
          value: value,
          label: getListTypeName(value),
          leadingIcon: Icon(
            getListTypeIcon(value),
            size: AppConstants.iconS,
            color: AppColors.primary,
          ),
        );
      }).toList(),
    );
  }

  void _addIngredientToList(RecipeIngredient ingredient, String listType) {
    widget.onProductSelected(ingredient.productId, listType);
  }
}
