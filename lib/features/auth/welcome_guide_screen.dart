import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:barber_gold/providers/auth_provider.dart';
import 'package:barber_gold/network/dio_client.dart';

import 'package:barber_gold/config/api_config.dart';

class WelcomeGuideScreen extends ConsumerStatefulWidget {
  const WelcomeGuideScreen({super.key});

  @override
  ConsumerState<WelcomeGuideScreen> createState() => _WelcomeGuideScreenState();
}

class _WelcomeGuideScreenState extends ConsumerState<WelcomeGuideScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isUpdating = false;

  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  Future<void> _finalizeSetup() async {
    if (_passController.text.isEmpty || _passController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres')),
      );
      return;
    }

    if (_passController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final dio = ref.read(dioClientProvider).dio;
      await dio.post(ApiConfig.finalizeSetup, data: {
        'newPassword': _passController.text,
      });

      // Si todo sale bien, avanzamos al último paso
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            physics: const NeverScrollableScrollPhysics(), // Force navigation via buttons
            children: [
              _buildStep1(),
              _buildStep2(),
              _buildStep3(),
              _buildStep4(),
            ],
          ),
          // Progress Dots
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) => _buildDot(index)),
            ),
          ),
          // Close/Cancel Button
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white54, size: 28),
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (mounted) context.go('/login');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return _buildBaseLayout(
      image: 'assets/images/avatares_gia/avatar_01.png',
      title: '¡Bienvenido a bordo!',
      subtitle: 'Hola, soy tu guía. Antes de empezar, necesitamos asegurar tu cuenta. Es un paso rápido, ¡prometido!',
      buttonLabel: 'COMENZAR',
      onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
    );
  }

  Widget _buildStep2() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF000000), Color(0xFF1A0000)],
        ),
      ),
      child: _buildBaseLayout(
        image: 'assets/images/avatares_gia/avatar_02.png',
        title: 'Tu seguridad es importante 🔒',
        subtitle: 'Una buena contraseña protege tu información y tus reservas de accesos no autorizados. ¡Vamos a crear una fuerte!',
        buttonLabel: 'ENTENDIDO',
        onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
        isDark: true,
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
       child: Container(
         height: MediaQuery.of(context).size.height,
         child: _buildBaseLayout(
          image: 'assets/images/avatares_gia/avatar_03.png',
          title: 'Crea tu nueva contraseña',
          subtitle: 'Escribe tu nueva clave aquí. Usa al menos 6 caracteres mezclando letras y números.',
          customContent: Column(
            children: [
              const SizedBox(height: 16),
              _buildCyberInput(controller: _passController, label: 'NUEVA CONTRASEÑA', isPassword: true),
              const SizedBox(height: 16),
              _buildCyberInput(controller: _confirmPassController, label: 'CONFIRMAR CONTRASEÑA', isPassword: true),
            ],
          ),
          buttonLabel: _isUpdating ? 'GUARDANDO...' : 'ACTUALIZAR CLAVE',
          onPressed: _isUpdating ? null : _finalizeSetup,
        ),
       ),
    );
  }

  Widget _buildStep4() {
    return Stack(
      children: [
        _buildBaseLayout(
          image: 'assets/images/avatares_gia/avatar_04.png',
          title: '¡Todo listo! 🎉',
          subtitle: 'Tu contraseña ha sido actualizada con éxito. Ya estás listo para empezar a trabajar con nosotros.',
          buttonLabel: 'IR A LA APP',
          onPressed: () async {
            // Actualizamos estado local y persistido para que el router sepa que terminó
            await ref.read(authProvider.notifier).markFirstLoginCompleted();
            if (mounted) context.go('/login'); // El router redirigirá al dashboard correcto
          },
        ),
        // Brillo de fondo con Icono de éxito nativo
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.5),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 120,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBaseLayout({
    required String image,
    required String title,
    required String subtitle,
    Widget? customContent,
    String? buttonLabel,
    VoidCallback? onPressed,
    bool isDark = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 80),
          // Avatar
          Expanded(
            flex: 3,
            child: Image.asset(image, fit: BoxFit.contain),
          ),
          const SizedBox(height: 24),
          // Diálogo
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.black54 : const Color(0xFFFFE5E5),
              borderRadius: BorderRadius.circular(24),
              border: isDark ? Border.all(color: Colors.redAccent.withOpacity(0.3)) : null,
            ),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                if (customContent != null) customContent,
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (buttonLabel != null)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  buttonLabel,
                  style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
              ),
            ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildCyberInput({required TextEditingController controller, required String label, bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.redAccent, fontSize: 10),
        filled: true,
        fillColor: Colors.black,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.redAccent : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
