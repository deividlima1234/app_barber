import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/providers/auth_provider.dart';
import 'package:barber_gold/features/admin/models/admin_dashboard_dto.dart';
import 'package:barber_gold/features/admin/models/card_admin_dto.dart';
import 'package:barber_gold/features/admin/models/service_catalog_dto.dart';
import 'package:barber_gold/features/admin/models/admin_prize_redemption_dto.dart';

final adminDioProvider = Provider<Dio>((ref) => ref.watch(dioClientProvider).dio);

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(adminDioProvider));
});

class AdminRepository {
  final Dio _dio;

  AdminRepository(this._dio);

  Future<AdminDashboardDto> getDashboardStats() async {
    final response = await _dio.get('/admin/dashboard');
    return AdminDashboardDto.fromJson(response.data);
  }

  Future<int> getQrInventory() async {
    final response = await _dio.get('/cards/inventory');
    return response.data['available'] as int;
  }

  Future<List<String>> generateBatch(int count) async {
    final response = await _dio.post('/cards/batch', data: {'count': count});
    final rawTokens = response.data['tokens'] as List;
    return rawTokens.map((e) => e.toString()).toList();
  }

  Future<List<String>> getAvailableCards() async {
    final response = await _dio.get('/cards/available');
    return List<String>.from(response.data);
  }

  Future<List<CardAdminDto>> getAllCards() async {
    final response = await _dio.get('/cards/admin/all');
    return (response.data as List).map((e) => CardAdminDto.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final response = await _dio.get('/admin/users');
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Service Catalog
  Future<List<ServiceCatalogDto>> getServices() async {
    final response = await _dio.get('/services');
    return (response.data as List).map((e) => ServiceCatalogDto.fromJson(e)).toList();
  }

  Future<void> createService(ServiceCatalogDto service) async {
    await _dio.post('/services', data: service.toJson());
  }

  Future<void> updateService(ServiceCatalogDto service) async {
    await _dio.put('/services/${service.id}', data: service.toJson());
  }

  Future<void> toggleService(int id) async {
    await _dio.patch('/services/$id/toggle');
  }

  Future<void> resetPassword(String userId, String newPassword) async {
    await _dio.put('/admin/users/$userId/password-reset', data: {
      'newPassword': newPassword,
    });
  }

  // Redemptions
  Future<List<AdminPrizeRedemptionDto>> getRedemptionsByStatus(String status) async {
    print("📡 [REPO] Solicitando canjes con estado: $status...");
    final response = await _dio.get('/redemptions/admin/all', queryParameters: {'status': status});
    return (response.data as List).map((e) => AdminPrizeRedemptionDto.fromJson(e)).toList();
  }

  Future<void> deliverPrize(int id) async {
    await _dio.put('/redemptions/admin/$id/deliver');
  }
}
