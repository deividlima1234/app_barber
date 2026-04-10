import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:barber_gold/features/shared/models/notification_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(const FlutterSecureStorage());
});

class NotificationRepository {
  final FlutterSecureStorage _storage;
  static const String _storageKey = 'local_notifications_history';

  NotificationRepository(this._storage);

  Future<List<NotificationModel>> getNotifications() async {
    final String? rawData = await _storage.read(key: _storageKey);
    if (rawData == null) return [];
    
    try {
      final List<dynamic> decoded = json.decode(rawData);
      return decoded.map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveNotification(NotificationModel notification) async {
    final notifications = await getNotifications();
    // Insertar al inicio para que el historial sea de reciente a antiguo
    notifications.insert(0, notification);
    
    // Limitar a las últimas 50 para no degradar el rendimiento
    if (notifications.length > 50) {
      notifications.removeLast();
    }

    await _storage.write(
      key: _storageKey,
      value: json.encode(notifications.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> markAsRead(String id) async {
    final notifications = await getNotifications();
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      await _storage.write(
        key: _storageKey,
        value: json.encode(notifications.map((e) => e.toJson()).toList()),
      );
    }
  }

  Future<void> clearAll() async {
    await _storage.delete(key: _storageKey);
  }
}
