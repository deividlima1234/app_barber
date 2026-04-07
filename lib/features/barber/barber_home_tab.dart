import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/features/barber/providers/barber_provider.dart';

class BarberHomeTab extends ConsumerWidget {
  const BarberHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(barberDashboardProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(barberDashboardProvider);
        },
        child: dashboardAsync.when(
          data: (data) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  '¡A romperla hoy!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Hero Metrics
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        title: 'Ingresos Hoy',
                        value: '\$${data.incomeToday.toStringAsFixed(2)}',
                        icon: Icons.attach_money,
                        color: Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _MetricCard(
                        title: 'Servicios',
                        value: '${data.servicesToday}',
                        icon: Icons.content_cut,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Recent Transactions List
                const Text(
                  'Últimos clientes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                
                if (data.recentTransactions.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('Aún no hay clientes hoy', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.recentTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = data.recentTransactions[index];
                      final timeString = "${tx.date.hour.toString().padLeft(2,'0')}:${tx.date.minute.toString().padLeft(2,'0')}";
                      
                      return Card(
                        color: const Color(0xFF1E1E1E),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.white10),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.redAccent,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(
                            tx.customerName,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          subtitle: Text(
                            '$timeString - ${tx.serviceName}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${tx.amountCharged.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent),
                              ),
                              Text(
                                '+${tx.pointsAwarded} pts',
                                style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
          error: (error, stack) => Center(
            child: Text('Error al cargar datos: $error', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
