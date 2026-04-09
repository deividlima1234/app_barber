import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:barber_gold/features/admin/providers/admin_redemptions_provider.dart';

class AdminRedemptionsTab extends ConsumerWidget {
  const AdminRedemptionsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final redemptionsAsync = ref.watch(adminRedemptionsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CANJES DE PREMIOS',
                  style: GoogleFonts.orbitron(
                    color: Colors.redAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'Gestiona y entrega los premios ganados en el sistema.',
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: redemptionsAsync.when(
              data: (prizes) {
                if (prizes.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: prizes.length,
                  itemBuilder: (context, index) => _RedemptionAdminCard(redemption: prizes[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
              error: (err, st) => Center(
                child: Text('Error al cargar canjes', style: TextStyle(color: Colors.redAccent)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            '¡No hay canjes pendientes!',
            style: GoogleFonts.inter(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _RedemptionAdminCard extends ConsumerWidget {
  final dynamic redemption;
  const _RedemptionAdminCard({required this.redemption});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('dd/MM HH:mm').format(redemption.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                child: const Icon(Icons.person, color: Colors.redAccent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      redemption.customerFullName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      redemption.customerEmail,
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Text(
                dateStr,
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      redemption.prizeName,
                      style: GoogleFonts.inter(color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                    if (redemption.prizeDescription.isNotEmpty)
                      Text(
                        redemption.prizeDescription,
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.withOpacity(0.2),
                  foregroundColor: Colors.green,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: const BorderSide(color: Colors.green, width: 0.5),
                ),
                onPressed: () => _confirmDelivery(context, ref),
                child: const Text('ENTREGAR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelivery(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('¿Confirmar entrega?', style: TextStyle(color: Colors.white)),
        content: Text('¿Le has entregado el premio "${redemption.prizeName}" a ${redemption.customerFullName}?', 
          style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('NO')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(adminRedemptionsProvider.notifier).deliverPrize(redemption.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Premio marcado como entregado' : 'Error al confirmar entrega'),
                    backgroundColor: success ? Colors.green : Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('SÍ, ENTREGADO'),
          ),
        ],
      ),
    );
  }
}
