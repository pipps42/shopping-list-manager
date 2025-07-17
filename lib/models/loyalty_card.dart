class LoyaltyCard {
  final int? id;
  final String name;
  final String imagePath;
  final DateTime createdAt;

  const LoyaltyCard({
    this.id,
    required this.name,
    required this.imagePath,
    required this.createdAt,
  });

  factory LoyaltyCard.fromMap(Map<String, dynamic> map) {
    return LoyaltyCard(
      id: map['id'],
      name: map['name'],
      imagePath: map['image_path'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  LoyaltyCard copyWith({
    int? id,
    String? name,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return LoyaltyCard(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LoyaltyCard &&
        other.id == id &&
        other.name == name &&
        other.imagePath == imagePath &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        imagePath.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'LoyaltyCard(id: $id, name: $name, imagePath: $imagePath, createdAt: $createdAt)';
  }
}
