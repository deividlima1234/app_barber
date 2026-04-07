import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:barber_gold/features/auth/login_screen.dart';

import 'package:barber_gold/features/customer/customer_layout.dart';
import 'package:barber_gold/features/barber/barber_layout.dart';
import 'package:barber_gold/features/admin/admin_layout.dart';
import 'package:barber_gold/features/customer/roulette_screen.dart';
import 'package:barber_gold/features/barber/scanner_pro_screen.dart';
import 'package:barber_gold/providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isGoingToLogin = state.matchedLocation == '/login';
      
      switch (authState.status) {
        case AuthStatus.unauthenticated:
          return isGoingToLogin ? null : '/login';
        case AuthStatus.authenticated:
          if (isGoingToLogin) {
            // Redirect based on role
            if (authState.userRole == 'ROLE_CUSTOMER') return '/customer';
            if (authState.userRole == 'ROLE_BARBER') return '/barber';
            if (authState.userRole == 'ROLE_ADMIN') return '/admin';
          }
          return null; // Stay where they are
        case AuthStatus.checking:
          return null;
      }
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/customer',
        builder: (context, state) => const CustomerLayout(),
      ),
      GoRoute(
        path: '/roulette',
        builder: (context, state) => const RouletteScreen(),
      ),
      GoRoute(
        path: '/barber',
        builder: (context, state) => const BarberLayout(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminLayout(),
      ),
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const ScannerProScreen(),
      ),
    ],
  );
});
