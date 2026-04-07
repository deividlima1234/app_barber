import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/features/admin/models/admin_dashboard_dto.dart';
import 'package:barber_gold/features/admin/models/card_admin_dto.dart';
import 'package:barber_gold/features/admin/models/service_catalog_dto.dart';
import 'package:barber_gold/features/admin/repositories/admin_repository.dart';

final adminDashboardProvider = StreamProvider.autoDispose<AdminDashboardDto>((ref) async* {
  bool isDisposed = false;
  ref.onDispose(() => isDisposed = true);

  final repo = ref.watch(adminRepositoryProvider);
  while (!isDisposed) {
    try {
      final data = await repo.getDashboardStats();
      yield data;
    } catch (e) {
      if (!isDisposed) yield* Stream.error(e);
      break; // Exit loop on error to show error in UI
    }
    await Future.delayed(const Duration(seconds: 10));
  }
});

final qrInventoryProvider = StreamProvider.autoDispose<int>((ref) async* {
  bool isDisposed = false;
  ref.onDispose(() => isDisposed = true);

  final repo = ref.watch(adminRepositoryProvider);
  while (!isDisposed) {
    try {
      yield await repo.getQrInventory();
    } catch (e) {
      if (!isDisposed) yield* Stream.error(e);
      break;
    }
    await Future.delayed(const Duration(seconds: 10));
  }
});

final availableCardsProvider = StreamProvider.autoDispose<List<String>>((ref) async* {
  bool isDisposed = false;
  ref.onDispose(() => isDisposed = true);

  final repo = ref.watch(adminRepositoryProvider);
  while (!isDisposed) {
    try {
      yield await repo.getAvailableCards();
    } catch (e) {
      if (!isDisposed) yield* Stream.error(e);
      break;
    }
    await Future.delayed(const Duration(seconds: 5));
  }
});

final allCardsProvider = StreamProvider.autoDispose<List<CardAdminDto>>((ref) async* {
  bool isDisposed = false;
  ref.onDispose(() => isDisposed = true);

  final repo = ref.watch(adminRepositoryProvider);
  while (!isDisposed) {
    try {
      yield await repo.getAllCards();
    } catch (e) {
      if (!isDisposed) yield* Stream.error(e);
      break;
    }
    await Future.delayed(const Duration(seconds: 10));
  }
});

final adminServicesProvider = StreamProvider.autoDispose<List<ServiceCatalogDto>>((ref) async* {
  bool isDisposed = false;
  ref.onDispose(() => isDisposed = true);

  final repo = ref.watch(adminRepositoryProvider);
  while (!isDisposed) {
    try {
      yield await repo.getServices();
    } catch (e) {
      if (!isDisposed) yield* Stream.error(e);
      break;
    }
    await Future.delayed(const Duration(seconds: 60));
  }
});

final adminUsersProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) async* {
  bool isDisposed = false;
  ref.onDispose(() => isDisposed = true);

  final repo = ref.watch(adminRepositoryProvider);
  while (!isDisposed) {
    try {
      yield await repo.getUsers();
    } catch (e) {
      if (!isDisposed) yield* Stream.error(e);
      break;
    }
    await Future.delayed(const Duration(seconds: 60));
  }
});

