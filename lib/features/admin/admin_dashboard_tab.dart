import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/features/admin/providers/admin_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminDashboardTab extends ConsumerWidget {
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(adminDashboardProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminDashboardProvider),
        child: dashboardAsync.when(
          data: (data) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Directorio Financiero', 
                    style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)
                  ),
                  const SizedBox(height: 24),
                  
                  _buildQuickStats(data),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Top Barberos (Semana)'),
                  const SizedBox(height: 16),
                  if (data.barberLeaderboard.isEmpty)
                     _emptyState('No hay actividad registrada esta semana.')
                  else
                    ...data.barberLeaderboard.map((item) => _BarberCard(item: item)),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Últimas Acciones'),
                  const SizedBox(height: 16),
                  if (data.recentTransactions.isEmpty)
                    _emptyState('Todavía no hay transacciones.')
                  else
                    ...data.recentTransactions.map((tx) => _TransactionCard(tx: tx)),

                  const SizedBox(height: 80), // Espacio para el FAB escáner
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
          error: (e, st) => Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text('Error al cargar datos: $e', style: const TextStyle(color: Colors.white)),
            ],
          )),
        ),
      ),
    );
  }

  Widget _buildQuickStats(dynamic data) {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            title: 'Ingresos Semanales',
            value: '\$${data.grossIncomeWeek.toStringAsFixed(2)}',
            color: Colors.greenAccent,
            icon: Icons.payments_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatBox(
            title: 'Deuda en Puntos',
            value: '${data.totalPassivePoints}',
            color: Colors.redAccent,
            icon: Icons.stars_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.outfit(
            color: Colors.white.withOpacity(0.5),
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.05))),
      ],
    );
  }

  Widget _emptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatBox({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withOpacity(0.5), size: 20),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.robotoMono(fontSize: 20, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _BarberCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _BarberCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final revenue = (item['totalRevenue'] as num?)?.toDouble() ?? 0.0;
    final services = item['services'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF1A1A1A),
          child: Icon(Icons.person, color: Colors.white70),
        ),
        title: Text(item['barberName'] ?? 'Desconocido', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text('$services servicios realizados', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: Text(
          '\$${revenue.toStringAsFixed(2)}', 
          style: GoogleFonts.robotoMono(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final dynamic tx;
  const _TransactionCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('HH:mm').format(tx.date);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(dateStr, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 10)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.customerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text('${tx.serviceName} • por ${tx.barberName}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${tx.amountCharged.toStringAsFixed(2)}', style: GoogleFonts.robotoMono(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('+${tx.pointsAwarded} pts', style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}
