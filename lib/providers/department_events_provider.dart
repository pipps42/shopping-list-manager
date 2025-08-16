import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/department_event.dart';

/// Provider per il bus degli eventi dei dipartimenti
final departmentEventBusProvider = Provider<DepartmentEventBus>((ref) {
  return DepartmentEventBus();
});

/// StreamProvider per ascoltare gli eventi dei dipartimenti
final departmentEventsProvider = StreamProvider<DepartmentEvent>((ref) {
  final eventBus = ref.watch(departmentEventBusProvider);
  return eventBus.stream;
});

/// Bus per gli eventi dei dipartimenti
class DepartmentEventBus {
  final StreamController<DepartmentEvent> _controller = StreamController<DepartmentEvent>.broadcast();
  
  /// Stream degli eventi
  Stream<DepartmentEvent> get stream => _controller.stream;
  
  /// Emette un evento
  void emit(DepartmentEvent event) {
    _controller.add(event);
  }
  
  /// Chiude il controller
  void dispose() {
    _controller.close();
  }
}