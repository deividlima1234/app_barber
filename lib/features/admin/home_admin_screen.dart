import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class HomeAdminScreen extends ConsumerWidget {
  const HomeAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración - Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart, size: 100),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Gestión de Lotes de Tarjetas'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Gestión de Premios (CRUD)'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push<String>('/scanner');
          if (result != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Código escaneado: $result')),
            );
            // Aquí en el futuro se enviará el resultado al CustomerController / GamificationController
          }
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Escanear QR'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
