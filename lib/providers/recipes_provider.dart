import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../models/recipe_with_ingredients.dart';
import '../services/database_service.dart';
import 'database_provider.dart';

// Provider per tutte le ricette
final recipesProvider =
    StateNotifierProvider<RecipesNotifier, AsyncValue<List<Recipe>>>((ref) {
      return RecipesNotifier(ref.watch(databaseServiceProvider), ref);
    });

// Provider per le ricette con ingredienti
final recipesWithIngredientsProvider =
    StateNotifierProvider<
      RecipesWithIngredientsNotifier,
      AsyncValue<List<RecipeWithIngredients>>
    >((ref) {
      return RecipesWithIngredientsNotifier(
        ref.watch(databaseServiceProvider),
        ref,
      );
    });

// Provider per una singola ricetta con ingredienti
final recipeWithIngredientsProvider =
    FutureProvider.family<RecipeWithIngredients?, int>((ref, recipeId) async {
      final databaseService = ref.watch(databaseServiceProvider);
      return await databaseService.getRecipeWithIngredients(recipeId);
    });

// Provider per gli ingredienti di una ricetta specifica
final recipeIngredientsProvider =
    FutureProvider.family<List<RecipeIngredient>, int>((ref, recipeId) async {
      final databaseService = ref.watch(databaseServiceProvider);
      return await databaseService.getRecipeIngredients(recipeId);
    });

class RecipesNotifier extends StateNotifier<AsyncValue<List<Recipe>>> {
  final DatabaseService _databaseService;
  final Ref _ref;

  RecipesNotifier(this._databaseService, this._ref)
    : super(const AsyncValue.loading()) {
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    try {
      state = const AsyncValue.loading();
      final recipes = await _databaseService.getAllRecipes();
      state = AsyncValue.data(recipes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      await _databaseService.insertRecipe(recipe);
      await loadRecipes();
      // Invalida anche il provider delle ricette con ingredienti
      _ref.invalidate(recipesWithIngredientsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      await _databaseService.updateRecipe(recipe);
      await loadRecipes();
      _ref.invalidate(recipesWithIngredientsProvider);
      _ref.invalidate(recipeWithIngredientsProvider(recipe.id!));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteRecipe(int recipeId) async {
    try {
      await _databaseService.deleteRecipe(recipeId);
      await loadRecipes();
      _ref.invalidate(recipesWithIngredientsProvider);
      _ref.invalidate(recipeWithIngredientsProvider(recipeId));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

class RecipesWithIngredientsNotifier
    extends StateNotifier<AsyncValue<List<RecipeWithIngredients>>> {
  final DatabaseService _databaseService;
  final Ref _ref;

  RecipesWithIngredientsNotifier(this._databaseService, this._ref)
    : super(const AsyncValue.loading()) {
    loadRecipesWithIngredients();
  }

  Future<void> loadRecipesWithIngredients() async {
    try {
      state = const AsyncValue.loading();
      final recipes = await _databaseService.getAllRecipesWithIngredients();
      state = AsyncValue.data(recipes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addProductToRecipe(
    int recipeId,
    int productId, {
    String? quantity,
    String? notes,
  }) async {
    try {
      final success = await _databaseService.addProductToRecipe(
        recipeId,
        productId,
        quantity: quantity,
        notes: notes,
      );
      if (success) {
        await loadRecipesWithIngredients();
        _ref.invalidate(recipeWithIngredientsProvider(recipeId));
        _ref.invalidate(recipeIngredientsProvider(recipeId));
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> removeProductFromRecipe(int recipeId, int productId) async {
    try {
      final success = await _databaseService.removeProductFromRecipe(
        recipeId,
        productId,
      );
      if (success) {
        await loadRecipesWithIngredients();
        _ref.invalidate(recipeWithIngredientsProvider(recipeId));
        _ref.invalidate(recipeIngredientsProvider(recipeId));
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateRecipeIngredient(RecipeIngredient ingredient) async {
    try {
      await _databaseService.updateRecipeIngredient(ingredient);
      await loadRecipesWithIngredients();
      _ref.invalidate(recipeWithIngredientsProvider(ingredient.recipeId));
      _ref.invalidate(recipeIngredientsProvider(ingredient.recipeId));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}
