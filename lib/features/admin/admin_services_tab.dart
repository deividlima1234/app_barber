import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_gold/features/admin/models/service_catalog_dto.dart';
import 'package:barber_gold/features/admin/providers/admin_provider.dart';
import 'package:barber_gold/features/admin/repositories/admin_repository.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminServicesTab extends ConsumerStatefulWidget {
  const AdminServicesTab({super.key});

  @override
  ConsumerState<AdminServicesTab> createState() => _AdminServicesTabState();
}

class _AdminServicesTabState extends ConsumerState<AdminServicesTab> {
  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(adminServicesProvider);

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: servicesAsync.when(
            data: (services) {
              if (services.isEmpty) return _emptyState();
              
              final categories = <String, List<ServiceCatalogDto>>{};
              for (var s in services) {
                categories.putIfAbsent(s.category, () => []).add(s);
              }

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                children: categories.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            Text(
                              entry.key.toUpperCase(),
                              style: GoogleFonts.outfit(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Divider(color: Colors.redAccent.withOpacity(0.2))),
                          ],
                        ),
                      ),
                      ...entry.value.map((s) => _ServiceCard(service: s)).toList(),
                    ],
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
            error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Catálogo de Servicios',
                style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Text(
                'Gestiona el menú de tu barbería',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          IconButton.filled(
            onPressed: () => _showServiceDialog(context),
            style: IconButton.styleFrom(backgroundColor: Colors.redAccent),
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.content_cut, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Text('No hay servicios creados', style: TextStyle(color: Colors.grey, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Añade uno nuevo para empezar', style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  void _showServiceDialog(BuildContext context, [ServiceCatalogDto? service]) {
    showDialog(
      context: context,
      builder: (context) => _ServiceDialog(service: service),
    );
  }
}

class _ServiceCard extends ConsumerWidget {
  final ServiceCatalogDto service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: service.isActive ? Colors.white.withOpacity(0.05) : Colors.redAccent.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: service.isActive ? Colors.redAccent.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          child: Icon(
            _getIconForCategory(service.category),
            color: service.isActive ? Colors.redAccent : Colors.grey,
            size: 20,
          ),
        ),
        title: Text(
          service.name,
          style: GoogleFonts.outfit(
            color: service.isActive ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Row(
          children: [
            Text('\$${service.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '+${service.pointsReward} PTS',
                style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _editService(context, service),
              icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 20),
            ),
            Switch(
              value: service.isActive,
              activeColor: Colors.redAccent,
              onChanged: (val) async {
                await ref.read(adminRepositoryProvider).toggleService(service.id!);
                ref.invalidate(adminServicesProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'pelo': return Icons.face;
      case 'barba': return Icons.face_retouching_natural;
      case 'combo': return Icons.auto_awesome;
      default: return Icons.content_cut;
    }
  }

  void _editService(BuildContext context, ServiceCatalogDto service) {
    showDialog(
      context: context,
      builder: (context) => _ServiceDialog(service: service),
    );
  }
}

class _ServiceDialog extends ConsumerStatefulWidget {
  final ServiceCatalogDto? service;
  const _ServiceDialog({this.service});

  @override
  ConsumerState<_ServiceDialog> createState() => _ServiceDialogState();
}

class _ServiceDialogState extends ConsumerState<_ServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _pointsController;
  String _category = 'Pelo';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name ?? '');
    _priceController = TextEditingController(text: widget.service?.price.toString() ?? '');
    _pointsController = TextEditingController(text: widget.service?.pointsReward.toString() ?? '');
    _category = widget.service?.category ?? 'Pelo';

    if (widget.service == null) {
      _priceController.addListener(_autoCalculatePoints);
    }
  }

  void _autoCalculatePoints() {
    final priceStr = _priceController.text;
    if (priceStr.isNotEmpty) {
      final price = double.tryParse(priceStr) ?? 0;
      _pointsController.text = price.round().toString();
    }
  }

  @override
  void dispose() {
    _priceController.removeListener(_autoCalculatePoints);
    _nameController.dispose();
    _priceController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0A0A0A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
      ),
      title: Text(
        widget.service == null ? 'Nuevo Servicio' : 'Editar Servicio',
        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Nombre del Servicio', _nameController, Icons.label_outline),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField('Precio (\$)', _priceController, Icons.attach_money, isNumber: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Recompensa (PTS)', _pointsController, Icons.stars, isNumber: true)),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Por defecto: 1 punto por cada \$1',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.redAccent, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _category,
      dropdownColor: const Color(0xFF151515),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Categoría',
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.category_outlined, color: Colors.redAccent, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
      ),
      items: ['Pelo', 'Barba', 'Combo', 'Otro'].map((c) {
        return DropdownMenuItem(value: c, child: Text(c));
      }).toList(),
      onChanged: (val) => setState(() => _category = val!),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      final newService = ServiceCatalogDto(
        id: widget.service?.id,
        name: _nameController.text,
        category: _category,
        price: double.parse(_priceController.text),
        pointsReward: int.parse(_pointsController.text),
        isActive: widget.service?.isActive ?? true,
      );

      if (widget.service == null) {
        await repo.createService(newService);
      } else {
        await repo.updateService(newService);
      }

      ref.invalidate(adminServicesProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
