import 'package:manual_speech_to_text/manual_speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:shopping_list_manager/utils/length_aware_ratio.dart';
import 'voice_text_parser.dart';
import 'database_service.dart';
import '../models/product.dart';
import 'dart:async';
import 'package:flutter/material.dart';

/// Rappresenta un match di n-gramma con informazioni complete per il conflict resolution
class NgramMatch {
  final String ngram; // "aceto balsamico"
  final int startIndex; // 0 (indice prima parola)
  final int endIndex; // 1 (indice ultima parola)
  final int ngramLength; // 2 (numero parole)
  final Product matchedProduct; // Prodotto matchato
  final int fuzzyScore; // 88 (punteggio FuzzyWuzzy)

  const NgramMatch({
    required this.ngram,
    required this.startIndex,
    required this.endIndex,
    required this.ngramLength,
    required this.matchedProduct,
    required this.fuzzyScore,
  });

  @override
  String toString() =>
      'NgramMatch($ngram -> ${matchedProduct.name}, score: $fuzzyScore, indices: $startIndex-$endIndex)';
}

/// Servizio per la gestione del riconoscimento vocale con ManualStt
class VoiceRecognitionService {
  static final VoiceRecognitionService _instance =
      VoiceRecognitionService._internal();
  factory VoiceRecognitionService() => _instance;
  VoiceRecognitionService._internal();

  late ManualSttController _sttController;
  final VoiceTextParser _parser = VoiceTextParser();

  // DatabaseService iniettato tramite dependency injection
  late final DatabaseService _databaseService;

  bool _isInitialized = false;
  bool _isListening = false;

  // Getters per lo stato
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;

  // Timer master per il controllo dei 60 secondi
  Timer? _masterTimer;

  // Callbacks salvati
  Function(String)? _savedOnResult;
  Function(String)? _savedOnError;

  // Testo completo dell'ultimo riconoscimento vocale
  String _finalRecognizedText = '';

  // Cache dei prodotti con nomi completi
  final List<Product> _cachedProducts = [];
  final List<String> _productNames = [];

  /// Inizializza il servizio di riconoscimento vocale con ManualStt
  Future<bool> initialize([
    DatabaseService? databaseService,
    BuildContext? context,
  ]) async {
    if (_isInitialized) return true;

    try {
      // Inietta DatabaseService se fornito, altrimenti usa il singleton
      _databaseService = databaseService ?? DatabaseService();

      // Carica e normalizza tutti i prodotti per la cache
      await _loadAndCacheProducts();

      // Richiedi permesso microfono (manual_stt lo gestisce automaticamente, ma lo facciamo per sicurezza)
      final permissionStatus = await Permission.microphone.request();
      if (permissionStatus != PermissionStatus.granted) {
        debugPrint('Permesso microfono negato');
        return false;
      }

      _isInitialized = true;
      debugPrint(
        '✅ Voice Recognition Service inizializzato con ${_cachedProducts.length} prodotti',
      );
      return true;
    } catch (e) {
      debugPrint('❌ Errore durante l\'inizializzazione: $e');
      return false;
    }
  }

  /// Avvia l'ascolto vocale con ManualStt (controllo completo per 60 secondi)
  void startListening({
    required Function(String) onResult,
    required Function(String) onError,
    required Duration timeout,
    required BuildContext context,
  }) {
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

    // Reset testo
    _finalRecognizedText = '';

    // Avvia timer master per 60 secondi
    _masterTimer?.cancel();
    _masterTimer = Timer(timeout, () {
      debugPrint(
        '⏰ Timer master scaduto (${timeout.inSeconds}s) - Fine ascolto automatica',
      );
      _finalizeListening();
    });

    try {
      // Inizializza ManualSttController con context se fornito
      _sttController = ManualSttController(context);
      _sttController.pauseIfMuteFor = timeout;
      debugPrint('🎛️ ManualSttController inizializzato');

      // Configura i callback per ManualStt
      _sttController.listen(
        onListeningStateChanged: (ManualSttState state) {
          debugPrint('🎙️ Stato ManualStt: $state');
          switch (state) {
            case ManualSttState.listening:
              _isListening = true;
              break;
            case ManualSttState.paused:
              // stopListening();
              debugPrint('⏸️ ManualStt in pausa - ascolto sospeso');
              break;
            case ManualSttState.stopped:
              _isListening = false;
              break;
          }
        },
        onListeningTextChanged: (String text) {
          debugPrint('📝 Testo ManualStt: "$text"');

          // Salva l'ultimo testo ricevuto (processamento finale a fine ascolto)
          _finalRecognizedText = text;
        },
        onSoundLevelChanged: (double level) {
          // Gestisci il livello audio se necessario
        },
      );

      // Avvia l'ascolto manuale (startStt è void, non restituisce Future)
      _sttController.startStt();
      _isListening = true;

      debugPrint(
        '🚀 ManualStt avviato - Ascolto continuo per ${timeout.inSeconds} secondi',
      );
    } catch (e) {
      debugPrint('❌ Errore durante l\'avvio ManualStt: $e');
      onError('Errore durante l\'avvio dell\'ascolto: $e');
    }
  }

  /// Ferma l'ascolto vocale e processa tutti i risultati
  void stopListening() {
    if (!_isListening) return;

    debugPrint('🛑 Stop manuale richiesto');
    _finalizeListening();
  }

  /// Cancella l'ascolto vocale e scarta tutti i risultati
  void cancelListening() {
    if (!_isListening) return;

    try {
      _masterTimer?.cancel();
      _sttController.stopStt();
      _isListening = false;
      _finalRecognizedText = '';

      debugPrint('❌ Ascolto cancellato - risultati scartati');
    } catch (e) {
      debugPrint('Errore durante la cancellazione dell\'ascolto: $e');
    }
  }

  /// Controlla se il microfono ha il permesso
  Future<bool> hasMicrophonePermission() async {
    return await Permission.microphone.isGranted;
  }

  /// Carica tutti i prodotti dal database e li mette in cache
  Future<void> _loadAndCacheProducts() async {
    try {
      final allProducts = await _databaseService.getAllProducts();
      _cachedProducts.clear();
      _productNames.clear();

      for (final product in allProducts) {
        _cachedProducts.add(product);
        _productNames.add(product.name.toLowerCase());
      }

      debugPrint('📦 Cache caricata: ${_cachedProducts.length} prodotti');
    } catch (e) {
      debugPrint('❌ Errore durante caricamento cache prodotti: $e');
      rethrow;
    }
  }

  /// Estrae prodotti dal testo finale usando N-grammi + FuzzyWuzzy con voti cumulativi
  List<Product> _extractProductsFromFinalText(String text) {
    if (text.trim().isEmpty) return [];

    try {
      debugPrint('🔍 Processamento N-grammi da testo: "$text"');

      // 1. Normalizza il testo usando VoiceTextParser
      final normalizedText = _parser.normalizeText(text);
      final cleanedText = _parser.removeStopWords(normalizedText);
      debugPrint('📝 Testo normalizzato: "$cleanedText"');

      // 2. Mappa per accumulare score per indice specifico
      final Map<int, Map<String, double>> scoresByIndex = {};
      final Map<String, Product> productMap = {};

      final words = cleanedText
          .toLowerCase()
          .split(' ')
          .where((w) => w.isNotEmpty)
          .toList();

      if (words.isEmpty) return [];

      // Inizializza scoresByIndex per ogni indice
      for (int i = 0; i < words.length; i++) {
        scoresByIndex[i] = <String, double>{};
      }

      // Genera n-grammi e accumula match per ogni indice specifico
      for (int n = 1; n <= 3; n++) {
        for (int i = 0; i <= words.length - n; i++) {
          final ngram = words.sublist(i, i + n).join(' ');

          // Skip n-grammi troppo corti (solo per 1-grammi)
          if (n == 1 && ngram.length <= 2) continue;

          // Trova tutti i match per questo n-gramma usando extractAll
          final matches = _findAllFuzzyMatches(ngram, i, i + n - 1, n);

          // Accumula score per ogni indice che questo n-gramma occupa
          for (final match in matches) {
            final productName = match.matchedProduct.name;
            productMap[productName] = match.matchedProduct;

            // Aggiungi lo score a tutti gli indici occupati da questo n-gramma
            for (int idx = match.startIndex; idx <= match.endIndex; idx++) {
              scoresByIndex[idx]![productName] =
                  (scoresByIndex[idx]![productName] ?? 0) + match.fuzzyScore;
            }

            debugPrint(
              '🗳️ Match: $ngram -> $productName (score: ${match.fuzzyScore}, indici: ${match.startIndex}-${match.endIndex})',
            );
          }
        }
      }

      debugPrint('🏆 Score per indice:');
      for (int i = 0; i < words.length; i++) {
        debugPrint('  Indice $i (${words[i]}):');
        final sortedProducts = scoresByIndex[i]!.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        for (final entry in sortedProducts.take(3)) {
          // Mostra solo i top 3
          debugPrint('    ${entry.key}: ${entry.value.toStringAsFixed(1)}');
        }
      }

      // 3. Risolvi conflitti: per ogni indice scegli il prodotto con score più alto
      final finalMatches = _resolveConflictsWithIndexSpecificScores(
        scoresByIndex,
        productMap,
        words,
      );

      debugPrint(
        '✅ Prodotti finali dopo risoluzione conflitti: ${finalMatches.length}',
      );
      for (final product in finalMatches) {
        debugPrint('  ${product.name}');
      }

      return finalMatches;
    } catch (e) {
      debugPrint('❌ Errore durante estrazione prodotti con N-grammi: $e');
      return [];
    }
  }

  /// Trova tutti i match fuzzy per un n-gramma usando extractAll
  List<NgramMatch> _findAllFuzzyMatches(
    String ngram,
    int startIndex,
    int endIndex,
    int ngramLength,
  ) {
    if (ngram.trim().isEmpty || ngram.length <= 2) return [];

    try {
      // Usa extractAll per ottenere tutti i match possibili
      final allMatches = extractAll(
        query: ngram,
        choices: _productNames,
        cutoff: 75, // Soglia più permissiva per catturare più match
        ratio: LengthAwareRatio(),
      );

      final List<NgramMatch> ngramMatches = [];

      for (final match in allMatches) {
        final String matchedProductName = match.choice;
        final int productIndex = _productNames.indexOf(matchedProductName);

        if (productIndex >= 0) {
          final Product matchedProduct = _cachedProducts[productIndex];
          final int fuzzyScore = match.score;

          ngramMatches.add(
            NgramMatch(
              ngram: ngram,
              startIndex: startIndex,
              endIndex: endIndex,
              ngramLength: ngramLength,
              matchedProduct: matchedProduct,
              fuzzyScore: fuzzyScore,
            ),
          );
        }
      }

      return ngramMatches;
    } catch (e) {
      debugPrint('⚠️ Errore nel fuzzy match per "$ngram": $e');
      return [];
    }
  }

  /// Risolve conflitti usando score per indice specifico: per ogni indice sceglie il prodotto con score più alto
  List<Product> _resolveConflictsWithIndexSpecificScores(
    Map<int, Map<String, double>> scoresByIndex,
    Map<String, Product> productMap,
    List<String> words,
  ) {
    if (scoresByIndex.isEmpty) return [];

    final List<Product> finalProducts = [];
    final List<bool> usedIndices = List.filled(words.length, false);

    // Itera attraverso ogni indice sequenzialmente
    for (int i = 0; i < words.length; i++) {
      // Se l'indice è già stato usato da un n-gramma precedente, saltalo
      if (usedIndices[i]) {
        continue;
      }

      final scoresForIndex = scoresByIndex[i]!;
      if (scoresForIndex.isEmpty) {
        continue;
      }

      // Trova il prodotto con score più alto per questo indice
      String bestProduct = scoresForIndex.keys.first;
      double bestScore = scoresForIndex[bestProduct]!;

      for (final entry in scoresForIndex.entries) {
        if (entry.value > bestScore) {
          bestProduct = entry.key;
          bestScore = entry.value;
        }
      }

      // Aggiungi il prodotto vincitore
      finalProducts.add(productMap[bestProduct]!);

      debugPrint(
        '🏆 Indice $i (${words[i]}): "$bestProduct" vince con score ${bestScore.toStringAsFixed(1)}',
      );

      // Determina quanti indici questo prodotto occupa (lunghezza del nome del prodotto divisa per parole)
      // Per ora segniamo solo questo indice come usato - questo è il comportamento più semplice
      // In futuro potremmo implementare logica più sofisticata per n-grammi
      usedIndices[i] = true;
    }

    return finalProducts;
  }

  /// Finalizza tutto il processo di listening e processa il testo finale
  void _finalizeListening() {
    try {
      _masterTimer?.cancel();

      if (_isListening) {
        _sttController.stopStt();
      }

      _isListening = false;

      // Processa il testo finale usando N-grammi + FuzzyWuzzy
      if (_finalRecognizedText.isNotEmpty) {
        debugPrint('🎙️ Processando testo finale: "$_finalRecognizedText"');

        final extractedProducts = _extractProductsFromFinalText(
          _finalRecognizedText,
        );

        if (extractedProducts.isNotEmpty) {
          // Chiama il callback finale con i prodotti estratti
          if (_savedOnResult != null) {
            final allResults = extractedProducts.map((p) => p.name).join(', ');
            debugPrint(
              '🏁 Finalizing con ${extractedProducts.length} prodotti estratti: $allResults',
            );
            _savedOnResult!(allResults);
          }
        } else {
          debugPrint(
            '⚠️ Nessun prodotto estratto dal testo: "$_finalRecognizedText"',
          );
          if (_savedOnResult != null) {
            _savedOnResult!('Nessun prodotto riconosciuto');
          }
        }
      } else {
        debugPrint('⚠️ Nessun testo ricevuto durante l\'ascolto');
        if (_savedOnResult != null) {
          _savedOnResult!('Nessun testo riconosciuto');
        }
      }

      // Reset finale
      _finalRecognizedText = '';
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
    _sttController.dispose();
  }
}
