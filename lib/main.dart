import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/theme/app_theme.dart';
import 'package:barber_gold/router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    // Solicitar permisos iniciales
    await FirebaseMessaging.instance.requestPermission();
  } catch (e) {
    debugPrint("Error inicializando Firebase: $e");
    // La app continuará aunque Firebase falle, evitando el crash de arranque
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
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'BarberGold',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.cyberBarberTheme,
      routerConfig: router,
    );
  }
}
