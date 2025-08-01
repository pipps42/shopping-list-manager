class RecipeIngredient {
  final int? id;
  final int recipeId;
  final int productId;
  final String? quantity;
  final String? notes;

  // Campi aggiuntivi per le query JOIN
  final String? productName;
  final String? productImagePath;
  final int? departmentId;
  final String? departmentName;

  RecipeIngredient({
    this.id,
    required this.recipeId,
    required this.productId,
    this.quantity,
    this.notes,
    this.productName,
    this.productImagePath,
    this.departmentId,
    this.departmentName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'product_id': productId,
      'quantity': quantity,
      'notes': notes,
    };
  }

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      id: map['id']?.toInt(),
      recipeId: map['recipe_id']?.toInt() ?? 0,
      productId: map['product_id']?.toInt() ?? 0,
      quantity: map['quantity'],
      notes: map['notes'],
      productName: map['product_name'],
      productImagePath: map['product_image_path'],
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
    String? productImagePath,
    int? departmentId,
    String? departmentName,
  }) {
    return RecipeIngredient(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      productName: productName ?? this.productName,
      productImagePath: productImagePath ?? this.productImagePath,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
    );
  }
}
