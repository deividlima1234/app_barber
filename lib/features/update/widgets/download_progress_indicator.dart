import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class DownloadProgressIndicator extends StatelessWidget {
  final double progress;

  const DownloadProgressIndicator({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 120,
              width: 120,
              child: CircularProgressIndicator(
                value: progress / 100,
                strokeWidth: 8,
                backgroundColor: AppTheme.secondaryColor,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            ),
            Text(
              '${progress.toInt()}%',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Descargando actualización...',
          style: GoogleFonts.montserrat(
            color: AppTheme.textColor.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
