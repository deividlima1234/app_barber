import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/theme/app_theme.dart';
import 'package:barber_gold/router/app_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:barber_gold/features/shared/services/notification_service.dart';
import 'package:barber_gold/features/shared/repositories/notification_repository.dart';
import 'package:barber_gold/features/shared/models/notification_model.dart';

import 'package:uuid/uuid.dart';

// Handler para notificaciones en segundo plano
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final notification = message.notification;
  if (notification != null) {
    final repository = NotificationRepository(const FlutterSecureStorage());
    await repository.saveNotification(NotificationModel(
      id: const Uuid().v4(),
      title: notification.title ?? 'Aviso',
      body: notification.body ?? '',
      timestamp: DateTime.now(),
    ));
  }
}

// Provider global para el servicio de notificaciones
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationService(repository);
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    
    // Configurar handler de fondo
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Solicitar permisos iniciales
    await FirebaseMessaging.instance.requestPermission();
  } catch (e) {
    debugPrint("Error inicializando Firebase: $e");
  }
  
  runApp(
    const ProviderScope(
      child: BarberGoldApp(),
    ),
  );
}

class BarberGoldApp extends ConsumerWidget {
  const BarberGoldApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Inicializar el servicio al arrancar la app
    ref.read(notificationServiceProvider).init();
    
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'BarberGold',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.cyberBarberTheme,
      routerConfig: router,
    );
  }
}
