/// Servizio per il parsing del testo vocale e l'estrazione di nomi prodotti
class VoiceTextParser {
  static final VoiceTextParser _instance = VoiceTextParser._internal();
  factory VoiceTextParser() => _instance;
  VoiceTextParser._internal();

  /// Parole da rimuovere completamente dal testo
  static const List<String> _stopWords = [
    // Verbi di azione
    'prendiamo', 'prendi', 'prendo', 'prendere',
    'compriamo', 'compra', 'compro', 'comprare',
    'metti', 'metto', 'mettere', 'mettiamo', 'mettete',
    'aggiungi', 'aggiungo', 'aggiungere', 'aggiungiamo', 'aggiungete',
    'serve', 'servono', 'servire', 'serviamo', 'servite',
    'bisogna', 'bisognano', 'bisognare',
    'occorre', 'occorrono', 'occorrere',
    'voglio', 'vuoi', 'vuole', 'vogliamo', 'volete', 'vogliono',
    'desidero',
    'desideri',
    'desidera',
    'desideriamo',
    'desiderate',
    'desiderano',
    'devo', 'devi', 'deve', 'dobbiamo', 'dovete', 'devono',
    'posso', 'puoi', 'può', 'possiamo', 'potete', 'possono',
    'vuole', 'ci', 'mi', 'ti', 'gli', 'le', 'vi',

    // Congiunzioni principali
    'e', 'ed', 'o', 'od', 'poi', 'quindi', 'anche', 'pure', 'oltre',

    // Marcatori discorsivi
    'allora', 'dunque', 'ecco', 'senti', 'ah', 'eh', 'oh', 'uh',
    'beh', 'insomma', 'vabbè',
    'bene', 'ok', 'va', 'vero', 'sì', 'no',
    'dopo', 'adesso', 'ora', 'già',

    // Espressioni colloquiali di contesto
    'dimenticavo', 'dimenticare', 'ricordare', 'ricordo',
    'spero', 'credo', 'penso', 'dico', 'diciamo',
    'davvero', 'ancora',

    // Articoli
    'il', 'la', 'lo', 'gli', 'le', 'i', 'l\'',
    'un', 'una', 'uno', 'un\'',

    // Verbi ausiliari
    'è', 'sono', 'sei', 'siamo', 'siete', 'essere', 'avere',
    'ho', 'hai', 'ha', 'abbiamo', 'avete', 'hanno',
    'sto', 'stai', 'sta', 'stiamo', 'state', 'stanno',

    // Pronomi
    'io', 'tu', 'lui', 'lei', 'noi', 'voi', 'loro',
    'me', 'te', 'se', 'ce', 've', 'ne',
    'questo', 'questa', 'quello', 'quella', 'questi', 'queste',
    'quelli', 'quelle', 'stesso', 'stessa', 'stessi', 'stesse',

    // Parole di contesto che non sono prodotti
    'tutto', 'niente', 'nulla', 'cosa', 'come', 'quando', 'dove',
    'perché', 'che', 'chi', 'cui', 'quale', 'quali',
    'tanto', 'molto', 'poco', 'troppo', 'abbastanza', 'piuttosto',
    'sempre', 'mai', 'spesso', 'raramente', 'qualche', 'volta',

    // Aggettivi possessivi
    'mio', 'mia', 'mie', 'miei',
    'tuo', 'tuoi', 'tua', 'tue',
    'suo', 'sua', 'suoi', 'sue',
    'nostro', 'nostra', 'nostri', 'nostre',
    'vostro', 'vostra', 'vostri', 'vostre',

    // Aggettivi qualitativi molto generici
    'buono', 'buona', 'buoni', 'buone',
    'bello', 'bella', 'belli', 'belle', 'bell\'',
    'grande', 'grandi', 'piccolo', 'piccola', 'piccoli', 'piccole',

    // Quantificatori numerici puri
    'uno',
    'due',
    'tre',
    'quattro',
    'cinque',
    'sei',
    'sette',
    'otto',
    'nove',
    'dieci',
    'mezzo', 'mezza', 'mezze',
    'primo', 'prima', 'primi', 'prime',
    'secondo', 'seconda', 'secondi', 'seconde',

    // Preposizioni articolate
    'del', 'della', 'dello', 'degli', 'delle', 'dei',
    'dal', 'dalla', 'dallo', 'dagli', 'dalle', 'dai',
    'nel', 'nella', 'nello', 'negli', 'nelle', 'nei',
    'sul', 'sulla', 'sullo', 'sugli', 'sulle', 'sui',
    'col', 'cogli', 'colle',

    // Avverbi di quantità
    'più', 'meno', 'tanto', 'po\'', 'poco', 'troppo', 'abbastanza',
    'almeno', 'circa', 'quasi', 'proprio', 'davvero', 'altro', 'tot',

    // Verbi comuni
    'fare', 'fatto', 'faccio', 'fai', 'fa', 'facciamo', 'fate', 'fanno',
    'dire', 'detto', 'dico', 'dici', 'dice', 'diciamo', 'dite', 'dicono',
    'andare', 'vado', 'vai', 'va', 'andiamo', 'andate', 'vanno',
    'stare', 'sto', 'stai', 'sta', 'stiamo', 'state', 'stanno',
    'vedere', 'vedo', 'vedi', 'vede', 'vediamo', 'vedete', 'vedono',
    'sentire', 'sento', 'senti', 'sente', 'sentiamo', 'sentite', 'sentono',
    'trovare', 'trovo', 'trovi', 'trova', 'troviamo', 'trovate', 'trovano',
    'usare', 'uso', 'usi', 'usa', 'usiamo', 'usate', 'usano',
    'mancare', 'manco', 'manchi', 'manca', 'manchiamo', 'mancate', 'mancano',
    'finire', 'finisco', 'finisci', 'finisce', 'finiamo', 'finite', 'finiscono',
    'bastare', 'basto', 'basti', 'basta', 'bastiamo', 'bastate', 'bastano',
    'piacere', 'piaccio', 'piaci', 'piace', 'piacciamo', 'piacete', 'piacciono',
    'venire', 'vengo', 'vieni', 'viene', 'veniamo', 'venite', 'vengono',
    'uscire', 'esco', 'esci', 'esce', 'usciamo', 'uscite', 'escono',
    'sapere', 'so', 'sai', 'sa', 'sappiamo', 'sapete', 'sanno',
    'dovere', 'devo', 'devi', 'deve', 'dobbiamo', 'dovete', 'devono',
    'potere', 'posso', 'puoi', 'può', 'possiamo', 'potete', 'possono',
    'volere', 'voglio', 'vuoi', 'vuole', 'vogliamo', 'volete', 'vogliono',
    'parlare', 'parlo', 'parli', 'parla', 'parliamo', 'parlate', 'parlano',
    'chiamare',
    'chiamo',
    'chiami',
    'chiama',
    'chiamiamo',
    'chiamate',
    'chiamano',
    'comprare',
    'compro',
    'compri',
    'compra',
    'compriamo',
    'comprate',
    'comprano',
    'prendere',
    'prendo',
    'prendi',
    'prende',
    'prendiamo',
    'prendete',
    'prendono',
  ];

  /// Pattern da preservare come nomi prodotto composti
  static final List<RegExp> _compoundPatterns = [
    // X di Y (es: "olio di oliva", "pane di segale")
    RegExp(r'\b\w+\s+di\s+\w+\b'),
    // X da Y (es: "carta da forno")
    RegExp(r'\b\w+\s+da\s+\w+\b'),
    // X per Y (es: "sapone per piatti")
    RegExp(r'\b\w+\s+per\s+\w+\b'),
    // X fresco/fresca/fresche/freschi
    RegExp(r'\b\w+\s+fresc[hoiae]+\b'),
    // X igienica/igienico/igienici/igieniche
    RegExp(r'\b\w+\s+igienic[oaihe]+\b'),
    // X bio
    RegExp(r'\b\w+\s+bio\b'),
    // X senza Y (es: "pasta senza glutine")
    RegExp(r'\b\w+\s+senza\s+\w+\b'),
    // X vegano/vegana/vegani/vegane
    RegExp(r'\b\w+\s+vegan[oaie]+\b'),
    // X naturale/naturale/naturali/naturali
    RegExp(r'\b\w+\s+naturale[iaie]+\b'),
    // X grosso/grossa/grosse/grossi
    RegExp(r'\b\w+\s+gross[oaie]+\b'),
    // X in Y (es: "tonno in scatola")
    RegExp(r'\b\w+\s+in\s+\w+\b'),
    // X al/alla Y (es: "pasta al pomodoro")
    RegExp(r'\b\w+\s+alla?\s+\w+\b'),
  ];

  /// Step 1: Normalizzazione con gestione apostrofi
  String _normalizeText(String text) {
    String normalized = text.toLowerCase().trim();

    // Gestione apostrofi speciali
    // d' diventa "di "
    normalized = normalized.replaceAll(RegExp(r"\bd'"), 'di ');

    // Rimuovi punteggiatura e apostrofi rimanenti
    normalized = normalized.replaceAll(
      RegExp(
        r'[.,!?;:()"\'
        '-]',
      ),
      ' ',
    );
    normalized = normalized.replaceAll(RegExp(r'\.{2,}'), ' ');

    // Normalizza spazi multipli
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');

    return normalized.trim();
  }

  /// Step 2: Rimuovi tutte le stop words
  String _removeStopWords(String text) {
    String cleaned = text;

    // Rimuovi ogni stop word
    for (final stopWord in _stopWords) {
      cleaned = cleaned.replaceAll(
        RegExp('\\b${RegExp.escape(stopWord)}\\b', caseSensitive: false),
        ' ',
      );
    }

    // Pulisci spazi multipli
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    return cleaned;
  }

  /// Step 3: Separazione parole con gestione compound
  List<String> _extractWords(String text) {
    final Set<String> results = {};

    // Prima estrai i compound patterns
    for (final pattern in _compoundPatterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        final compound = match.group(0)!.trim();
        if (compound.isNotEmpty) {
          results.add(compound);
        }
      }
    }

    // Poi estrai le parole singole, escludendo quelle già catturate nei compound
    String remainingText = text;
    for (final pattern in _compoundPatterns) {
      remainingText = remainingText.replaceAll(pattern, ' ');
    }

    final singleWords = remainingText
        .split(' ')
        .where((word) => word.trim().isNotEmpty);
    for (final word in singleWords) {
      final trimmedWord = word.trim();
      if (trimmedWord.length > 1) {
        results.add(trimmedWord);
      }
    }

    return results.toList();
  }

  /// Metodo principale per estrarre prodotti dal testo vocale
  List<String> parseVoiceText(String voiceText) {
    if (voiceText.isEmpty) return [];

    // Step 1: Normalizzazione
    final normalizedText = _normalizeText(voiceText);

    // Step 2: Rimozione stop words
    final cleanedText = _removeStopWords(normalizedText);
    print('Step 2 - Cleaned: $cleanedText');

    // Step 3: Separazione parole con compound
    final products = _extractWords(cleanedText);
    print('Step 3 - Extracted: $products');
    print('Prodotti estratti: ${products.length}');

    return products;
  }
}
