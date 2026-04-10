import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/features/admin/models/prize.dart';
import 'package:barber_gold/features/admin/providers/prize_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barber_gold/features/shared/widgets/friendly_error_widget.dart';

class AdminPrizesTab extends ConsumerWidget {
  const AdminPrizesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prizesAsync = ref.watch(prizesProvider);
    final costAsync = ref.watch(rouletteCostProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('NUEVO PREMIO', style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold)),
        onPressed: () => _showPrizeDialog(context, ref),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.redAccent.withOpacity(0.15), Colors.black],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RULETA GOLD',
                            style: GoogleFonts.orbitron(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            'CONFIGURACIÓN DE GAMIFICACIÓN',
                            style: GoogleFonts.outfit(
                              color: Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.settings_suggest, color: Colors.white24, size: 40),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildCostCard(context, ref, costAsync),
                ],
              ),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'LISTADO DE PREMIOS',
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white38,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),

          prizesAsync.when(
            data: (prizes) => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _PrizeCard(prize: prizes[index]),
                  childCount: prizes.length,
                ),
              ),
            ),
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: Colors.redAccent))),
            error: (e, st) => SliverToBoxAdapter(
              child: FriendlyErrorWidget(
                message: 'No logramos sincronizar los premios con el servidor.',
                onRetry: () => ref.invalidate(prizesProvider),
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildCostCard(BuildContext context, WidgetRef ref, AsyncValue<int> costAsync) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: costAsync.when(
        data: (cost) => Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.stars_rounded, color: Colors.amber, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('COSTO POR GIRO', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(
                    '$cost PUNTOS',
                    style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showCostDialog(context, ref, cost),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.edit_note_rounded, color: Colors.redAccent),
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, st) => const Text('Error al cargar', style: TextStyle(color: Colors.redAccent)),
      ),
    );
  }

  void _showCostDialog(BuildContext context, WidgetRef ref, int currentCost) {
    final controller = TextEditingController(text: currentCost.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Colors.white10)),
        title: Text('AJUSTAR COSTO', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            suffixText: 'PTS',
            suffixStyle: GoogleFonts.outfit(color: Colors.white24),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR', style: TextStyle(color: Colors.white24))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              final newCost = int.tryParse(controller.text);
              if (newCost != null) {
                ref.read(prizeActionProvider.notifier).updateCost(newCost);
                Navigator.pop(ctx);
              }
            },
            child: const Text('ACTUALIZAR'),
          ),
        ],
      ),
    );
  }

  void _showPrizeDialog(BuildContext context, WidgetRef ref, [Prize? prize]) {
    final nameController = TextEditingController(text: prize?.name);
    final descController = TextEditingController(text: prize?.description);
    final weightController = TextEditingController(text: prize?.weight.toString() ?? '10');
    final stockController = TextEditingController(text: prize?.stock?.toString() ?? '');
    bool isRespin = prize?.isRespin ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Colors.white10)),
            title: Text(prize == null ? 'NUEVO PREMIO' : 'EDITAR PREMIO', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dialogField('Nombre del Premio', nameController, 'Ej: Corte Gratis'),
                  const SizedBox(height: 16),
                  _dialogField('Descripción', descController, 'Detalles del premio...'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _dialogField('Peso (Prob.)', weightController, '1-100', isNumeric: true)),
                      const SizedBox(width: 16),
                      Expanded(child: _dialogField('Stock', stockController, 'Ilimitado', isNumeric: true)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Probabilidad estimada: ${_getWeightLabel(int.tryParse(weightController.text) ?? 0)}',
                    style: TextStyle(color: _getWeightColor(int.tryParse(weightController.text) ?? 0), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12)),
                    child: CheckboxListTile(
                      title: Text('¿ES RE-INTENTO?', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('El usuario gira de nuevo sin perder puntos.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                      value: isRespin,
                      activeColor: Colors.amber,
                      onChanged: (val) => setState(() => isRespin = val ?? false),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR', style: TextStyle(color: Colors.white24))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  final newPrize = Prize(
                    id: prize?.id,
                    name: nameController.text,
                    description: descController.text,
                    weight: int.tryParse(weightController.text) ?? 10,
                    stock: int.tryParse(stockController.text),
                    isRespin: isRespin,
                    isActive: prize?.isActive ?? true,
                  );
                  if (prize == null) {
                    ref.read(prizeActionProvider.notifier).createPrize(newPrize);
                  } else {
                    ref.read(prizeActionProvider.notifier).updatePrize(newPrize);
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('GUARDAR'),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _dialogField(String label, TextEditingController controller, String hint, {bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.orbitron(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white10),
            filled: true,
            fillColor: Colors.white.withOpacity(0.03),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  String _getWeightLabel(int weight) {
    if (weight <= 2) return 'LEGENDARIO (MUY RARO)';
    if (weight <= 5) return 'EPICO (RARO)';
    if (weight <= 15) return 'RARO (POCO COMÚN)';
    return 'COMÚN';
  }

  Color _getWeightColor(int weight) {
    if (weight <= 2) return Colors.amber;
    if (weight <= 5) return Colors.purpleAccent;
    if (weight <= 15) return Colors.blueAccent;
    return Colors.grey;
  }
}

class _PrizeCard extends ConsumerWidget {
  final Prize prize;
  const _PrizeCard({required this.prize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: prize.isActive ? const Color(0xFF151515) : Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: prize.isActive ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.02),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => const AdminPrizesTab()._showPrizeDialog(context, ref, prize),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: prize.isActive ? Colors.redAccent.withOpacity(0.05) : Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    prize.isRespin ? Icons.autorenew_rounded : Icons.card_giftcard_rounded,
                    color: prize.isActive ? Colors.redAccent : Colors.white24,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prize.name,
                        style: GoogleFonts.outfit(
                          color: prize.isActive ? Colors.white : Colors.white24,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (prize.description != null)
                        Text(
                          prize.description!,
                          style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          _tag('PESO: ${prize.weight}', prize.isActive ? Colors.blueAccent : Colors.white10),
                          _tag(prize.stock == null ? 'INF.' : 'STOCK: ${prize.stock}', prize.isActive ? Colors.greenAccent : Colors.white10),
                          if (prize.isRespin) _tag('RE-INTENTO', prize.isActive ? Colors.amber : Colors.white10),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Switch(
                      value: prize.isActive,
                      onChanged: (val) => ref.read(prizeActionProvider.notifier).togglePrize(prize.id!),
                      activeColor: Colors.redAccent,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.white12, size: 20),
                      onPressed: () => _confirmDelete(context, ref),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('¿Eliminar Premio?', style: TextStyle(color: Colors.white)),
        content: Text('Esta acción no se puede deshacer.', style: TextStyle(color: Colors.grey[400])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () {
              ref.read(prizeActionProvider.notifier).deletePrize(prize.id!);
              Navigator.pop(context);
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
