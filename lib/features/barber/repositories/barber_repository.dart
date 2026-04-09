import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/features/barber/models/barber_dashboard_dto.dart';
import 'package:barber_gold/features/barber/models/service_catalog.dart';
import 'package:barber_gold/providers/auth_provider.dart';

final barberRepositoryProvider = Provider<BarberRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return BarberRepository(dioClient.dio);
});

class BarberRepository {
  final Dio _dio;

  BarberRepository(this._dio);

  Future<BarberDashboardDto> getDashboardStats() async {
    final response = await _dio.get('/barbers/me/dashboard');
    return BarberDashboardDto.fromJson(response.data);
  }

  Future<List<ServiceCatalog>> getActiveServices() async {
    final response = await _dio.get('/services/active');
    final data = response.data as List;
    return data.map((json) => ServiceCatalog.fromJson(json)).toList();
  }
  
  Future<Map<String, dynamic>> checkCardStatus(String qrToken) async {
    final response = await _dio.get('/cards/$qrToken');
    return response.data;
  }
  
  Future<void> submitTransaction(String qrToken, int serviceId) async {
    await _dio.post('/points/add', data: {
      'qrToken': qrToken,
      'serviceId': serviceId,
    });
  }
  
  Future<void> registerCustomer(String qrToken, String email, String password, String fullName) async {
    await _dio.post('/customers/activate', data: {
      'qrToken': qrToken,
      'email': email,
      'password': password,
      'fullName': fullName,
    });
  }
}
