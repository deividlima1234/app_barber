import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:barber_gold/features/admin/admin_dashboard_tab.dart';
import 'package:barber_gold/features/admin/admin_users_tab.dart';
import 'package:barber_gold/features/admin/admin_services_tab.dart';
import 'package:barber_gold/features/admin/admin_prizes_tab.dart';
import 'package:barber_gold/features/admin/admin_redemptions_tab.dart';
import 'package:barber_gold/features/admin/admin_broadcast_tab.dart';
import 'package:barber_gold/features/shared/settings_tab.dart';

class AdminLayout extends ConsumerStatefulWidget {
  const AdminLayout({super.key});

  @override
  ConsumerState<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends ConsumerState<AdminLayout> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const AdminDashboardTab(),
    const AdminUsersTab(),
    const AdminServicesTab(),
    const AdminPrizesTab(),
    const AdminRedemptionsTab(),
    const AdminBroadcastTab(),
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
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Usuarios'),
          BottomNavigationBarItem(icon: Icon(Icons.content_cut), label: 'Servicios'),
          BottomNavigationBarItem(icon: Icon(Icons.stars), label: 'Ruleta'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Canjes'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Difusión'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Perfil'),
        ],
      ),
    );
  }
}
