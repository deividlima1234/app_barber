import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/features/admin/models/prize.dart';
import 'package:barber_gold/features/admin/repositories/prize_repository.dart';

final prizesProvider = FutureProvider<List<Prize>>((ref) async {
  final repo = ref.watch(prizeRepositoryProvider);
  return repo.getPrizes();
});

final rouletteCostProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(prizeRepositoryProvider);
  return repo.getRouletteCost();
});

class PrizeNotifier extends StateNotifier<AsyncValue<void>> {
  final PrizeRepository _repository;
  final Ref _ref;

  PrizeNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> createPrize(Prize prize) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createPrize(prize);
      _ref.invalidate(prizesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updatePrize(Prize prize) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updatePrize(prize);
      _ref.invalidate(prizesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deletePrize(int id) async {
    try {
      await _repository.deletePrize(id);
      _ref.invalidate(prizesProvider);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> togglePrize(int id) async {
    try {
      await _repository.togglePrize(id);
      _ref.invalidate(prizesProvider);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateCost(int cost) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateRouletteCost(cost);
      _ref.invalidate(rouletteCostProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final prizeActionProvider = StateNotifierProvider<PrizeNotifier, AsyncValue<void>>((ref) {
  return PrizeNotifier(ref.watch(prizeRepositoryProvider), ref);
});
