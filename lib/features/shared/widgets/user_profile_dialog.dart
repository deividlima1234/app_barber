import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barber_gold/models/user_profile.dart';
import 'package:barber_gold/providers/profile_provider.dart';
import 'package:barber_gold/providers/auth_provider.dart';

class UserProfileDialog extends ConsumerStatefulWidget {
  final UserProfile profile;
  const UserProfileDialog({super.key, required this.profile});

  @override
  ConsumerState<UserProfileDialog> createState() => _UserProfileDialogState();
}

class _UserProfileDialogState extends ConsumerState<UserProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phone);
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(userProfileProvider.notifier).updateProfile(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final bool isAdmin = authState.userRole == 'ROLE_ADMIN';

    return Dialog(
      backgroundColor: const Color(0xFF121212),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.redAccent.withOpacity(0.2)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'IDENTIFICACIÓN',
              style: GoogleFonts.orbitron(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            // ID Card style info
            _buildInfoRow('EMAIL', widget.profile.email, isLocked: true),
            const SizedBox(height: 16),
            _buildInfoRow(
              'NOMBRE REAL',
              _nameController.text,
              controller: _nameController,
              isLocked: !isAdmin, // Solo admin puede cambiar el nombre
              isEditing: _isEditing,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'TELÉFONO',
              _phoneController.text,
              controller: _phoneController,
              isLocked: false, // Todos pueden cambiar su teléfono
              isEditing: _isEditing,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('ROL', widget.profile.role, isLocked: true),
            if (widget.profile.role == 'ROLE_CUSTOMER') ...[
              const SizedBox(height: 16),
              _buildInfoRow('PUNTOS', '${widget.profile.totalPoints} PTS', isLocked: true, valueColor: Colors.amberAccent),
            ],
            const SizedBox(height: 32),
            if (!_isEditing)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('CERRAR', style: TextStyle(color: Colors.white54)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _isEditing = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('EDITAR DATOS'),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                   Expanded(
                    child: TextButton(
                      onPressed: () => setState(() => _isEditing = false),
                      child: const Text('CANCELAR', style: TextStyle(color: Colors.white24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.withOpacity(0.8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('GUARDAR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (!_isEditing)
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Aquí podríamos redirigir a una pantalla de cambio de contraseña
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Usa la opción de "Olvidé mi contraseña" o contacta soporte para cambio de clave.')),
                    );
                  },
                  icon: const Icon(Icons.lock_outline, size: 16, color: Colors.blueAccent),
                  label: const Text('Cambiar Contraseña', style: TextStyle(color: Colors.blueAccent)),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {
    TextEditingController? controller,
    bool isLocked = true,
    bool isEditing = false,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
            if (isLocked) const Icon(Icons.lock, size: 12, color: Colors.white10),
          ],
        ),
        const SizedBox(height: 6),
        if (isEditing && !isLocked && controller != null)
          TextField(
            controller: controller,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent, width: 2)),
            ),
          )
        else
          Text(
            value,
            style: GoogleFonts.outfit(
              color: valueColor ?? Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
