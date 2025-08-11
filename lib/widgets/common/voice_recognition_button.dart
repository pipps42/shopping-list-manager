import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/voice_recognition_provider.dart';
import '../../models/product.dart';
import '../../utils/color_palettes.dart';
import '../../utils/constants.dart';

/// Widget per il bottone di riconoscimento vocale
class VoiceRecognitionButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final Function(List<Product>)? onVoiceResult;
  final String? heroTag;

  const VoiceRecognitionButton({
    super.key,
    this.onPressed,
    this.onVoiceResult,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceRecognitionProvider);
    final voiceNotifier = ref.read(voiceRecognitionProvider.notifier);

    return FloatingActionButton(
      heroTag: heroTag ?? "voice_recognition_fab",
      backgroundColor: voiceState.isListening
          ? AppColors.error
          : AppColors.secondary,
      foregroundColor: AppColors.textOnSecondary(context),
      onPressed: voiceState.isListening
          ? () => _stopListening(voiceNotifier)
          : () => _startListening(context, voiceNotifier),
      child: voiceState.isListening
          ? const Icon(Icons.stop)
          : const Icon(Icons.mic),
    );
  }

  void _startListening(
    BuildContext context,
    VoiceRecognitionNotifier notifier,
  ) {
    if (onPressed != null) {
      onPressed!();
    }

    // Mostra dialog di ascolto
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => VoiceListeningDialog(
        onResult: onVoiceResult,
        onCancel: () {
          notifier.cancelListening();
          Navigator.of(dialogContext).pop();
        },
      ),
    );

    // Avvia ascolto
    notifier.startListening(
      context: context,
      onResult: (products) {
        Navigator.of(context).pop(); // Chiudi dialog
        if (onVoiceResult != null) {
          onVoiceResult!(products);
        }
      },
    );
  }

  void _stopListening(VoiceRecognitionNotifier notifier) {
    notifier.cancelListening();
  }
}

/// Dialog mostrato durante l'ascolto vocale
class VoiceListeningDialog extends ConsumerWidget {
  final Function(List<Product>)? onResult;
  final VoidCallback? onCancel;

  const VoiceListeningDialog({super.key, this.onResult, this.onCancel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceRecognitionProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      title: Row(
        children: [
          Icon(Icons.mic, color: AppColors.primary, size: AppConstants.iconL),
          const SizedBox(width: AppConstants.spacingM),
          const Text('Ascolto in corso...'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animazione microfono
          SizedBox(
            height: 100,
            child: Center(
              child: voiceState.isListening
                  ? _buildListeningAnimation()
                  : _buildIdleAnimation(),
            ),
          ),

          const SizedBox(height: AppConstants.spacingL),

          // Testo istruzioni
          Text(
            voiceState.isListening ? 'Parla ora...' : 'Inizializzazione...',
            style: TextStyle(
              fontSize: AppConstants.fontL,
              color: AppColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),

          // Mostra risultato parziale se disponibile
          if (voiceState.lastResult?.isNotEmpty == true) ...[
            const SizedBox(height: AppConstants.spacingM),
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Text(
                voiceState.lastResult!,
                style: TextStyle(
                  fontSize: AppConstants.fontL,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          // Mostra errore se disponibile
          if (voiceState.lastError != null) ...[
            const SizedBox(height: AppConstants.spacingM),
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Text(
                voiceState.lastError!,
                style: TextStyle(
                  fontSize: AppConstants.fontM,
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
      actions: [TextButton(onPressed: onCancel, child: const Text('Annulla'))],
    );
  }

  Widget _buildListeningAnimation() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.2),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
            child: Icon(Icons.mic, size: 30, color: AppColors.primary),
          ),
        );
      },
      onEnd: () {
        // Ripeti animazione (questo dovrebbe essere gestito meglio con AnimationController)
      },
    );
  }

  Widget _buildIdleAnimation() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.secondary.withValues(alpha: 0.2),
      ),
      child: Icon(Icons.mic, size: 30, color: AppColors.secondary),
    );
  }
}
