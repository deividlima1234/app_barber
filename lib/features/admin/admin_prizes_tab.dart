import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/features/admin/models/prize.dart';
import 'package:barber_gold/features/admin/providers/prize_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminPrizesTab extends ConsumerWidget {
  const AdminPrizesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prizesAsync = ref.watch(prizesProvider);
    final costAsync = ref.watch(rouletteCostProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () => _showPrizeDialog(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestión de Ruleta',
                    style: GoogleFonts.orbitron(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configura los premios y probabilidades del sistema.',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 24),
                  
                  // Card para el costo del giro
                  _buildCostCard(context, ref, costAsync),
                  
                  const SizedBox(height: 32),
                  Text(
                    'Premios Activos',
                    style: GoogleFonts.orbitron(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
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
            error: (e, st) => SliverToBoxAdapter(child: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red)))),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildCostCard(BuildContext context, WidgetRef ref, AsyncValue<int> costAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: costAsync.when(
        data: (cost) => Row(
          children: [
            const Icon(Icons.stars, color: Colors.amber, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Costo por Giro', style: TextStyle(color: Colors.grey)),
                  Text(
                    '$cost Puntos',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.redAccent),
              onPressed: () => _showCostDialog(context, ref, cost),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Text('Error: $e'),
      ),
    );
  }

  void _showCostDialog(BuildContext context, WidgetRef ref, int currentCost) {
    final controller = TextEditingController(text: currentCost.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Editar Costo de Ruleta', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: 'Puntos por giro'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final newCost = int.tryParse(controller.text);
              if (newCost != null) {
                ref.read(prizeActionProvider.notifier).updateCost(newCost);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar'),
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(prize == null ? 'Nuevo Premio' : 'Editar Premio', style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: descController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Descripción')),
              TextField(
                controller: weightController, 
                keyboardType: TextInputType.number, 
                style: const TextStyle(color: Colors.white), 
                decoration: const InputDecoration(labelText: 'Peso (Probabilidad)', helperText: 'Más alto = Más común'),
              ),
              TextField(
                controller: stockController, 
                keyboardType: TextInputType.number, 
                style: const TextStyle(color: Colors.white), 
                decoration: const InputDecoration(labelText: 'Stock (Opcional)', helperText: 'Vacío si es ilimitado'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final newPrize = Prize(
                id: prize?.id,
                name: nameController.text,
                description: descController.text,
                weight: int.tryParse(weightController.text) ?? 10,
                stock: int.tryParse(stockController.text),
              );
              if (prize == null) {
                ref.read(prizeActionProvider.notifier).createPrize(newPrize);
              } else {
                ref.read(prizeActionProvider.notifier).updatePrize(newPrize);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
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
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: prize.isActive ? Colors.redAccent.withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(prize.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (prize.description != null) Text(prize.description!, style: TextStyle(color: Colors.grey[500])),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTag('Peso: ${prize.weight}', Colors.blueAccent),
                const SizedBox(width: 8),
                _buildTag(prize.stock == null ? 'Ilimitado' : 'Stock: ${prize.stock}', Colors.greenAccent),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: prize.isActive,
              onChanged: (_) => ref.read(prizeActionProvider.notifier).togglePrize(prize.id!),
              activeColor: Colors.redAccent,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: () => ref.read(prizeActionProvider.notifier).deletePrize(prize.id!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}
