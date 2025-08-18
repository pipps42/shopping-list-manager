import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loyalty_card.dart';
import '../providers/loyalty_cards_provider.dart';
import '../widgets/common/empty_state_widget.dart';
import '../widgets/common/error_state_widget.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/common/base_dialog.dart';
import '../widgets/loyalty_cards/loyalty_card_tile.dart';
import '../widgets/loyalty_cards/add_loyalty_card_dialog.dart';
import '../widgets/loyalty_cards/full_screen_image_viewer.dart';
import '../utils/constants.dart';
import '../utils/color_palettes.dart';
import '../features/tutorials/mixins/tutorial_mixin.dart';

class LoyaltyCardsScreen extends ConsumerStatefulWidget {
  const LoyaltyCardsScreen({super.key});

  @override
  ConsumerState<LoyaltyCardsScreen> createState() => _LoyaltyCardsScreenState();
}

class _LoyaltyCardsScreenState extends ConsumerState<LoyaltyCardsScreen>
    with TutorialMixin {
  @override
  void initState() {
    super.initState();
    // Tutorial gestito dal MainScreen
  }

  @override
  Widget build(BuildContext context) {
    final loyaltyCardsState = ref.watch(loyaltyCardsProvider);

    return Scaffold(
      body: loyaltyCardsState.when(
        data: (cards) => _buildCardsGrid(context, ref, cards),
        loading: () =>
            const LoadingWidget(message: 'Caricamento carte fedeltà...'),
        error: (error, stack) => ErrorStateWidget(
          message: 'Errore nel caricamento delle carte: $error',
          onRetry: () => ref.invalidate(loyaltyCardsProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "loyalty_cards_fab",
        onPressed: () => _showAddCardDialog(context, ref),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textOnSecondary(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCardsGrid(
    BuildContext context,
    WidgetRef ref,
    List<LoyaltyCard> cards,
  ) {
    if (cards.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.credit_card_outlined,
        title: 'Nessuna carta fedeltà',
        subtitle: 'Aggiungi la tua prima carta fedeltà con il pulsante +',
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: AppConstants.paddingM,
        left: AppConstants.paddingM,
        right: AppConstants.paddingM,
        bottom: AppConstants.listBottomSpacing, // Spazio per FAB
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: AppConstants.paddingM,
          mainAxisSpacing: AppConstants.paddingM,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return LoyaltyCardTile(
            card: card,
            onTap: () => _openFullScreenImage(context, card),
            onEdit: () => _showEditCardDialog(context, ref, card),
            onDelete: () => _showDeleteCardDialog(context, ref, card),
          );
        },
      ),
    );
  }

  void _openFullScreenImage(BuildContext context, LoyaltyCard card) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          imagePath: card.imagePath,
          cardName: card.name,
        ),
      ),
    );
  }

  void _showAddCardDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddLoyaltyCardDialog(
        onSave: (name, imagePath) async {
          await ref
              .read(loyaltyCardsProvider.notifier)
              .addLoyaltyCard(name, imagePath);
        },
      ),
    );
  }

  void _showEditCardDialog(
    BuildContext context,
    WidgetRef ref,
    LoyaltyCard card,
  ) {
    showDialog(
      context: context,
      builder: (context) => AddLoyaltyCardDialog(
        card: card,
        onSave: (name, imagePath) async {
          final updatedCard = card.copyWith(name: name, imagePath: imagePath);
          await ref
              .read(loyaltyCardsProvider.notifier)
              .updateLoyaltyCard(updatedCard);
        },
      ),
    );
  }

  void _showDeleteCardDialog(
    BuildContext context,
    WidgetRef ref,
    LoyaltyCard card,
  ) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Elimina Carta',
        message: 'Sei sicuro di voler eliminare "${card.name}"?',
        icon: Icons.delete_outline,
        iconColor: AppColors.error,
        confirmText: 'Elimina',
        confirmType: DialogActionType.delete,
        onConfirm: () async {
          await ref
              .read(loyaltyCardsProvider.notifier)
              .deleteLoyaltyCard(card.id!);
        },
      ),
    );
  }
}
