import 'product.dart';

class ListItemWithProduct {
  final int? id;
  final int listId;
  final Product product;
  final bool isChecked;
  final DateTime addedAt;

  const ListItemWithProduct({
    this.id,
    required this.listId,
    required this.product,
    required this.isChecked,
    required this.addedAt,
  });

  ListItemWithProduct copyWith({
    int? id,
    int? listId,
    Product? product,
    bool? isChecked,
    DateTime? addedAt,
  }) {
    return ListItemWithProduct(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      product: product ?? this.product,
      isChecked: isChecked ?? this.isChecked,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}