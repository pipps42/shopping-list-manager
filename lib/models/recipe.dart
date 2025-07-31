class Recipe {
  final int? id;
  final String name;
  final String? description;
  final String? imagePath;
  final int createdAt;

  Recipe({
    this.id,
    required this.name,
    this.description,
    this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_path': imagePath,
      'created_at': createdAt,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      description: map['description'],
      imagePath: map['image_path'],
      createdAt: map['created_at']?.toInt() ?? 0,
    );
  }

  Recipe copyWith({
    int? id,
    String? name,
    String? description,
    String? imagePath,
    int? createdAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
