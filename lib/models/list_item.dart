class ListItem {
  final int? id;
  final int listId;
  final int productId;
  final bool isChecked;
  final DateTime addedAt;

  // Campi aggiuntivi per query con JOIN
  final String? productName;
  final String? productIconType;
  final String? productIconValue;
  final int? departmentId;
  final String? departmentName;
  final int? departmentOrder;

  ListItem({
    this.id,
    required this.listId,
    required this.productId,
    required this.isChecked,
    required this.addedAt,
    this.productName,
    this.productIconType,
    this.productIconValue,
    this.departmentId,
    this.departmentName,
    this.departmentOrder,
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
      productName: map['product_name'],
      productIconType: map['product_icon_type'],
      productIconValue: map['product_icon_value'],
      departmentId: map['department_id']?.toInt(),
      departmentName: map['department_name'],
      departmentOrder: map['department_order']?.toInt(),
    );
  }

  ListItem copyWith({
    int? id,
    int? listId,
    int? productId,
    bool? isChecked,
    DateTime? addedAt,
    String? productName,
    String? productIconType,
    String? productIconValue,
    int? departmentId,
    String? departmentName,
    int? departmentOrder,
  }) {
    return ListItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      productId: productId ?? this.productId,
      isChecked: isChecked ?? this.isChecked,
      addedAt: addedAt ?? this.addedAt,
      productName: productName ?? this.productName,
      productIconType: productIconType ?? this.productIconType,
      productIconValue: productIconValue ?? this.productIconValue,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      departmentOrder: departmentOrder ?? this.departmentOrder,
    );
  }
}
