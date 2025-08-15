import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/voice_recognition_service.dart';
import '../models/product.dart';
import 'database_provider.dart';

/// Provider per il servizio di riconoscimento vocale
final voiceRecognitionServiceProvider = Provider<VoiceRecognitionService>((
  ref,
) {
  final service = VoiceRecognitionService();
  final databaseService = ref.read(databaseServiceProvider);

  service.initialize(databaseService);
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

  VoiceRecognitionNotifier(this._service)
    : super(const VoiceRecognitionState());

  /// Inizializza il servizio
  Future<bool> initialize() async {
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

    _service.startListening(
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
      return VoiceRecognitionNotifier(service);
    });
