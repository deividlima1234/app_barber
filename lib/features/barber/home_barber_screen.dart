import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/providers/auth_provider.dart';

import 'package:go_router/go_router.dart';

class HomeBarberScreen extends ConsumerWidget {
  const HomeBarberScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel del Barbero'),
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
            const Icon(Icons.qr_code_scanner, size: 100),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Escanear QR de Cliente'),
              onPressed: () async {
                final result = await context.push<String>('/scanner');
                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Código escaneado: $result')),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('Activar Nueva Tarjeta'),
              onPressed: () {
                // TODO: Registrar cliente
              },
            ),
          ],
        ),
      ),
    );
  }
}
