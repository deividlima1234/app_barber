import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:barber_gold/features/shared/models/notification_model.dart';
import 'package:barber_gold/features/shared/repositories/notification_repository.dart';
import 'package:uuid/uuid.dart';

class NotificationService {
  final NotificationRepository _repository;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  NotificationService(this._repository);

  Future<void> init() async {
    // 1. Configurar Local Notifications para primer plano
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // 2. Obtener y loguear el FCM Token para depuración
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      print("🔑 [FCM TOKEN]: $token");
    } catch (e) {
      print("🚩 Error obteniendo FCM Token: $e");
    }

    // 3. Escuchar mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Mensaje recibido en PRIMER PLANO");
      _handleMessage(message, isForeground: true);
    });

    // 4. Escuchar cuando abren la app desde una notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🖱️ Notificación pulsada (App abierta desde el tray)");
      _handleMessage(message, isForeground: false);
    });
  }

  void _handleMessage(RemoteMessage message, {required bool isForeground}) async {
    final notification = message.notification;
    if (notification == null) return;

    final model = NotificationModel(
      id: const Uuid().v4(),
      title: notification.title ?? 'Aviso',
      body: notification.body ?? '',
      timestamp: DateTime.now(),
    );

    // Guardar en el historial local
    await _repository.saveNotification(model);

    // Si está en primer plano, mostrar alerta visual
    if (isForeground) {
      _showLocalNotification(model);
    }
  }

  void _showLocalNotification(NotificationModel model) {
    _localNotifications.show(
      model.hashCode,
      model.title,
      model.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'Notificaciones Importantes',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  Future<void> subscribeToRole(String role) async {
    // Limpiar ROLE_ de la cadena (ej: ROLE_ADMIN -> admin_topic)
    final cleanRole = role.replaceAll('ROLE_', '').toLowerCase();
    final topic = '${cleanRole}_topic';
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    print("🔔 Suscrito al tópico: $topic");
  }

  Future<void> unsubscribeFromRole(String role) async {
    final cleanRole = role.replaceAll('ROLE_', '').toLowerCase();
    final topic = '${cleanRole}_topic';
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    print("🔕 Desuscrito del tópico: $topic");
  }
}
