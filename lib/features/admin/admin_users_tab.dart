import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/features/admin/providers/admin_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminUsersTab extends ConsumerWidget {
  const AdminUsersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DefaultTabController(
        length: 2,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Row(
                  children: [
                    const Icon(Icons.people_outline, color: Colors.redAccent, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      'CENTRO DE CONTROL',
                      style: GoogleFonts.outfit(
                        fontSize: 24, 
                        fontWeight: FontWeight.w800, 
                        color: Colors.white,
                        letterSpacing: 1.2
                      ),
                    ),
                  ],
                ),
              ),
              TabBar(
                labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelColor: Colors.white24,
                indicatorColor: Colors.redAccent,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'SQUAD (STAFF)', icon: Icon(Icons.shield, size: 20)),
                  Tab(text: 'CLIENT BASE', icon: Icon(Icons.group, size: 20)),
                ],
              ),
              Expanded(
                child: usersAsync.when(
                  data: (users) {
                    final staff = users.where((u) => u['role'] == 'ADMIN' || u['role'] == 'BARBER').toList();
                    final customers = users.where((u) => u['role'] == 'CUSTOMER').toList();

                    return TabBarView(
                      children: [
                        _UserList(users: staff, emptyMessage: 'Sin personal activo.'),
                        _UserList(users: customers, emptyMessage: 'Sin clientes registrados.'),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
                  error: (e, st) => _ErrorView(error: e.toString(), onRetry: () => ref.invalidate(adminUsersProvider)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  final List<dynamic> users;
  final String emptyMessage;

  const _UserList({required this.users, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
        child: Text(emptyMessage, style: GoogleFonts.outfit(color: Colors.white24, fontSize: 18)),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: users.length,
      itemBuilder: (context, index) {
        return _UserCard(user: users[index]);
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final bool isCustomer = user['role'] == 'CUSTOMER';
    final String roleLabel = user['role'] == 'ADMIN' ? 'SUPERUSER' : (user['role'] == 'BARBER' ? 'OPERATIVE' : 'LOYAL CLIENT');
    final Color roleColor = user['role'] == 'ADMIN' ? Colors.redAccent : (user['role'] == 'BARBER' ? Colors.blueAccent : Colors.amberAccent);
    
    final String dateStr = user['createdAt'] != null ? user['createdAt'].toString().split('T')[0] : 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: roleColor.withOpacity(0.1),
                  child: Text(
                    (user['fullName'] ?? 'U')[0].toUpperCase(),
                    style: GoogleFonts.outfit(color: roleColor, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['fullName'] ?? user['username'],
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          roleLabel,
                          style: GoogleFonts.outfit(color: roleColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
                        ),
                      ),
                    ],
                  ),
                ),
                if (user['isActive'] == true)
                  const _PulseIndicator()
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          // Info Body
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoItem(label: 'PHONE / TARGET', value: user['username'] ?? 'N/A'),
                if (isCustomer) 
                  _InfoItem(label: 'REWARD POINTS', value: '${user['totalPoints'] ?? 0} PTS', valueColor: Colors.amberAccent),
                _InfoItem(label: 'MEMBER SINCE', value: dateStr),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.robotoMono(
            color: valueColor ?? Colors.white70, 
            fontSize: 12, 
            fontWeight: FontWeight.w600
          ),
        ),
      ],
    );
  }
}

class _PulseIndicator extends StatefulWidget {
  const _PulseIndicator();

  @override
  State<_PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<_PulseIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller.drive(CurveTween(curve: Curves.easeInOut)),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onRetry, child: const Text('RETRY UPLINK')),
        ],
      ),
    );
  }
}
