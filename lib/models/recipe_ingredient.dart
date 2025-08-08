import '../utils/icon_types.dart';

class RecipeIngredient {
  final int? id;
  final int recipeId;
  final int productId;

  // Campi aggiuntivi per le query JOIN
  final String? productName;
  final IconType? productIconType;
  final String? productIconValue;
  final int? departmentId;
  final String? departmentName;

  RecipeIngredient({
    this.id,
    required this.recipeId,
    required this.productId,
    this.productName,
    this.productIconType,
    this.productIconValue,
    this.departmentId,
    this.departmentName,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'recipe_id': recipeId, 'product_id': productId};
  }

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      id: map['id']?.toInt(),
      recipeId: map['recipe_id']?.toInt() ?? 0,
      productId: map['product_id']?.toInt() ?? 0,
      productName: map['product_name'],
      productIconType: map['product_icon_type'] != null
          ? IconType.fromString(map['product_icon_type'])
          : null,
      productIconValue: map['product_icon_value'],
      departmentId: map['department_id']?.toInt(),
      departmentName: map['department_name'],
    );
  }

  RecipeIngredient copyWith({
    int? id,
    int? recipeId,
    int? productId,
    String? quantity,
    String? notes,
    String? productName,
    IconType? productIconType,
    String? productIconValue,
    int? departmentId,
    String? departmentName,
  }) {
    return RecipeIngredient(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productIconType: productIconType ?? this.productIconType,
      productIconValue: productIconValue ?? this.productIconValue,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
    );
  }
}
