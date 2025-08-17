import 'package:shared_preferences/shared_preferences.dart';

class TutorialStorage {
  static const String _keyPrefix = 'tutorial_';
  static const String _disabledSuffix = '_disabled';

  /// Controlla se il tutorial deve essere mostrato
  /// Di default tutti i tutorial sono abilitati (true)
  Future<bool> shouldShowTutorial(String sectionKey) async {
    final prefs = await SharedPreferences.getInstance();
    final isDisabled = prefs.getBool('$_keyPrefix$sectionKey$_disabledSuffix') ?? false;
    return !isDisabled;
  }

  /// Marca il tutorial come "non mostrare più"
  /// Questo è l'unico modo per disabilitare permanentemente un tutorial
  Future<void> disableTutorial(String sectionKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyPrefix$sectionKey$_disabledSuffix', true);
  }

  /// Riabilita un tutorial specifico
  Future<void> enableTutorial(String sectionKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$sectionKey$_disabledSuffix');
  }

  /// Riabilita tutti i tutorial
  Future<void> enableAllTutorials() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final tutorialKeys = keys.where((key) => key.startsWith(_keyPrefix));
    
    for (final key in tutorialKeys) {
      await prefs.remove(key);
    }
  }

  /// Ottiene lo stato di tutti i tutorial
  /// Restituisce una mappa con chiave = sectionKey, valore = isEnabled
  Future<Map<String, bool>> getAllTutorialStates() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final tutorialKeys = keys.where((key) => key.startsWith(_keyPrefix));
    
    final Map<String, bool> states = {};
    
    for (final key in tutorialKeys) {
      if (key.endsWith(_disabledSuffix)) {
        final sectionKey = key
            .replaceFirst(_keyPrefix, '')
            .replaceFirst(_disabledSuffix, '');
        final isDisabled = prefs.getBool(key) ?? false;
        states[sectionKey] = !isDisabled; // Inverte perché states contiene "isEnabled"
      }
    }
    
    return states;
  }

  /// Verifica se un tutorial specifico è abilitato
  Future<bool> isTutorialEnabled(String sectionKey) async {
    return await shouldShowTutorial(sectionKey);
  }

  // Mantengo questi metodi per retrocompatibilità, ma ora fanno tutti la stessa cosa
  @Deprecated('Use disableTutorial instead')
  Future<void> markTutorialCompleted(String sectionKey) async {
    // Non fa nulla - completare/saltare non disabilita più il tutorial
  }

  @Deprecated('Use disableTutorial instead')
  Future<void> markTutorialSkipped(String sectionKey) async {
    // Non fa nulla - completare/saltare non disabilita più il tutorial
  }

  @Deprecated('Use enableTutorial instead')
  Future<void> resetTutorial(String sectionKey) async {
    await enableTutorial(sectionKey);
  }

  @Deprecated('Use enableAllTutorials instead')
  Future<void> resetAllTutorials() async {
    await enableAllTutorials();
  }
}