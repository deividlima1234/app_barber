import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/network/dio_client.dart';

final adminNotificationRepositoryProvider = Provider<AdminNotificationRepository>((ref) {
  final dio = DioClient().dio;
  return AdminNotificationRepository(dio);
});

class AdminNotificationRepository {
  final Dio _dio;
  AdminNotificationRepository(this._dio);

  Future<void> sendBroadcast({
    required String topic,
    required String title,
    required String body,
  }) async {
    try {
      await _dio.post('/notifications/broadcast', data: {
        'topic': topic,
        'title': title,
        'body': body,
      });
    } catch (e) {
      throw Exception('No se pudo enviar la notificación: $e');
    }
  }
}
