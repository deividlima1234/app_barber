import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barber_gold/features/admin/models/prize.dart';
import 'package:barber_gold/features/admin/providers/prize_provider.dart';
import 'package:barber_gold/features/customer/providers/customer_provider.dart';
import 'package:barber_gold/features/admin/repositories/prize_repository.dart';
import 'package:lottie/lottie.dart';
import 'package:barber_gold/features/shared/widgets/friendly_error_widget.dart';

class RouletteScreen extends ConsumerStatefulWidget {
  const RouletteScreen({super.key});

  @override
  ConsumerState<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends ConsumerState<RouletteScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isSpinning = false;
  String? _wonPrizeName;
  String? _wonPrizeDesc;
  bool _wonRespin = false;
  double _stopAngle = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _spin() async {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _wonPrizeName = null;
    });

    try {
      final wallet = ref.read(customerDashboardProvider).value;
      if (wallet == null || wallet.qrToken == null) throw 'No se pudo identificar al cliente';

      final repo = ref.read(prizeRepositoryProvider);
      final result = await repo.spinRoulette(wallet.qrToken!);
      
      final activePrizes = ref.read(prizesProvider).value?.where((p) => p.isActive).toList() ?? [];
      
      if (activePrizes.isEmpty) throw 'No hay premios activos configurados';

      // Encontrar el índice del premio ganado para detener la ruleta exactamente ahí
      final wonIndex = activePrizes.indexWhere((p) => p.name == result['name']);
      
      if (wonIndex != -1) {
        final sweepAngle = 2 * pi / activePrizes.length;
        // Calculamos el ángulo para que el premio quede bajo el puntero (en la parte superior -pi/2)
        // Agregamos varias vueltas completas (8 vueltas * 2pi) para el efecto visual
        _stopAngle = (16 * pi) - (wonIndex * sweepAngle + sweepAngle / 2) - (pi / 2);
      } else {
        // Fallback si no se encuentra por nombre
        _stopAngle = 10 * pi;
      }

      _controller.reset();
      await _controller.forward();

      setState(() {
        _isSpinning = false;
        _wonPrizeName = result['name'];
        _wonPrizeDesc = result['description'] ?? "";
        _wonRespin = result['isRespin'] ?? false;
      });

      // Refrescar puntos antes del diálogo para que se vea actualizado al fondo
      ref.invalidate(customerDashboardProvider);

      if (mounted && _wonPrizeName != null) {
        _showWinDialog(_wonPrizeName!, _wonPrizeDesc!);
      }
    } catch (e) {
      setState(() => _isSpinning = false);
      String errorMessage = 'Error al girar la ruleta';
      
      if (e is DioException) {
        debugPrint("Error dio: ${e.response?.statusCode} - ${e.response?.data}");
        if (e.response?.data != null && e.response?.data['message'] != null) {
          errorMessage = e.response?.data['message'];
        } else if (e.response?.statusCode == 401) {
          errorMessage = 'Sesión expirada. Por favor, inicia sesión de nuevo.';
        } else {
          errorMessage = 'Error de conexión con el servidor de premios';
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage), 
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showWinDialog(String name, String desc) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), 
          side: BorderSide(color: _wonRespin ? Colors.amber : Colors.redAccent)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.network(
              'https://lottie.host/8099307c-9b16-43f1-9457-3f338d780727/8XjI7F70Gj.json', // Confetti estable
              width: 200,
              height: 200,
              repeat: false,
            ),
            Text(
              _wonRespin ? '¡RE-INTENTO!' : '¡FELICIDADES!',
              style: GoogleFonts.orbitron(
                color: _wonRespin ? Colors.amber : Colors.redAccent, 
                fontSize: 24, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _wonRespin ? 'Sigue intentando:' : 'Has ganado:',
              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
            ),
            Text(
              name,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _wonRespin ? Colors.amber : Colors.redAccent),
              onPressed: () {
                Navigator.pop(ctx);
                if (_wonRespin) _spin(); // Auto-reintento
              },
              child: Text(
                _wonRespin ? 'GIRAR DE NUEVO' : 'GENIAL', 
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prizesAsync = ref.watch(prizesProvider);
    final costAsync = ref.watch(rouletteCostProvider);
    final walletAsync = ref.watch(customerDashboardProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('RULETA GOLD', style: GoogleFonts.orbitron(letterSpacing: 2)),
        centerTitle: true,
      ),
      body: walletAsync.when(
        data: (wallet) => Column(
          children: [
            const SizedBox(height: 20),
            _buildPointsDisplay(wallet.totalPoints),
            const Spacer(),
            
            // The Wheel
            prizesAsync.when(
              data: (prizes) => Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _animation.value * _stopAngle,
                          child: _RouletteWheel(prizes: prizes.where((p) => p.isActive).toList()),
                        );
                      },
                    ),
                    // Pointer
                    Positioned(
                      top: 0,
                      child: Container(
                        width: 4,
                        height: 30,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => FriendlyErrorWidget(
                message: 'No pudimos cargar los premios de la ruleta. ¡Vuelve a intentarlo!',
                onRetry: () => ref.invalidate(prizesProvider),
              ),
            ),
            
            const Spacer(),
            
            costAsync.when(
              data: (cost) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                child: Column(
                  children: [
                    Text(
                      'Costo por giro: $cost PTS',
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          disabledBackgroundColor: Colors.grey[900],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: (_isSpinning || wallet.totalPoints < cost) ? null : _spin,
                        child: Text(
                          _isSpinning ? 'GIRANDO...' : '¡GIRAR AHORA!',
                          style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(),
              error: (e, st) => const SizedBox(),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => FriendlyErrorWidget(
          message: 'Error al conectar con tu cartera de puntos.',
          onRetry: () => ref.invalidate(customerDashboardProvider),
        ),
      ),
    );
  }

  Widget _buildPointsDisplay(int points) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars, color: Colors.amber, size: 24),
          const SizedBox(width: 8),
          Text(
            '$points PTS',
            style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _RouletteWheel extends StatelessWidget {
  final List<Prize> prizes;
  const _RouletteWheel({required this.prizes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.redAccent, width: 4),
        boxShadow: [
          BoxShadow(color: Colors.redAccent.withOpacity(0.2), blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: CustomPaint(
        painter: _WheelPainter(prizes),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<Prize> prizes;
  _WheelPainter(this.prizes);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (prizes.isEmpty) return;

    final sweepAngle = 2 * pi / prizes.length;

    for (int i = 0; i < prizes.length; i++) {
      final paint = Paint()
        ..color = i % 2 == 0 ? const Color(0xFF0D0D0D) : const Color(0xFF1A1A1A)
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, i * sweepAngle, sweepAngle, true, paint);

      // Draw text/icon placeholder
      final textAngle = i * sweepAngle + sweepAngle / 2;
      final x = center.dx + (radius * 0.7) * cos(textAngle);
      final y = center.dy + (radius * 0.7) * sin(textAngle);

      final textSpan = TextSpan(
        text: prizes[i].name.substring(0, min(prizes[i].name.length, 6)),
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(textAngle + pi / 2);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
