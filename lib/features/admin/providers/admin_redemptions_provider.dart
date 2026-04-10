import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/features/admin/repositories/admin_repository.dart';
import 'package:barber_gold/features/admin/models/admin_prize_redemption_dto.dart';

final adminRedemptionsProvider = StateNotifierProvider<AdminRedemptionsNotifier, AsyncValue<List<AdminPrizeRedemptionDto>>>((ref) {
  return AdminRedemptionsNotifier(ref.watch(adminRepositoryProvider));
});

class AdminRedemptionsNotifier extends StateNotifier<AsyncValue<List<AdminPrizeRedemptionDto>>> {
  final AdminRepository _repository;

  AdminRedemptionsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadRedemptions();
  }

  Future<void> loadRedemptions() async {
    state = const AsyncValue.loading();
    try {
      print("🚀 [NOTIFIER] Lanzando petición de canjes...");
      final data = await _repository.getPendingRedemptions();
      print("✅ [NOTIFIER] Petición exitosa, recibidos ${data.length} canjes");
      state = AsyncValue.data(data);
    } catch (e, st) {
      print("🚩 [NOTIFIER] ERROR CRÍTICO: $e");
      print("📋 [NOTIFIER] RASTRO DEL ERROR: \n $st");
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> deliverPrize(int id) async {
    try {
      await _repository.deliverPrize(id);
      loadRedemptions(); // Recargar lista
      return true;
    } catch (e) {
      return false;
    }
  }
}
