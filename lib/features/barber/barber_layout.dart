import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:barber_gold/features/barber/barber_home_tab.dart';
import 'package:barber_gold/features/shared/settings_tab.dart';

class BarberLayout extends ConsumerStatefulWidget {
  const BarberLayout({super.key});

  @override
  ConsumerState<BarberLayout> createState() => _BarberLayoutState();
}

class _BarberLayoutState extends ConsumerState<BarberLayout> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const BarberHomeTab(),
    const Center(child: Text('Historial')),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/scanner'),
        child: const Icon(Icons.qr_code_scanner, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Mi Turno'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
