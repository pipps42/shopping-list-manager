import 'product.dart';

/// Enum per i tipi di operazioni sui prodotti
enum ProductEventType { created, updated, deleted }

/// Evento che rappresenta un'operazione atomica su un prodotto
class ProductEvent {
  final ProductEventType type;
  final Product? product; // null per le operazioni di delete
  final int? productId; // per le operazioni di delete
  final String? oldName; // per le operazioni di update, se il nome è cambiato

  const ProductEvent({
    required this.type,
    this.product,
    this.productId,
    this.oldName,
  });

  /// Factory per evento di creazione prodotto
  ProductEvent.created(Product this.product)
    : type = ProductEventType.created,
      productId = null,
      oldName = null;

  /// Factory per evento di aggiornamento prodotto
  ProductEvent.updated(Product this.product, {this.oldName})
    : type = ProductEventType.updated,
      productId = null;

  /// Factory per evento di eliminazione prodotto
  ProductEvent.deleted(int this.productId)
    : type = ProductEventType.deleted,
      product = null,
      oldName = null;

  @override
  String toString() {
    switch (type) {
      case ProductEventType.created:
        return 'ProductEvent.created(${product?.name})';
      case ProductEventType.updated:
        return 'ProductEvent.updated(${product?.name}${oldName != null ? ', oldName: $oldName' : ''})';
      case ProductEventType.deleted:
        return 'ProductEvent.deleted($productId)';
    }
  }
}
