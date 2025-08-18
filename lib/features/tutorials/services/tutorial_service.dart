import 'package:flutter/material.dart';
import '../models/tutorial_config.dart';
import '../widgets/tutorial_dialog.dart';
import 'tutorial_storage.dart';

class TutorialService {
  final TutorialStorage _storage;
  final Map<String, TutorialConfig> _configs;

  TutorialService({
    TutorialStorage? storage,
    Map<String, TutorialConfig>? configs,
  }) : _storage = storage ?? TutorialStorage(),
        _configs = configs ?? {};

  void registerTutorial(TutorialConfig config) {
    _configs[config.sectionKey] = config;
  }

  void registerTutorials(List<TutorialConfig> configs) {
    for (final config in configs) {
      registerTutorial(config);
    }
  }

  TutorialConfig? getTutorialConfig(String sectionKey) {
    return _configs[sectionKey];
  }

  Future<bool> shouldShowTutorial(String sectionKey) async {
    final config = _configs[sectionKey];
    if (config == null || !config.isEnabled || config.isEmpty) {
      return false;
    }
    
    return await _storage.shouldShowTutorial(sectionKey);
  }

  Future<void> checkAndShowTutorial(BuildContext context, String sectionKey) async {
    if (!await shouldShowTutorial(sectionKey)) {
      return;
    }

    final config = _configs[sectionKey];
    if (config == null) {
      return;
    }

    if (context.mounted) {
      await _showTutorialDialog(context, config);
    }
  }

  Future<void> _showTutorialDialog(BuildContext context, TutorialConfig config) async {
    final result = await showDialog<TutorialDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => TutorialDialog(config: config),
    );

    if (result != null) {
      switch (result) {
        case TutorialDialogResult.completed:
          // Completato - non fa nulla, il tutorial può essere mostrato di nuovo
          break;
        case TutorialDialogResult.skipped:
          // Saltato - non fa nulla, il tutorial può essere mostrato di nuovo
          break;
        case TutorialDialogResult.cancelled:
          // Cancellato - non fa nulla
          break;
        case TutorialDialogResult.neverShowAgain:
          // Disabilita permanentemente il tutorial
          await _storage.disableTutorial(config.sectionKey);
          break;
      }
    }
  }

  Future<void> showTutorialManually(BuildContext context, String sectionKey) async {
    final config = _configs[sectionKey];
    if (config == null || !config.isEnabled || config.isEmpty) {
      return;
    }

    if (context.mounted) {
      await _showTutorialDialog(context, config);
    }
  }

  Future<void> disableTutorial(String sectionKey) async {
    await _storage.disableTutorial(sectionKey);
  }

  Future<void> enableTutorial(String sectionKey) async {
    await _storage.enableTutorial(sectionKey);
  }

  Future<void> enableAllTutorials() async {
    await _storage.enableAllTutorials();
  }

  Future<bool> isTutorialEnabled(String sectionKey) async {
    return await _storage.isTutorialEnabled(sectionKey);
  }

  // Metodi deprecati per retrocompatibilità
  @Deprecated('Use disableTutorial instead')
  Future<void> markTutorialCompleted(String sectionKey) async {
    // Non fa più nulla
  }

  @Deprecated('Use disableTutorial instead')
  Future<void> markTutorialSkipped(String sectionKey) async {
    // Non fa più nulla
  }

  @Deprecated('Use enableTutorial instead')
  Future<void> resetTutorial(String sectionKey) async {
    await enableTutorial(sectionKey);
  }

  @Deprecated('Use enableAllTutorials instead')
  Future<void> resetAllTutorials() async {
    await enableAllTutorials();
  }

  List<String> getRegisteredSections() {
    return _configs.keys.toList();
  }

  Future<Map<String, bool>> getAllTutorialStates() async {
    return await _storage.getAllTutorialStates();
  }
}