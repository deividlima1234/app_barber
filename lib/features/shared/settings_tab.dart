import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barber_gold/providers/auth_provider.dart';
import 'package:barber_gold/providers/profile_provider.dart';
import 'package:barber_gold/features/shared/widgets/user_profile_dialog.dart';
import 'package:barber_gold/features/shared/widgets/friendly_error_widget.dart';

// Importamos los proveedores que necesitan ser limpiados al cerrar sesión
import 'package:barber_gold/features/admin/providers/admin_provider.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AJUSTES',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 32),

              // Account Section
              _buildSectionTitle('CUENTA'),
              const SizedBox(height: 16),
              profileAsync.when(
                data: (profile) => _buildProfileHeader(context, profile),
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
                error: (e, _) => FriendlyErrorWidget(
                  message: 'No logramos sincronizar tu perfil. Es posible que el servidor esté en mantenimiento.',
                  onRetry: () => ref.invalidate(userProfileProvider),
                ),
              ),

              const SizedBox(height: 32),

              // Preferences Section
              _buildSectionTitle('PREFERENCIAS'),
              const SizedBox(height: 16),
              _buildSettingsTile(
                icon: Icons.notifications_none_outlined,
                title: 'Historial de Notificaciones',
                subtitle: 'Ver avisos y alertas recibidas',
                onTap: () => context.push('/notifications'),
              ),
              _buildSettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Tema Oscuro',
                subtitle: 'Apariencia de la aplicación',
                trailing: Switch(value: true, onChanged: (v) {}, activeColor: Colors.redAccent),
              ),

              const SizedBox(height: 32),

              // About Section (Expandable as requested)
              _buildSectionTitle('SOPORTE E INFO'),
              const SizedBox(height: 16),
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: const Icon(Icons.info_outline, color: Colors.blueAccent),
                  title: Text('Acerca de BarberGold', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('Versión v1.0.0', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
                  childrenPadding: const EdgeInsets.all(16),
                  iconColor: Colors.white54,
                  collapsedIconColor: Colors.white24,
                  children: [
                    _buildAboutItem('App Name', 'BarberGold'),
                    _buildAboutItem('Versión', 'v1.0.0'),
                    _buildAboutItem('Desarrollado por', 'Eddam Eloy'),
                    _buildAboutItem('Corporación', 'EddamCore'),
                    const SizedBox(height: 12),
                    const Text(
                      '© 2026 EddamCore - Todos los derechos reservados.',
                      style: TextStyle(color: Colors.white24, fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutConfirmation(context, ref),
                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text('CERRAR SESIÓN SEGURA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: Colors.redAccent,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic profile) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => showDialog(
            context: context, 
            builder: (context) => UserProfileDialog(profile: profile),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  child: Text(
                    profile.fullName[0].toUpperCase(),
                    style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.fullName,
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        profile.email,
                        style: GoogleFonts.outfit(color: Colors.white38, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon, 
    required String title, 
    required String subtitle, 
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white54, size: 20),
      ),
      title: Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: GoogleFonts.outfit(color: Colors.white24, fontSize: 12)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.white10, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildAboutItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
        ),
        title: Text(
          '¿CERRAR SESIÓN?',
          style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro de que deseas salir? Se limpiarán todos los datos de la sesión actual por seguridad.',
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white24)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _handleLogout(context, ref);
            },
            child: const Text('SÍ, SALIR'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    try {
      // 1. Limpiar persistencia (Token, Role, etc. en SecureStorage)
      await ref.read(authProvider.notifier).logout();

      // 2. Invalidar todos los proveedores de datos para borrar la caché de memoria
      // Esto asegura que la siguiente sesión empiece de cero
      ref.invalidate(userProfileProvider);
      ref.invalidate(adminUsersProvider);
      ref.invalidate(adminDashboardProvider);
      ref.invalidate(qrInventoryProvider);
      ref.invalidate(availableCardsProvider);
      ref.invalidate(allCardsProvider);
      ref.invalidate(adminServicesProvider);
      
      // Si hubiera otros proveedores específicos de clientes o barberos, añadirlos aquí
      
      if (context.mounted) context.go('/login');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
