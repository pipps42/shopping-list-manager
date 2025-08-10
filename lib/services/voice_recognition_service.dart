import 'package:manual_speech_to_text/manual_speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'voice_text_parser.dart';
import 'database_service.dart';
import '../models/product.dart';
import 'dart:async';
import 'package:flutter/material.dart';

/// Servizio per la gestione del riconoscimento vocale con ManualStt
class VoiceRecognitionService {
  static final VoiceRecognitionService _instance =
      VoiceRecognitionService._internal();
  factory VoiceRecognitionService() => _instance;
  VoiceRecognitionService._internal();

  ManualSttController? _sttController;
  final VoiceTextParser _parser = VoiceTextParser();

  // DatabaseService iniettato tramite dependency injection
  late final DatabaseService _databaseService;

  bool _isInitialized = false;
  bool _isListening = false;

  // Risultati della fuzzy search accumulati durante l'ascolto
  final List<Product> _accumulatedResults = [];

  // Stream per comunicare i risultati parziali
  final StreamController<List<Product>> _resultsStreamController =
      StreamController<List<Product>>.broadcast();

  Stream<List<Product>> get resultsStream => _resultsStreamController.stream;

  // Getters per lo stato
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  bool get isAvailable => _sttController != null;

  // Timer master per il controllo dei 60 secondi
  Timer? _masterTimer;

  // Callbacks salvati
  Function(String)? _savedOnResult;
  Function(String)? _savedOnError;

  // Track dell'ultimo testo processato per processing incrementale
  String _lastProcessedText = '';

  /// Inizializza il servizio di riconoscimento vocale con ManualStt
  Future<bool> initialize([
    DatabaseService? databaseService,
    BuildContext? context,
  ]) async {
    if (_isInitialized) return true;

    try {
      // Inietta DatabaseService se fornito, altrimenti usa il singleton
      _databaseService = databaseService ?? DatabaseService();

      // Richiedi permesso microfono (manual_stt lo gestisce automaticamente, ma lo facciamo per sicurezza)
      final permissionStatus = await Permission.microphone.request();
      if (permissionStatus != PermissionStatus.granted) {
        debugPrint('Permesso microfono negato');
        return false;
      }

      _isInitialized = true;
      debugPrint(
        '✅ Voice Recognition Service (ManualStt) inizializzato con successo',
      );
      return true;
    } catch (e) {
      debugPrint('❌ Errore durante l\'inizializzazione: $e');
      return false;
    }
  }

  /// Avvia l'ascolto vocale con ManualStt (controllo completo per 60 secondi)
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
    Duration? timeout,
    BuildContext? context,
  }) async {
    if (!_isInitialized) {
      onError('Servizio non inizializzato');
      return;
    }

    if (_isListening) {
      debugPrint('⚠️ Già in ascolto...');
      return;
    }

    // Salva i callback
    _savedOnResult = onResult;
    _savedOnError = onError;

    // Pulisci risultati precedenti e reset tracking
    clearAccumulatedResults();
    _lastProcessedText = '';

    // Avvia timer master per 60 secondi
    _masterTimer?.cancel();
    _masterTimer = Timer(const Duration(seconds: 60), () {
      debugPrint('⏰ Timer master scaduto (60s) - Fine ascolto automatica');
      _finalizeBatchedListening();
    });

    try {
      // Inizializza ManualSttController con context se fornito
      if (_sttController == null && context != null) {
        _sttController = ManualSttController(context);
        debugPrint('🎛️ ManualSttController inizializzato');
      }

      if (_sttController == null) {
        onError('Context richiesto per l\'inizializzazione di ManualStt');
        return;
      }

      // Configura i callback per ManualStt
      _sttController!.listen(
        onListeningStateChanged: (ManualSttState state) {
          debugPrint('🎙️ Stato ManualStt: $state');
          switch (state) {
            case ManualSttState.listening:
              _isListening = true;
              break;
            case ManualSttState.paused:
              // ManualStt gestisce pause/resume automaticamente
              break;
            case ManualSttState.stopped:
              _isListening = false;
              break;
          }
        },
        onListeningTextChanged: (String text) {
          debugPrint('📝 Testo ManualStt: "$text"');

          // Processa il testo in tempo reale con logica incrementale
          _processPartialResult(text);
        },
        onSoundLevelChanged: (double level) {
          // Gestisci il livello audio se necessario
        },
      );

      // Avvia l'ascolto manuale (startStt è void, non restituisce Future)
      _sttController!.startStt();
      _isListening = true;

      debugPrint('🚀 ManualStt avviato - Ascolto continuo per 60 secondi');
    } catch (e) {
      debugPrint('❌ Errore durante l\'avvio ManualStt: $e');
      onError('Errore durante l\'avvio dell\'ascolto: $e');
    }
  }

  /// Ferma l'ascolto vocale e processa tutti i risultati
  Future<void> stopListening() async {
    if (!_isListening) return;

    debugPrint('🛑 Stop manuale richiesto');
    await _finalizeBatchedListening();
  }

  /// Cancella l'ascolto vocale e scarta tutti i risultati
  Future<void> cancelListening() async {
    if (!_isListening) return;

    try {
      _masterTimer?.cancel();

      if (_sttController != null) {
        _sttController!.stopStt();
      }

      _isListening = false;
      _lastProcessedText = '';
      clearAccumulatedResults();

      debugPrint('❌ Ascolto cancellato - risultati scartati');
    } catch (e) {
      debugPrint('Errore durante la cancellazione dell\'ascolto: $e');
    }
  }

  /// Ottieni le lingue disponibili
  Future<List<String>> getAvailableLocales() async {
    // ManualStt non espone questa funzionalità direttamente
    return ['it_IT', 'en_US'];
  }

  /// Controlla se il microfono ha il permesso
  Future<bool> hasMicrophonePermission() async {
    return await Permission.microphone.isGranted;
  }

  /// Processa un risultato parziale con logica incrementale
  Future<void> _processPartialResult(String currentText) async {
    if (currentText.trim().isEmpty) return;

    // Estrai solo la parte nuova del testo (incrementale)
    final newTextPart = _extractNewTextPart(currentText);
    if (newTextPart.trim().isEmpty) return;

    debugPrint(
      '🎙️ Processing incremental text: "$newTextPart" (from: "$currentText")',
    );

    // Aggiorna il tracking
    _lastProcessedText = currentText;

    // Parsing asincrono solo della parte nuova
    final newProducts = await _parseTextAsync(newTextPart);

    if (newProducts.isNotEmpty) {
      // Fuzzy search asincrona sui nuovi prodotti estratti
      final searchResults = await _performFuzzySearchAsync(newProducts);

      if (searchResults.isNotEmpty) {
        // Aggiungi ai risultati accumulati (evita duplicati)
        for (final product in searchResults) {
          if (!_accumulatedResults.any((p) => p.id == product.id)) {
            _accumulatedResults.add(product);
          }
        }

        // Invia i risultati aggiornati attraverso lo stream
        _resultsStreamController.add(List.from(_accumulatedResults));

        debugPrint(
          '✅ Risultati incrementali accumulati: ${_accumulatedResults.length}',
        );
      }
    }
  }

  /// Estrae solo la parte nuova del testo rispetto all'ultimo processing
  String _extractNewTextPart(String currentText) {
    if (_lastProcessedText.isEmpty) return currentText;

    // Se il testo corrente contiene quello precedente, estrai solo la differenza
    if (currentText.startsWith(_lastProcessedText)) {
      final newPart = currentText.substring(_lastProcessedText.length).trim();
      return newPart;
    }

    // Se non c'è continuità, processa tutto
    return currentText;
  }

  /// Parsing asincrono del testo vocale
  Future<List<String>> _parseTextAsync(String text) async {
    return await Future.microtask(() {
      return _parser.parseVoiceText(text);
    });
  }

  /// Fuzzy search asincrona sui prodotti
  Future<List<Product>> _performFuzzySearchAsync(
    List<String> productNames,
  ) async {
    final List<Product> results = [];

    for (final productName in productNames) {
      if (productName.trim().isEmpty) continue;

      try {
        // Cerca prodotti che contengono il nome
        final products = await _databaseService.searchProducts(productName);
        results.addAll(products);
        debugPrint(
          'Fuzzy search ha estratto: "${products.length} results for $productName"',
        );
      } catch (e) {
        debugPrint('Errore nella fuzzy search per "$productName": $e');
      }
    }

    return results;
  }

  /// Ottieni i risultati accumulati
  List<Product> getAccumulatedResults() {
    return List.from(_accumulatedResults);
  }

  /// Pulisci i risultati accumulati
  void clearAccumulatedResults() {
    _accumulatedResults.clear();
    _resultsStreamController.add([]);
  }

  /// Finalizza tutto il processo di listening
  Future<void> _finalizeBatchedListening() async {
    try {
      _masterTimer?.cancel();

      if (_isListening && _sttController != null) {
        _sttController!.stopStt();
      }

      _isListening = false;
      _lastProcessedText = '';

      // Chiama il callback finale con tutti i risultati accumulati
      if (_savedOnResult != null && _accumulatedResults.isNotEmpty) {
        final allResults = _accumulatedResults.map((p) => p.name).join(', ');
        debugPrint(
          '🏁 Finalizing con ${_accumulatedResults.length} risultati: $allResults',
        );
        _savedOnResult!(allResults);
      }

      debugPrint('✅ ManualStt listening finalizzato');
    } catch (e) {
      debugPrint('❌ Errore durante finalizzazione: $e');
      if (_savedOnError != null) {
        _savedOnError!('Errore durante finalizzazione: $e');
      }
    }
  }

  /// Rilascia le risorse
  void dispose() {
    _masterTimer?.cancel();
    if (_isListening) {
      cancelListening();
    }
    if (_sttController != null) {
      _sttController!.dispose();
    }
    _resultsStreamController.close();
  }
}
