import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barber_gold/features/admin/providers/admin_provider.dart';
import 'package:barber_gold/features/admin/repositories/admin_repository.dart';
import 'package:barber_gold/features/admin/services/pdf_qr_service.dart';
import 'package:barber_gold/features/admin/models/card_admin_dto.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminCardsTab extends ConsumerStatefulWidget {
  const AdminCardsTab({super.key});

  @override
  ConsumerState<AdminCardsTab> createState() => _AdminCardsTabState();
}

class _AdminCardsTabState extends ConsumerState<AdminCardsTab> {
  bool _isGenerating = false;
  bool _isSelectionMode = false;
  final Set<String> _selectedTokens = {};

  void _toggleSelection(String token) {
    setState(() {
      if (_selectedTokens.contains(token)) {
        _selectedTokens.remove(token);
        if (_selectedTokens.isEmpty) _isSelectionMode = false;
      } else {
        _selectedTokens.add(token);
      }
    });
  }

  void _enterSelectionMode(String token) {
    setState(() {
      _isSelectionMode = true;
      _selectedTokens.add(token);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedTokens.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final allCardsAsync = ref.watch(allCardsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(allCardsAsync),
            Expanded(
              child: allCardsAsync.when(
                data: (cards) {
                  if (cards.isEmpty) return _emptyState();
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.82,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      final isSelected = _selectedTokens.contains(card.qrToken);
                      return _QrCard(
                        card: card,
                        isSelected: isSelected,
                        isSelectionMode: _isSelectionMode,
                        onTap: () {
                          if (_isSelectionMode) {
                            if (!card.isAssigned) _toggleSelection(card.qrToken);
                          } else {
                            _showPhotoCheck(context, card);
                          }
                        },
                        onLongPress: () {
                          if (!_isSelectionMode && !card.isAssigned) {
                            _enterSelectionMode(card.qrToken);
                          }
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
                error: (e, st) => _errorState(e),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isSelectionMode 
        ? FloatingActionButton.extended(
            onPressed: _selectedTokens.isEmpty ? null : () => PdfQrService.generateAndPrintBatch(_selectedTokens.toList()),
            backgroundColor: Colors.redAccent,
            icon: const Icon(Icons.print, color: Colors.white),
            label: Text('IMPRIMIR (${_selectedTokens.length})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        : null,
    );
  }

  Widget _buildHeader(AsyncValue<List<CardAdminDto>> asyncState) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_isSelectionMode) ...[
            IconButton(
              onPressed: _exitSelectionMode,
              icon: const Icon(Icons.close, color: Colors.white),
            ),
            Text(
              '${_selectedTokens.length} Seleccionados',
              style: GoogleFonts.outfit(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            asyncState.when(
              data: (cards) => IconButton(
                onPressed: () {
                  final available = cards.where((c) => !c.isAssigned).map((c) => c.qrToken);
                  setState(() => _selectedTokens.addAll(available));
                },
                icon: const Icon(Icons.select_all, color: Colors.white70),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ] else ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Inventario Total', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                asyncState.when(
                  data: (cards) {
                    final available = cards.where((c) => !c.isAssigned).length;
                    return Text('$available disponibles / ${cards.length} total', style: const TextStyle(color: Colors.grey));
                  },
                  loading: () => const Text('Cargando inventario...', style: TextStyle(color: Colors.grey)),
                  error: (_, __) => const Text('Error de sincronización', style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
            IconButton.filled(
              onPressed: _isGenerating ? null : () => _generateBatch(ref),
              style: IconButton.styleFrom(backgroundColor: Colors.redAccent),
              icon: _isGenerating 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.add_circle_outline, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _errorState(Object e) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text('Error: $e', style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_2, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Text('Inventario Vacío', style: TextStyle(color: Colors.grey, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Genera un lote para empezar', style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Future<void> _generateBatch(WidgetRef ref) async {
    setState(() => _isGenerating = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.generateBatch(10);
      ref.invalidate(allCardsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Lote de 10 QR generado!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }
}

class _QrCard extends StatelessWidget {
  final CardAdminDto card;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _QrCard({
    required this.card,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = card.isAssigned ? Colors.cyanAccent : Colors.redAccent;
    final String displayName = card.isAssigned 
        ? (card.assignedToFullName ?? 'Cliente') 
        : 'DISPONIBLE';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.redAccent : Colors.white.withOpacity(0.05),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4))
              ]
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      data: card.qrToken,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  displayName.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: statusColor, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 11
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${card.qrToken.substring(0, 8)}',
                  style: GoogleFonts.robotoMono(
                    color: Colors.white38, 
                    fontSize: 9
                  ),
                ),
              ],
            ),
          ),
          if (isSelectionMode && !card.isAssigned)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.redAccent : Colors.black45,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Icon(
                  isSelected ? Icons.check : null,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          if (card.isAssigned)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.cyanAccent, width: 0.5),
                ),
                child: const Text('OK', style: TextStyle(color: Colors.cyanAccent, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}

void _showPhotoCheck(BuildContext context, CardAdminDto card) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: card.isAssigned ? Colors.cyanAccent.withOpacity(0.3) : Colors.redAccent.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: (card.isAssigned ? Colors.cyanAccent : Colors.redAccent).withOpacity(0.1), 
                blurRadius: 20, 
                spreadRadius: 5
              )
            ]
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 60% SUPERIOR - IDENTIDAD
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.content_cut, color: card.isAssigned ? Colors.cyanAccent : Colors.redAccent, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            'BARBERGOLD',
                            style: GoogleFonts.outfit(
                              color: card.isAssigned ? Colors.cyanAccent : Colors.redAccent, 
                              fontWeight: FontWeight.w900, 
                              fontSize: 22,
                              letterSpacing: 2
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      Text(
                        card.isAssigned 
                            ? (card.assignedToFullName?.toUpperCase() ?? 'CLIENTE') 
                            : 'NUEVO MIEMBRO',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white, 
                          fontWeight: FontWeight.w800, 
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(height: 2, width: 60, color: card.isAssigned ? Colors.cyanAccent : Colors.redAccent),
                      const SizedBox(height: 16),
                      Text(
                        card.isAssigned ? 'STATUS: ACTIVE MEMBER' : 'CATEGORY: UNASSIGNED',
                        style: GoogleFonts.outfit(
                          color: card.isAssigned ? Colors.cyanAccent : Colors.redAccent, 
                          fontWeight: FontWeight.w700, 
                          fontSize: 14,
                          letterSpacing: 1.5
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '"Tu estilo, tu recompensa"',
                        style: GoogleFonts.outfit(
                          color: Colors.white38, 
                          fontSize: 12,
                          fontStyle: FontStyle.italic
                        ),
                      ),
                    ],
                  ),
                ),
                // 40% INFERIOR - FUNCIONAL
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF121212),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: QrImageView(
                          data: card.qrToken,
                          version: QrVersions.auto,
                          size: 100,
                          gapless: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ID: ${card.qrToken.substring(0, 8).toUpperCase()}',
                        style: GoogleFonts.robotoMono(
                          color: Colors.white70, 
                          fontWeight: FontWeight.bold,
                          fontSize: 14
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Escanea para sumar puntos\nNo compartas este código',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white24, fontSize: 10),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, color: card.isAssigned ? Colors.cyanAccent : Colors.redAccent, size: 16),
                          const SizedBox(width: 24),
                          Icon(Icons.chat_bubble_outline, color: card.isAssigned ? Colors.cyanAccent : Colors.redAccent, size: 16),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
