import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/voice_recognition_service.dart';

/// Provider per il servizio di riconoscimento vocale
final voiceRecognitionServiceProvider = Provider<VoiceRecognitionService>((ref) {
  return VoiceRecognitionService();
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

  VoiceRecognitionNotifier(this._service) : super(const VoiceRecognitionState());

  /// Inizializza il servizio
  Future<bool> initialize() async {
    final success = await _service.initialize();
    
    state = state.copyWith(
      isInitialized: success,
      isAvailable: _service.isAvailable,
      lastError: success ? null : 'Inizializzazione fallita',
    );
    
    return success;
  }

  /// Avvia l'ascolto vocale
  Future<void> startListening({
    required Function(String) onResult,
    Duration? timeout,
  }) async {
    if (!state.isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    state = state.copyWith(
      isListening: true,
      lastError: null,
      lastResult: null,
    );

    await _service.startListening(
      onResult: (result) {
        state = state.copyWith(
          lastResult: result,
          isListening: false,
        );
        onResult(result);
      },
      onError: (error) {
        state = state.copyWith(
          lastError: error,
          isListening: false,
        );
      },
      timeout: timeout,
    );
  }

  /// Ferma l'ascolto
  Future<void> stopListening() async {
    await _service.stopListening();
    state = state.copyWith(isListening: false);
  }

  /// Cancella l'ascolto
  Future<void> cancelListening() async {
    await _service.cancelListening();
    state = state.copyWith(
      isListening: false,
      lastError: null,
      lastResult: null,
    );
  }

  /// Controlla i permessi microfono
  Future<bool> checkMicrophonePermission() async {
    return await _service.hasMicrophonePermission();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

/// Provider per lo stato del riconoscimento vocale
final voiceRecognitionProvider = StateNotifierProvider<VoiceRecognitionNotifier, VoiceRecognitionState>((ref) {
  final service = ref.watch(voiceRecognitionServiceProvider);
  return VoiceRecognitionNotifier(service);
});