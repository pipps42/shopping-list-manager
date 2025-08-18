import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tutorial_config.dart';
import '../services/tutorial_service.dart';
import '../services/tutorial_storage.dart';

final tutorialStorageProvider = Provider<TutorialStorage>((ref) {
  return TutorialStorage();
});

final tutorialServiceProvider = Provider<TutorialService>((ref) {
  final storage = ref.read(tutorialStorageProvider);
  return TutorialService(storage: storage);
});

final tutorialConfigsProvider = StateProvider<Map<String, TutorialConfig>>((ref) {
  return {};
});

final tutorialStateProvider = FutureProvider.family<bool, String>((ref, sectionKey) async {
  final service = ref.read(tutorialServiceProvider);
  return await service.shouldShowTutorial(sectionKey);
});

final allTutorialStatesProvider = FutureProvider<Map<String, bool>>((ref) async {
  final service = ref.read(tutorialServiceProvider);
  return await service.getAllTutorialStates();
});

class TutorialNotifier extends StateNotifier<AsyncValue<void>> {
  final TutorialService _service;

  TutorialNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> disableTutorial(String sectionKey) async {
    state = const AsyncValue.loading();
    try {
      await _service.disableTutorial(sectionKey);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> enableTutorial(String sectionKey) async {
    state = const AsyncValue.loading();
    try {
      await _service.enableTutorial(sectionKey);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> enableAllTutorials() async {
    state = const AsyncValue.loading();
    try {
      await _service.enableAllTutorials();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Metodi deprecati per retrocompatibilità
  @Deprecated('Use enableTutorial instead')
  Future<void> resetTutorial(String sectionKey) async {
    await enableTutorial(sectionKey);
  }

  @Deprecated('Use enableAllTutorials instead')
  Future<void> resetAllTutorials() async {
    await enableAllTutorials();
  }
}

final tutorialNotifierProvider = StateNotifierProvider<TutorialNotifier, AsyncValue<void>>((ref) {
  final service = ref.read(tutorialServiceProvider);
  return TutorialNotifier(service);
});