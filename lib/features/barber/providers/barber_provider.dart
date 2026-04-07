import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/features/barber/models/barber_dashboard_dto.dart';
import 'package:barber_gold/features/barber/models/service_catalog.dart';
import 'package:barber_gold/features/barber/repositories/barber_repository.dart';

final barberDashboardProvider = StreamProvider.autoDispose<BarberDashboardDto>((ref) async* {
  bool isDisposed = false;
  ref.onDispose(() => isDisposed = true);

  final repo = ref.watch(barberRepositoryProvider);
  while (!isDisposed) {
    try {
      yield await repo.getDashboardStats();
    } catch (e) {}
    if (isDisposed) break;
    await Future.delayed(const Duration(seconds: 5));
  }
});

final activeServicesProvider = FutureProvider.autoDispose<List<ServiceCatalog>>((ref) async {
  final repository = ref.watch(barberRepositoryProvider);
  return await repository.getActiveServices();
});
