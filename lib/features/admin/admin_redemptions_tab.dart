import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:barber_gold/features/admin/models/admin_prize_redemption_dto.dart';
import 'package:barber_gold/features/admin/providers/admin_redemptions_provider.dart';

class AdminRedemptionsTab extends ConsumerWidget {
  const AdminRedemptionsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 100,
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
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
                  'Gestiona las entregas de premios ganados.',
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.redAccent,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white24,
            labelStyle: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
            tabs: const [
              Tab(text: 'PENDIENTES'),
              Tab(text: 'HISTORIAL'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _RedemptionsList(status: 'PENDING'),
            _RedemptionsList(status: 'DELIVERED'),
          ],
        ),
      ),
    );
  }
}

class _RedemptionsList extends ConsumerWidget {
  final String status;
  const _RedemptionsList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = status == 'PENDING' 
        ? adminPendingRedemptionsProvider 
        : adminHistoryRedemptionsProvider;
    
    final redemptionsAsync = ref.watch(provider);

    return redemptionsAsync.when(
      data: (prizes) {
        if (prizes.isEmpty) {
          return _buildEmptyState(status == 'PENDING');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: prizes.length,
          itemBuilder: (context, index) => _RedemptionAdminCard(
            redemption: prizes[index],
            isHistory: status == 'DELIVERED',
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
      error: (err, st) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white24))),
    );
  }

  Widget _buildEmptyState(bool isPending) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPending ? Icons.check_circle_outline : Icons.history_toggle_off,
            size: 64, 
            color: Colors.white10
          ),
          const SizedBox(height: 16),
          Text(
            isPending ? '¡Todo entregado!' : 'No hay historial de entregas.',
            style: GoogleFonts.inter(color: Colors.white24),
          ),
        ],
      ),
    );
  }
}

class _RedemptionAdminCard extends ConsumerWidget {
  final AdminPrizeRedemptionDto redemption;
  final bool isHistory;
  const _RedemptionAdminCard({
    required this.redemption,
    this.isHistory = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String dateStr = "N/A";
    try {
      dateStr = DateFormat('dd/MM HH:mm').format(redemption.createdAt);
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isHistory ? Colors.white.withOpacity(0.02) : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isHistory ? Colors.white10 : Colors.redAccent.withOpacity(0.1),
                  radius: 18,
                  child: Icon(
                    isHistory ? Icons.history : Icons.person, 
                    color: isHistory ? Colors.white24 : Colors.redAccent, 
                    size: 16
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        redemption.customerFullName,
                        style: TextStyle(
                          color: isHistory ? Colors.white60 : Colors.white, 
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        redemption.customerEmail,
                        style: const TextStyle(color: Colors.white24, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Text(
                  dateStr,
                  style: const TextStyle(color: Colors.white24, fontSize: 10),
                ),
              ],
            ),
            const Divider(height: 24, color: Colors.white10),
            
            Text(
              redemption.prizeName.toUpperCase(),
              style: GoogleFonts.orbitron(
                color: isHistory ? Colors.white24 : Colors.amber, 
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
            if (redemption.prizeDescription.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                redemption.prizeDescription,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
            
            if (!isHistory) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('CONFIRMAR ENTREGA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.1),
                    foregroundColor: Colors.green,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.green, width: 0.5),
                    ),
                  ),
                  onPressed: () => _confirmDelivery(context, ref),
                ),
              ),
            ] else ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.done_all_rounded, color: Colors.green, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'ENTREGADO',
                        style: GoogleFonts.orbitron(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelivery(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.white10)),
        title: Text('¿CONFIRMAR ENTREGA?', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        content: Text('¿Confirmas que ya has entregado este premio al cliente?', 
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR', style: TextStyle(color: Colors.white24))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(adminPendingRedemptionsProvider.notifier).deliverPrize(redemption.id);
            },
            child: const Text('SÍ, ENTREGADO'),
          ),
        ],
      ),
    );
  }
}
