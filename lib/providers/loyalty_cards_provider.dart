import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loyalty_card.dart';
import '../services/database_service.dart';
import 'database_provider.dart';

final loyaltyCardsProvider =
    StateNotifierProvider<LoyaltyCardsNotifier, AsyncValue<List<LoyaltyCard>>>((
      ref,
    ) {
      return LoyaltyCardsNotifier(ref.watch(databaseServiceProvider));
    });

class LoyaltyCardsNotifier
    extends StateNotifier<AsyncValue<List<LoyaltyCard>>> {
  final DatabaseService _databaseService;

  LoyaltyCardsNotifier(this._databaseService)
    : super(const AsyncValue.loading()) {
    loadLoyaltyCards();
  }

  Future<void> loadLoyaltyCards() async {
    try {
      state = const AsyncValue.loading();
      final cards = await _databaseService.getAllLoyaltyCards();
      state = AsyncValue.data(cards);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addLoyaltyCard(String name, String imagePath) async {
    final card = LoyaltyCard(
      name: name,
      imagePath: imagePath,
      createdAt: DateTime.now(),
    );

    await _databaseService.insertLoyaltyCard(card);
    await loadLoyaltyCards();
  }

  Future<void> updateLoyaltyCard(LoyaltyCard card) async {
    await _databaseService.updateLoyaltyCard(card);
    await loadLoyaltyCards();
  }

  Future<void> deleteLoyaltyCard(int id) async {
    await _databaseService.deleteLoyaltyCard(id);
    await loadLoyaltyCards();
  }
}
