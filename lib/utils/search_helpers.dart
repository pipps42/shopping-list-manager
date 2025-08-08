/// Utility per il filtraggio e ordinamento di ricerca
class SearchHelpers {
  /// Ordina i risultati di ricerca dando priorità a quelli che iniziano con la query
  static List<T> sortBySearchRelevance<T>(
    List<T> items,
    String query,
    String Function(T) nameExtractor,
  ) {
    if (query.isEmpty) return items;

    final queryLower = query.toLowerCase();
    
    // Separa i risultati in due liste
    final startsWith = <T>[];
    final contains = <T>[];
    
    for (final item in items) {
      final nameLower = nameExtractor(item).toLowerCase();
      if (nameLower.startsWith(queryLower)) {
        startsWith.add(item);
      } else if (nameLower.contains(queryLower)) {
        contains.add(item);
      }
    }
    
    // Combina i risultati: prima quelli che iniziano, poi gli altri
    return [...startsWith, ...contains];
  }
}