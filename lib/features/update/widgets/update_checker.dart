import 'package:flutter/material.dart';
import '../services/update_service.dart';
import 'update_dialog.dart';
import 'package:barber_gold/router/app_router.dart';

class UpdateChecker extends StatefulWidget {
  final Widget child;

  const UpdateChecker({super.key, required this.child});

  @override
  State<UpdateChecker> createState() => _UpdateCheckerState();
}

class _UpdateCheckerState extends State<UpdateChecker> {
  final UpdateService _updateService = UpdateService();

  @override
  void initState() {
    super.initState();
    // Ejecutar después del primer frame para poder mostrar el diálogo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUpdate();
    });
  }

  Future<void> _checkUpdate() async {
    final updateData = await _updateService.checkForUpdate();
    
    if (updateData != null && mounted) {
      final String version = updateData['latestVersion'];
      final int skipCount = await _updateService.getSkipCount(version);
      
      // La actualización es obligatoria si se ha saltado 2 veces (la tercera es obligatoria)
      final bool isMandatory = skipCount >= 2;

      if (mounted) {
        final context = rootNavigatorKey.currentContext;
        if (context != null) {
          showDialog(
            context: context,
            barrierDismissible: false, // Bloquea clic fuera
            builder: (context) => UpdateDialog(
              updateData: updateData,
              isMandatory: isMandatory,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
