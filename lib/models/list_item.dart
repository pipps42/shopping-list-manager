class ListItem {
  final int? id;
  final int listId;
  final int productId;
  final bool isChecked;
  final DateTime addedAt;

  const ListItem({
    this.id,
    required this.listId,
    required this.productId,
    required this.isChecked,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'list_id': listId,
      'product_id': productId,
      'is_checked': isChecked ? 1 : 0,
      'added_at': addedAt.millisecondsSinceEpoch,
    };
  }

  factory ListItem.fromMap(Map<String, dynamic> map) {
    return ListItem(
      id: map['id']?.toInt(),
      listId: map['list_id']?.toInt() ?? 0,
      productId: map['product_id']?.toInt() ?? 0,
      isChecked: (map['is_checked'] ?? 0) == 1,
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['added_at']),
    );
  }

  ListItem copyWith({
    int? id,
    int? listId,
    int? productId,
    bool? isChecked,
    DateTime? addedAt,
  }) {
    return ListItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      productId: productId ?? this.productId,
      isChecked: isChecked ?? this.isChecked,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
