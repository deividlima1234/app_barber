import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/features/customer/home_customer_screen.dart';
import 'package:barber_gold/features/customer/roulette_screen.dart';
import 'package:barber_gold/features/shared/settings_tab.dart';

class CustomerLayout extends ConsumerStatefulWidget {
  const CustomerLayout({super.key});

  @override
  ConsumerState<CustomerLayout> createState() => _CustomerLayoutState();
}

class _CustomerLayoutState extends ConsumerState<CustomerLayout> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeCustomerScreen(),
    const RouletteScreen(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Billetera'),
          BottomNavigationBarItem(icon: Icon(Icons.casino), label: 'Ruleta'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}
