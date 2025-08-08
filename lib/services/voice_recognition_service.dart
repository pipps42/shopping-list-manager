import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

/// Servizio per la gestione del riconoscimento vocale
class VoiceRecognitionService {
  static final VoiceRecognitionService _instance = VoiceRecognitionService._internal();
  factory VoiceRecognitionService() => _instance;
  VoiceRecognitionService._internal();

  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  // Getters per lo stato
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  bool get isAvailable => _speechToText.isAvailable;

  /// Inizializza il servizio di riconoscimento vocale
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Richiedi permesso microfono
      final permissionStatus = await Permission.microphone.request();
      if (permissionStatus != PermissionStatus.granted) {
        debugPrint('Permesso microfono negato');
        return false;
      }

      // Inizializza speech to text
      _isInitialized = await _speechToText.initialize(
        onError: _onError,
        onStatus: _onStatus,
        debugLogging: kDebugMode,
      );

      if (_isInitialized) {
        debugPrint('Voice Recognition Service inizializzato con successo');
      } else {
        debugPrint('Errore nell\'inizializzazione del Voice Recognition Service');
      }

      return _isInitialized;
    } catch (e) {
      debugPrint('Errore durante l\'inizializzazione: $e');
      return false;
    }
  }

  /// Avvia l'ascolto vocale
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
    Duration? timeout,
  }) async {
    if (!_isInitialized) {
      onError('Servizio non inizializzato');
      return;
    }

    if (_isListening) {
      debugPrint('Già in ascolto...');
      return;
    }

    try {
      await _speechToText.listen(
        onResult: (result) {
          debugPrint('Risultato vocale: ${result.recognizedWords}');
          if (result.finalResult) {
            onResult(result.recognizedWords);
          }
        },
        listenFor: timeout ?? const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        localeId: 'it_IT', // Italiano
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
      
      _isListening = true;
      debugPrint('Ascolto vocale avviato');
    } catch (e) {
      onError('Errore durante l\'avvio dell\'ascolto: $e');
    }
  }

  /// Ferma l'ascolto vocale
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speechToText.stop();
      _isListening = false;
      debugPrint('Ascolto vocale fermato');
    } catch (e) {
      debugPrint('Errore durante l\'arresto dell\'ascolto: $e');
    }
  }

  /// Cancella l'ascolto vocale
  Future<void> cancelListening() async {
    if (!_isListening) return;

    try {
      await _speechToText.cancel();
      _isListening = false;
      debugPrint('Ascolto vocale cancellato');
    } catch (e) {
      debugPrint('Errore durante la cancellazione dell\'ascolto: $e');
    }
  }

  /// Ottieni le lingue disponibili
  Future<List<LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) return [];
    return await _speechToText.locales();
  }

  /// Controlla se il microfono ha il permesso
  Future<bool> hasMicrophonePermission() async {
    return await Permission.microphone.isGranted;
  }

  /// Handler per errori
  void _onError(dynamic error) {
    debugPrint('Errore Speech-to-Text: $error');
    _isListening = false;
  }

  /// Handler per cambi di stato
  void _onStatus(String status) {
    debugPrint('Stato Speech-to-Text: $status');
    
    switch (status) {
      case 'listening':
        _isListening = true;
        break;
      case 'notListening':
      case 'done':
        _isListening = false;
        break;
    }
  }

  /// Rilascia le risorse
  void dispose() {
    if (_isListening) {
      cancelListening();
    }
  }
}