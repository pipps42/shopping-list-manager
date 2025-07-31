import 'recipe.dart';
import 'recipe_ingredient.dart';

class RecipeWithIngredients {
  final Recipe recipe;
  final List<RecipeIngredient> ingredients;

  RecipeWithIngredients({required this.recipe, required this.ingredients});

  int get totalIngredients => ingredients.length;

  // Ottieni gli ID dei prodotti per controllare rapidamente se sono nella lista
  Set<int> get productIds => ingredients.map((i) => i.productId).toSet();
}
