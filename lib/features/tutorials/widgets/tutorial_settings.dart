import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import '../providers/tutorial_provider.dart';
import '../models/tutorial_configs.dart';

class TutorialSettings extends ConsumerWidget {
  const TutorialSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutorialStates = ref.watch(allTutorialStatesProvider);
    final tutorialNotifier = ref.watch(tutorialNotifierProvider.notifier);

    return Card(
      margin: const EdgeInsets.all(AppConstants.paddingM),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.school,
                  color: AppColors.accent,
                ),
                const SizedBox(width: AppConstants.spacingM),
                Text(
                  'Tutorial',
                  style: TextStyle(
                    fontSize: AppConstants.fontXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              'Gestisci i tutorial per ogni sezione dell\'app',
              style: TextStyle(
                fontSize: AppConstants.fontL,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),
            
            tutorialStates.when(
              data: (states) => _buildTutorialList(context, ref, states),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Text(
                'Errore nel caricamento: $error',
                style: TextStyle(color: AppColors.error),
              ),
            ),
            
            const SizedBox(height: AppConstants.spacingL),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await tutorialNotifier.enableAllTutorials();
                  ref.invalidate(allTutorialStatesProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tutti i tutorial sono stati riabilitati'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Riabilita Tutti i Tutorial'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialList(
    BuildContext context,
    WidgetRef ref,
    Map<String, bool> states,
  ) {
    final sections = TutorialConfigs.getAvailableSections();
    final tutorialService = ref.read(tutorialServiceProvider);
    final tutorialNotifier = ref.read(tutorialNotifierProvider.notifier);

    return Column(
      children: sections.map((sectionKey) {
        final config = TutorialConfigs.getConfig(sectionKey);
        if (config == null) return const SizedBox.shrink();

        final isCompleted = states['${sectionKey}_completed'] ?? false;
        final isSkipped = states['${sectionKey}_skipped'] ?? false;
        
        String statusText;
        Color statusColor;
        
        if (isCompleted) {
          statusText = 'Completato';
          statusColor = AppColors.success;
        } else if (isSkipped) {
          statusText = 'Saltato';
          statusColor = AppColors.warning;
        } else {
          statusText = 'Non visto';
          statusColor = AppColors.textSecondary(context);
        }

        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.spacingS),
          child: ListTile(
            leading: const Icon(Icons.school),
            title: Text(config.title),
            subtitle: Text(
              'Stato: $statusText',
              style: TextStyle(color: statusColor),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    tutorialService.showTutorialManually(context, sectionKey);
                  },
                  icon: const Icon(Icons.play_arrow),
                  tooltip: 'Mostra tutorial',
                ),
                IconButton(
                  onPressed: () async {
                    await tutorialNotifier.enableTutorial(sectionKey);
                    ref.invalidate(allTutorialStatesProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Riabilita tutorial',
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}