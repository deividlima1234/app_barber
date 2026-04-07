import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/theme/app_theme.dart';
import 'package:barber_gold/router/app_router.dart';

void main() {
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
