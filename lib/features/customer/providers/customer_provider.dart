import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/features/customer/models/customer_dashboard_dto.dart';
import 'package:barber_gold/features/customer/repositories/customer_repository.dart';

final customerDashboardProvider = StreamProvider.autoDispose<CustomerDashboardDto>((ref) async* {
  bool isDisposed = false;
  ref.onDispose(() => isDisposed = true);

  final repo = ref.watch(customerRepositoryProvider);
  while (!isDisposed) {
    try {
      final data = await repo.getWalletData();
      yield data;
    } catch (e) {
      if (!isDisposed) yield* Stream.error(e);
      break;
    }
    await Future.delayed(const Duration(seconds: 30));
  }
});
