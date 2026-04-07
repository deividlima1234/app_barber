import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/network/dio_client.dart';
import 'package:barber_gold/features/admin/models/prize.dart';

final prizeDioProvider = Provider<Dio>((ref) => DioClient().dio);

final prizeRepositoryProvider = Provider<PrizeRepository>((ref) {
  return PrizeRepository(ref.watch(prizeDioProvider));
});

class PrizeRepository {
  final Dio _dio;
  PrizeRepository(this._dio);

  Future<List<Prize>> getPrizes() async {
    final response = await _dio.get('/prizes');
    final data = response.data as List;
    return data.map((json) => Prize.fromJson(json)).toList();
  }

  Future<Prize> createPrize(Prize prize) async {
    final response = await _dio.post('/prizes', data: prize.toJson());
    return Prize.fromJson(response.data);
  }

  Future<Prize> updatePrize(Prize prize) async {
    final response = await _dio.put('/prizes/${prize.id}', data: prize.toJson());
    return Prize.fromJson(response.data);
  }

  Future<void> deletePrize(int id) async {
    await _dio.delete('/prizes/$id');
  }

  Future<void> togglePrize(int id) async {
    await _dio.patch('/prizes/$id/toggle');
  }

  Future<int> getRouletteCost() async {
    final response = await _dio.get('/prizes/config/cost');
    return response.data['cost'] ?? 1000;
  }

  Future<void> updateRouletteCost(int cost) async {
    await _dio.post('/prizes/config/cost', data: {'cost': cost});
  }

  Future<Map<String, dynamic>> spinRoulette(String qrToken) async {
    final response = await _dio.post('/gamification/spin', data: {'qrToken': qrToken});
    return response.data;
  }
}
