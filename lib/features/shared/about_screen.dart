import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('ACERCA DE', style: GoogleFonts.orbitron(letterSpacing: 2, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const SizedBox(height: 48),
            // Logo o Icono Principal
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.redAccent, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.redAccent.withOpacity(0.2), blurRadius: 40, spreadRadius: 5),
                ],
              ),
              child: const Icon(Icons.content_cut, color: Colors.redAccent, size: 80),
            ),
            const SizedBox(height: 32),
            Text(
              'BARBERGOLD',
              style: GoogleFonts.blackOpsOne(color: Colors.redAccent, fontSize: 32, letterSpacing: 4),
            ),
            Text(
              'Loyalty Ecosystem',
              style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14, letterSpacing: 2),
            ),
            const SizedBox(height: 64),
            
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final version = snapshot.hasData ? snapshot.data!.version : 'Cargando...';
                return _buildAboutRow('Versión', version);
              },
            ),
            _buildAboutRow('Desarrollado por', 'Eddam'),
            _buildAboutRow('Corporación', 'EddamCore'),
            _buildAboutRow('Estado del Sistema', 'Online / Cloud Sync'),
            
            const SizedBox(height: 64),
            
            Text(
              'Este software ha sido diseñado para revolucionar la gestión de fidelidad en la industria de la barbería, fusionando tecnología Cyberpunk con operatividad premium.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.grey, height: 1.6),
            ),
            
            const SizedBox(height: 48),
            const Divider(color: Colors.white10),
            const SizedBox(height: 16),
            Text(
              '© 2026 EddamCore. Todos los derechos reservados.',
              style: TextStyle(color: Colors.white24, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value, style: GoogleFonts.robotoMono(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
