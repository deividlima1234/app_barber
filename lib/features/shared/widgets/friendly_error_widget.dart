import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendlyErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  final IconData icon;

  const FriendlyErrorWidget({
    super.key,
    this.message,
    required this.onRetry,
    this.icon = Icons.wifi_off_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.redAccent.withOpacity(0.1)),
              ),
              child: Icon(
                icon,
                size: 64,
                color: Colors.redAccent.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'CONEXIÓN INTERRUMPIDA',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message ?? 'No pudimos establecer contacto con el servidor. Por favor, verifica tu conexión o reintenta en unos instantes.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white38,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              child: OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('REINTENTAR'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
