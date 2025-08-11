import 'package:fuzzywuzzy/applicable.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

/// Un Applicable che usa tokenSetRatio come base e penalizza i match
/// con grande differenza di numero di parole tra query e candidate.
class LengthAwareRatio implements Applicable {
  // Normalizzazione minimale
  String _normalize(String s) {
    return s
        .toLowerCase()
        .replaceAll(RegExp(r"[^\w\s]"), ' ') // rimuove punteggiatura
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  int _wordCount(String s) {
    if (s.isEmpty) return 0;
    return s.split(' ').where((w) => w.isNotEmpty).length;
  }

  @override
  int apply(String s1, String s2) {
    final a = _normalize(s1);
    final b = _normalize(s2);

    // base usando tokenSetRatio (ignora ordine / ridondanze)
    // final base = tokenSetRatio(a, b);
    // final base = weightedRatio(a, b);
    final base = ratio(a, b);

    final qa = _wordCount(a);
    final qb = _wordCount(b);
    final diff = (qa - qb).abs();

    double factor = 1.0;

    // Regole suggerite (tweak them to taste)
    if (qa == 1 && qb > 1) {
      // query monosillabica vs phrase più lunga -> forte penalità
      factor = 0.70;
    } else if (diff >= 2) {
      // differenza di 2 o più parole -> penalità rilevante
      factor = 0.80;
    } else if (diff == 1) {
      // differenza di 1 parola -> penalità lieve
      factor = 0.92;
    }

    final scored = (base * factor).round();

    // clamp 0..100
    if (scored < 0) return 0;
    if (scored > 100) return 100;
    return scored;
  }
}
