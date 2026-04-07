import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfQrService {
  static Future<void> generateAndPrintBatch(List<String> tokens) async {
    final pdf = pw.Document();

    // Cargar fuentes para el PDF (opcional, usamos las estándar para velocidad, 
    // pero podemos cargar las de Google si es necesario)
    final font = await PdfGoogleFonts.outfitBold();
    final monoFont = await PdfGoogleFonts.robotoMonoBold();

    // Agrupar de a 8 tarjetas por página A4
    for (var i = 0; i < tokens.length; i += 8) {
      final chunk = tokens.sublist(i, i + 8 > tokens.length ? tokens.length : i + 8);
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.GridView(
              crossAxisCount: 2,
              childAspectRatio: 0.63, // Proporción similar a tarjeta ID
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: chunk.map((token) => _buildPhotocheck(token, font, monoFont)).toList(),
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Batch_QR_BarberGold.pdf',
    );
  }

  static pw.Widget _buildPhotocheck(String token, pw.Font font, pw.Font monoFont) {
    const PdfColor primaryRed = PdfColor.fromInt(0xFFEE1111);
    const PdfColor darkBg = PdfColor.fromInt(0xFF0A0A0A);
    const PdfColor functionalBg = PdfColor.fromInt(0xFF121212);

    return pw.Container(
      decoration: pw.BoxDecoration(
        color: darkBg,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: primaryRed, width: 1),
      ),
      child: pw.Column(
        children: [
          // 60% BRANDING
          pw.Expanded(
            flex: 6,
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(12),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text('BARBERGOLD', style: pw.TextStyle(font: font, color: primaryRed, fontSize: 14)),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  pw.SizedBox(height: 16), // Espacio vacío para escribir a mano
                  pw.SizedBox(height: 4),
                  pw.Container(height: 1.5, width: 40, color: primaryRed),
                  pw.SizedBox(height: 10),
                  pw.Text('CATEGORY: UNASSIGNED', style: pw.TextStyle(font: font, color: primaryRed, fontSize: 8)),
                  pw.SizedBox(height: 4),
                  pw.Text('"Tu estilo, tu recompensa"', style: pw.TextStyle(color: PdfColors.grey400, fontSize: 7, fontStyle: pw.FontStyle.italic)),
                ],
              ),
            ),
          ),
          // 40% FUNCIONAL
          pw.Container(
            width: double.infinity,
            decoration: const pw.BoxDecoration(
              color: functionalBg,
              borderRadius: pw.BorderRadius.vertical(bottom: pw.Radius.circular(11)),
            ),
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(4),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.BarcodeWidget(
                    data: token,
                    width: 50,
                    height: 50,
                    barcode: pw.Barcode.qrCode(),
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text('ID: ${token.substring(0, 8).toUpperCase()}', style: pw.TextStyle(font: monoFont, color: PdfColors.white, fontSize: 8)),
                pw.SizedBox(height: 4),
                pw.Text('Escanea para sumar puntos', style: pw.TextStyle(color: PdfColors.grey600, fontSize: 6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
