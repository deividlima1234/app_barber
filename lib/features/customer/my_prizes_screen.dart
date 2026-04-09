import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:barber_gold/features/customer/providers/my_redemptions_provider.dart';

class MyPrizesScreen extends ConsumerWidget {
  const MyPrizesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final redemptionsAsync = ref.watch(myRedemptionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: Text(
          'MIS PREMIOS 🏆',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.amber,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.amber.withOpacity(0.05),
              Colors.black,
            ],
          ),
        ),
        child: redemptionsAsync.when(
          data: (prizes) {
            if (prizes.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: prizes.length,
              itemBuilder: (context, index) {
                final prize = prizes[index];
                return _buildPrizeCard(prize);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: Colors.amber)),
          error: (err, stack) => Center(
            child: Text(
              'Error al cargar tus premios',
              style: GoogleFonts.inter(color: Colors.redAccent),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 80, color: Colors.amber.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            '¡Aún no has ganado premios!',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Gira la ruleta para ganar recompensas únicas.',
            style: GoogleFonts.inter(color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _buildPrizeCard(dynamic prize) {
    final bool isPending = prize.status == 'PENDING';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending ? Colors.amber.withOpacity(0.3) : Colors.green.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: (isPending ? Colors.amber : Colors.green).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPending ? Colors.amber.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPending ? Icons.hourglass_top : Icons.check_circle,
              color: isPending ? Colors.amber : Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prize.prizeName,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Ganado el ${DateFormat('dd/MM/yyyy').format(prize.createdAt)}',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isPending ? Colors.amber.withOpacity(0.2) : Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isPending ? 'PENDIENTE' : 'ENTREGADO',
              style: GoogleFonts.inter(
                color: isPending ? Colors.amber : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
