class ShoppingList {
  final int? id;
  final String name;
  final DateTime createdAt;
  final DateTime? completedAt;
  final double? totalCost;

  ShoppingList({
    this.id,
    required this.name,
    required this.createdAt,
    this.completedAt,
    this.totalCost,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.millisecondsSinceEpoch,
      'completed_at': completedAt?.millisecondsSinceEpoch,
      'total_cost': totalCost,
    };
  }

  factory ShoppingList.fromMap(Map<String, dynamic> map) {
    return ShoppingList(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      completedAt: map['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_at'])
          : null,
      totalCost: map['total_cost']?.toDouble(),
    );
  }

  ShoppingList copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    DateTime? completedAt,
    double? totalCost,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      totalCost: totalCost ?? this.totalCost,
    );
  }

  bool get isCompleted => completedAt != null;
}
