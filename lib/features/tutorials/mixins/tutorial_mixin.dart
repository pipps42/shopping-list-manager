import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tutorial_provider.dart';

mixin TutorialMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool _hasShownTutorial = false;
  
  void checkAndShowTutorial(String sectionKey) {
    // Non fa nulla in initState - sarà chiamato manualmente quando necessario
  }

  void checkAndShowTutorialWhenVisible(String sectionKey) {
    if (mounted && !_hasShownTutorial) {
      _hasShownTutorial = true;
      final tutorialService = ref.read(tutorialServiceProvider);
      tutorialService.checkAndShowTutorial(context, sectionKey);
    }
  }

  void showTutorialManually(String sectionKey) {
    final tutorialService = ref.read(tutorialServiceProvider);
    tutorialService.showTutorialManually(context, sectionKey);
  }

  Future<void> enableTutorial(String sectionKey) async {
    final notifier = ref.read(tutorialNotifierProvider.notifier);
    await notifier.enableTutorial(sectionKey);
  }

  Future<void> enableAllTutorials() async {
    final notifier = ref.read(tutorialNotifierProvider.notifier);
    await notifier.enableAllTutorials();
  }
}