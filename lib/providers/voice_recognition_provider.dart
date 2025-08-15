import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/voice_recognition_service.dart';
import '../models/product.dart';
import '../models/product_event.dart';
import 'database_provider.dart';
import 'product_events_provider.dart';

/// Provider per il servizio di riconoscimento vocale
final voiceRecognitionServiceProvider = Provider<VoiceRecognitionService>((
  ref,
) {
  final service = VoiceRecognitionService();
  // Non inizializzare automaticamente - sarà inizializzato al primo utilizzo
  return service;
});

/// Stato del riconoscimento vocale
class VoiceRecognitionState {
  final bool isInitialized;
  final bool isListening;
  final bool isAvailable;
  final String? lastError;
  final String? lastResult;

  const VoiceRecognitionState({
    this.isInitialized = false,
    this.isListening = false,
    this.isAvailable = false,
    this.lastError,
    this.lastResult,
  });

  VoiceRecognitionState copyWith({
    bool? isInitialized,
    bool? isListening,
    bool? isAvailable,
    String? lastError,
    String? lastResult,
  }) {
    return VoiceRecognitionState(
      isInitialized: isInitialized ?? this.isInitialized,
      isListening: isListening ?? this.isListening,
      isAvailable: isAvailable ?? this.isAvailable,
      lastError: lastError,
      lastResult: lastResult,
    );
  }
}

/// Notifier per gestire lo stato del riconoscimento vocale
class VoiceRecognitionNotifier extends StateNotifier<VoiceRecognitionState> {
  final VoiceRecognitionService _service;
  final Ref? _ref;

  VoiceRecognitionNotifier(this._service, [this._ref])
    : super(const VoiceRecognitionState()) {
    // Ascolta gli eventi dei prodotti per aggiornare la cache
    _listenToProductEvents();
  }

  /// Inizializza il servizio
  Future<bool> initialize() async {
    // Se non è ancora inizializzato e abbiamo un ref, passa il database service
    if (!_service.isInitialized && _ref != null) {
      final databaseService = _ref.read(databaseServiceProvider);
      final success = await _service.initialize(databaseService);
      state = state.copyWith(
        isInitialized: success,
        lastError: success ? null : 'Inizializzazione fallita',
      );
      return success;
    }
    
    // Altrimenti usa l'inizializzazione standard
    final success = await _service.initialize();
    state = state.copyWith(
      isInitialized: success,
      lastError: success ? null : 'Inizializzazione fallita',
    );
    return success;
  }

  /// Avvia l'ascolto vocale
  Future<void> startListening({
    required Function(List<Product>) onResult,
    required BuildContext context,
  }) async {
    if (!state.isInitialized && !await initialize()) return;

    if (!context.mounted) {
      state = state.copyWith(
        isListening: false,
        lastError: 'Contesto non montato',
      );
      return;
    }

    state = state.copyWith(
      isListening: true,
      lastError: null,
      lastResult: null,
    );

    await _service.startListening(
      onResult: (products) {
        final resultText = products.map((p) => p.name).join(', ');
        state = state.copyWith(lastResult: resultText, isListening: false);
        onResult(products);
      },
      onError: (error) {
        state = state.copyWith(lastError: error, isListening: false);
      },
      timeout: const Duration(seconds: 60),
      context: context,
    );
  }

  /// Ferma l'ascolto
  void stopListening() {
    _service.stopListening();
    state = state.copyWith(isListening: false);
  }

  /// Cancella l'ascolto
  void cancelListening() {
    _service.cancelListening();
    state = state.copyWith(
      isListening: false,
      lastError: null,
      lastResult: null,
    );
  }

  /// Controlla i permessi microfono
  Future<bool> checkMicrophonePermission() =>
      _service.hasMicrophonePermission();

  /// Ascolta gli eventi dei prodotti e aggiorna la cache del voice recognition
  void _listenToProductEvents() {
    if (_ref == null) return;

    _ref.listen<AsyncValue<ProductEvent>>(productEventsProvider, (previous, next) {
      next.whenData((event) {
        // Solo se il voice recognition è inizializzato
        if (!_service.isInitialized) return;

        switch (event.type) {
          case ProductEventType.created:
            if (event.product != null) {
              debugPrint('🎤 Voice cache: Aggiunto prodotto ${event.product!.name}');
              _service.addProductToCache(event.product!);
            }
            break;
          
          case ProductEventType.updated:
            if (event.product != null) {
              debugPrint('🎤 Voice cache: Aggiornato prodotto ${event.product!.name}');
              _service.updateProductInCache(event.product!);
            }
            break;
          
          case ProductEventType.deleted:
            if (event.productId != null) {
              debugPrint('🎤 Voice cache: Rimosso prodotto ID ${event.productId}');
              _service.removeProductFromCache(event.productId!);
            }
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

/// Provider per lo stato del riconoscimento vocale
final voiceRecognitionProvider =
    StateNotifierProvider<VoiceRecognitionNotifier, VoiceRecognitionState>((
      ref,
    ) {
      final service = ref.watch(voiceRecognitionServiceProvider);
      return VoiceRecognitionNotifier(service, ref);
    });
