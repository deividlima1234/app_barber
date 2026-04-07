import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/features/customer/providers/customer_provider.dart';
import 'package:barber_gold/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class HomeCustomerScreen extends ConsumerWidget {
  const HomeCustomerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(customerDashboardProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: walletAsync.when(
          data: (data) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, ref, data.customerName),
                const SizedBox(height: 24),
                _buildCyberCard(context, data.customerName, data.qrToken),
                const SizedBox(height: 32),
                _buildPointsProgress(context, data.totalPoints, data.pointsToNextSpin),
                const SizedBox(height: 32),
                _buildRecentActivity(data.recentTransactions),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
          error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BIENVENIDO A BARBERGOLD,', 
              style: GoogleFonts.orbitron(color: Colors.redAccent, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(name.toUpperCase(), 
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.power_settings_new, color: Colors.grey),
          onPressed: () => _confirmLogout(context, ref),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('¿Cerrar sesión?', style: TextStyle(color: Colors.white)),
        content: const Text('¿Estás seguro de que deseas salir de Cyber-Wallet?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('SALIR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCyberCard(BuildContext context, String name, String? qrToken) {
    return Center(
      child: Container(
        width: 280,
        height: 440,
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.redAccent.withOpacity(0.1), blurRadius: 40, spreadRadius: -10),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: CustomPaint(painter: _CyberGridPainter()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.content_cut, color: Colors.redAccent, size: 24),
                      const SizedBox(width: 8),
                      Text('BARBERGOLD', style: GoogleFonts.blackOpsOne(color: Colors.redAccent, fontSize: 18, letterSpacing: 2)),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'VIP MEMBER',
                    style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"Tu estilo, tu recompensa"',
                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 10, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: qrToken != null
                        ? QrImageView(
                            data: qrToken,
                            version: QrVersions.auto,
                            size: 140,
                          )
                        : const SizedBox(
                            width: 140,
                            height: 140,
                            child: Center(child: Text('Sin Tarjeta', style: TextStyle(color: Colors.black, fontSize: 10))),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ID: HK-${qrToken?.substring(0, 4).toUpperCase() ?? 'PENDING'}',
                    style: GoogleFonts.robotoMono(color: Colors.white54, fontSize: 12),
                  ),
                  const Spacer(),
                  const Text(
                    'Escanea para sumar puntos\nNo compartas este código',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 9, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsProgress(BuildContext context, int total, int toNext) {
    double progress = (total % 1000) / 1000;
    bool ready = total >= 1000 && toNext == 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text('Puntos Totales', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                   Text('$total PTS', style: GoogleFonts.robotoMono(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              if (ready)
                GestureDetector(
                  onTap: () => context.push('/roulette'),
                  child: _buildReadyBadge(),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                     Text('Faltan para Girar', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                     Text('$toNext', style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.05),
            color: Colors.redAccent,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars, color: Colors.greenAccent, size: 16),
          const SizedBox(width: 4),
          Text('¡LISTO PARA GIRAR!', style: GoogleFonts.outfit(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(dynamic transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('HISTORIAL DE ESTILO', style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14)),
            const SizedBox(width: 8),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.05))),
          ],
        ),
        const SizedBox(height: 16),
        if (transactions.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No hay visitas todavía', style: TextStyle(color: Colors.grey))))
        else
          ...transactions.map((tx) => _TransactionCustomerTile(tx: tx)).toList(),
      ],
    );
  }
}

class _TransactionCustomerTile extends StatelessWidget {
  final dynamic tx;
  const _TransactionCustomerTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM').format(tx.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.content_cut, color: Colors.redAccent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.serviceName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Barbero: ${tx.barberName}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              Text('+${tx.pointsAwarded} PTS', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CyberGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 0.5;

    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
