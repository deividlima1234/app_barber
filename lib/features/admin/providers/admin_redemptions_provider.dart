import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/features/admin/repositories/admin_repository.dart';
import 'package:barber_gold/features/admin/models/admin_prize_redemption_dto.dart';

// Proveedor para canjes pendientes
final adminPendingRedemptionsProvider = StateNotifierProvider<AdminRedemptionsNotifier, AsyncValue<List<AdminPrizeRedemptionDto>>>((ref) {
  return AdminRedemptionsNotifier(ref.watch(adminRepositoryProvider), 'PENDING', ref);
});

// Proveedor para historial de entregados
final adminHistoryRedemptionsProvider = StateNotifierProvider<AdminRedemptionsNotifier, AsyncValue<List<AdminPrizeRedemptionDto>>>((ref) {
  return AdminRedemptionsNotifier(ref.watch(adminRepositoryProvider), 'DELIVERED', ref);
});

class AdminRedemptionsNotifier extends StateNotifier<AsyncValue<List<AdminPrizeRedemptionDto>>> {
  final AdminRepository _repository;
  final String _status;
  final Ref _ref;

  AdminRedemptionsNotifier(this._repository, this._status, this._ref) : super(const AsyncValue.loading()) {
    loadRedemptions();
  }

  Future<void> loadRedemptions() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getRedemptionsByStatus(_status);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> deliverPrize(int id) async {
    try {
      await _repository.deliverPrize(id);
      
      // Recargar lista de pendientes
      _ref.read(adminPendingRedemptionsProvider.notifier).loadRedemptions();
      // Recargar historial
      _ref.read(adminHistoryRedemptionsProvider.notifier).loadRedemptions();
      
      return true;
    } catch (e) {
      return false;
    }
  }
}
