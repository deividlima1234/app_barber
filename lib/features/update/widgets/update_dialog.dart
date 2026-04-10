import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ota_update/ota_update.dart';
import '../services/update_service.dart';
import 'download_progress_indicator.dart';
import '../../../theme/app_theme.dart';

class UpdateDialog extends StatefulWidget {
  final Map<String, dynamic> updateData;
  final bool isMandatory;

  const UpdateDialog({
    super.key,
    required this.updateData,
    required this.isMandatory,
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  final UpdateService _updateService = UpdateService();
  bool _isDownloading = false;
  double _progress = 0;
  String? _error;

  void _startDownload() {
    setState(() {
      _isDownloading = true;
      _error = null;
    });

    _updateService.downloadAndInstall(widget.updateData['downloadUrl']).listen(
      (OtaEvent event) {
        setState(() {
          if (event.status == OtaStatus.DOWNLOADING) {
            _progress = double.tryParse(event.value ?? '0') ?? 0;
          } else if (event.status == OtaStatus.INSTALLING) {
            _isDownloading = false;
            _progress = 100;
          } else {
            _isDownloading = false;
            _error = 'Error: ${event.status}';
          }
        });
      },
      onError: (e) {
        setState(() {
          _isDownloading = false;
          _error = 'Error de descarga: $e';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Bloquea el botón atrás físico
      child: Dialog(
        backgroundColor: AppTheme.secondaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 1),
          ),
          child: _isDownloading
              ? DownloadProgressIndicator(progress: _progress)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.system_update_rounded,
                        color: AppTheme.primaryColor,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Nueva actualización',
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'BarberGold v${widget.updateData['latestVersion']}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 16,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (widget.updateData['releaseNotes'].toString().isNotEmpty)
                      Flexible(
                        child: SingleChildScrollView(
                          child: Text(
                            widget.updateData['releaseNotes'],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: AppTheme.textColor.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ElevatedButton(
                      onPressed: _startDownload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: AppTheme.textColor,
                        elevation: 8,
                        shadowColor: AppTheme.primaryColor.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('DESCARGAR AHORA'),
                    ),
                    if (!widget.isMandatory) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          _updateService.incrementSkipCount(widget.updateData['latestVersion']);
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'MÁS TARDE',
                          style: GoogleFonts.montserrat(
                            color: AppTheme.textColor.withOpacity(0.5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
