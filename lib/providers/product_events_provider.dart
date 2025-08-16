import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_event.dart';

/// Provider per il bus degli eventi dei prodotti
final productEventBusProvider = Provider<ProductEventBus>((ref) {
  return ProductEventBus();
});

/// StreamProvider per ascoltare gli eventi dei prodotti
final productEventsProvider = StreamProvider<ProductEvent>((ref) {
  final eventBus = ref.watch(productEventBusProvider);
  return eventBus.stream;
});

/// Bus per gli eventi dei prodotti
class ProductEventBus {
  final StreamController<ProductEvent> _controller = StreamController<ProductEvent>.broadcast();
  
  /// Stream degli eventi
  Stream<ProductEvent> get stream => _controller.stream;
  
  /// Emette un evento
  void emit(ProductEvent event) {
    _controller.add(event);
  }
  
  /// Chiude il controller
  void dispose() {
    _controller.close();
  }
}