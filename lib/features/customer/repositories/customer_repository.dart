import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/network/dio_client.dart';
import 'package:barber_gold/features/customer/models/customer_dashboard_dto.dart';
import 'package:barber_gold/features/customer/models/prize_redemption_dto.dart';

final customerDioProvider = Provider<Dio>((ref) => DioClient().dio);

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(ref.watch(customerDioProvider));
});

class CustomerRepository {
  final Dio _dio;
  CustomerRepository(this._dio);

  Future<CustomerDashboardDto> getWalletData() async {
    final response = await _dio.get('/customers/me/wallet');
    return CustomerDashboardDto.fromJson(response.data);
  }

  Future<List<PrizeRedemptionDto>> getMyRedemptions() async {
    final response = await _dio.get('/redemptions/me');
    return (response.data as List).map((x) => PrizeRedemptionDto.fromJson(x)).toList();
  }
}
