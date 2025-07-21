import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:shopping_list_manager/widgets/common/empty_state_widget.dart';
import 'package:shopping_list_manager/widgets/common/error_state_widget.dart';
import 'package:shopping_list_manager/widgets/common/loading_widget.dart';
import '../providers/recipes_provider.dart';
import '../providers/current_list_provider.dart';
import '../models/recipe_with_ingredients.dart';
import '../widgets/recipes/recipe_card.dart';
import '../widgets/recipes/recipe_form_dialog.dart';
import '../widgets/recipes/recipe_ingredients_dialog.dart';
import 'dart:io';

class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key});

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFocus() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final recipesState = ref.watch(recipesWithIngredientsProvider);

    return GestureDetector(
      onTap: _clearFocus,
      child: Scaffold(
        body: Column(
          children: [
            // Barra di ricerca
            _buildSearchBar(),

            // Lista ricette
            Expanded(
              child: recipesState.when(
                data: (recipes) => _buildRecipesList(recipes),
                loading: () =>
                    const LoadingWidget(message: 'Caricamento ricette...'),
                error: (error, stack) => ErrorStateWidget(
                  message: 'Errore nel caricamento delle ricette: $error',
                  onRetry: () => ref.invalidate(recipesWithIngredientsProvider),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "recipes_fab",
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.textOnSecondary(context),
          onPressed: () {
            _clearFocus();
            _showAddRecipeDialog();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: TextField(
        controller: _searchController,
        onChanged: (value) =>
            setState(() => _searchQuery = value.toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Cerca ricette...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipesList(List<RecipeWithIngredients> allRecipes) {
    final filteredRecipes = _filterRecipes(allRecipes);

    if (filteredRecipes.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(recipesWithIngredientsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: AppConstants.paddingS,
          left: AppConstants.paddingS,
          right: AppConstants.paddingS,
          bottom: AppConstants.listBottomSpacing,
        ),
        itemCount: filteredRecipes.length,
        itemBuilder: (context, index) {
          final recipeWithIngredients = filteredRecipes[index];
          return RecipeCard(
            recipeWithIngredients: recipeWithIngredients,
            onTap: () => _showRecipeIngredientsDialog(recipeWithIngredients),
            onEdit: () => _showEditRecipeDialog(recipeWithIngredients.recipe),
            onDelete: () =>
                _showDeleteRecipeDialog(recipeWithIngredients.recipe),
          );
        },
      ),
    );
  }

  List<RecipeWithIngredients> _filterRecipes(
    List<RecipeWithIngredients> allRecipes,
  ) {
    if (_searchQuery.isEmpty) return allRecipes;

    return allRecipes.where((recipeWithIngredients) {
      final recipe = recipeWithIngredients.recipe;
      return recipe.name.toLowerCase().contains(_searchQuery) ||
          (recipe.description?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();
  }

  Widget _buildEmptyState() {
    final hasSearch = _searchQuery.isNotEmpty;

    return EmptyStateWidget(
      icon: hasSearch ? Icons.search_off : Icons.restaurant_menu,
      title: hasSearch ? 'Nessuna ricetta trovata' : 'Nessuna ricetta',
      subtitle: hasSearch
          ? 'Prova a modificare la ricerca'
          : 'Aggiungi la tua prima ricetta con il pulsante +',
    );
  }

  void _showAddRecipeDialog() {
    showDialog(
      context: context,
      builder: (context) => RecipeFormDialog(
        onSave: (recipe) async {
          await ref.read(recipesProvider.notifier).addRecipe(recipe);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ricetta aggiunta con successo')),
            );
          }
        },
      ),
    );
  }

  void _showEditRecipeDialog(recipe) {
    showDialog(
      context: context,
      builder: (context) => RecipeFormDialog(
        recipe: recipe,
        onSave: (updatedRecipe) async {
          await ref.read(recipesProvider.notifier).updateRecipe(updatedRecipe);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ricetta modificata con successo')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteRecipeDialog(recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Ricetta'),
        content: Text('Sei sicuro di voler eliminare "${recipe.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(recipesProvider.notifier).deleteRecipe(recipe.id!);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ricetta eliminata con successo'),
                  ),
                );
              }
            },
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  void _showRecipeIngredientsDialog(
    RecipeWithIngredients recipeWithIngredients,
  ) {
    showDialog(
      context: context,
      builder: (context) => RecipeIngredientsDialog(
        recipeWithIngredients: recipeWithIngredients,
        onProductSelected: (productId) async {
          await ref
              .read(currentListProvider.notifier)
              .addProductToList(productId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Prodotto aggiunto alla lista')),
            );
          }
        },
      ),
    );
  }
}
