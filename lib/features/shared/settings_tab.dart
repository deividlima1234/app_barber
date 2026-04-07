import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:barber_gold/providers/auth_provider.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle, size: 100, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Ajustes de Cuenta', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Cerrar Sesión Segura', style: TextStyle(color: Colors.white, fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              try {
                // Actualiza el Estado Global de Autenticación de Riverpod
                await ref.read(authProvider.notifier).logout();
                
                if (context.mounted) {
                  // Forza al GoRouter a ir a la vista de login ahora que el estado es desautorizado
                  context.go('/login');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

