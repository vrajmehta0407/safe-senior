// lib/services/pdf_report_service.dart
// Generates a real SafeSenior Weekly Security Report PDF using the 'pdf' package.
// Saves to app documents directory and opens the native share sheet or PDF viewer.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/scanned_message.dart';

class PdfReportService {
  /// Generates the Weekly Security Report PDF and shares it via the native sheet.
  static Future<void> exportAndShare({
    required BuildContext context,
    required List<ScannedMessage> messages,
    required String userName,
  }) async {
    final pdf = pw.Document();

    final now        = DateTime.now();
    final weekStart  = now.subtract(Duration(days: now.weekday - 1));
    final dateRange  = '${DateFormat('d MMM').format(weekStart)} – ${DateFormat('d MMM yyyy').format(now)}';
    final scamCount  = messages.where((m) => m.isScam).length;
    final safeCount  = messages.where((m) => !m.isScam).length;

    final primaryColor  = PdfColor.fromHex('#1D8A74');   // AppTheme.primaryTeal
    final dangerColor   = PdfColor.fromHex('#D32F2F');   // red
    final safeColor     = PdfColor.fromHex('#2E7D32');   // green
    final bgColor       = PdfColor.fromHex('#F8FFFE');
    final textLight     = PdfColor.fromHex('#5E706D');
    final white         = PdfColors.white;

    // ── Build PDF ──────────────────────────────────────────────────────────
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (ctx) => [
        // Header
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: pw.BoxDecoration(
            color: primaryColor,
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'SafeSenior',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: white,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Weekly Security Report',
                    style: pw.TextStyle(fontSize: 14, color: PdfColor.fromHex('#C8F0EA')),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    dateRange,
                    style: pw.TextStyle(
                      fontSize: 13,
                      color: white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Generated for: $userName',
                    style: pw.TextStyle(fontSize: 11, color: PdfColor.fromHex('#C8F0EA')),
                  ),
                ],
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 24),

        // Stats row
        pw.Row(
          children: [
            _statBox('Total Scanned', messages.length.toString(), primaryColor, white),
            pw.SizedBox(width: 12),
            _statBox('Threats Blocked', scamCount.toString(), dangerColor, white),
            pw.SizedBox(width: 12),
            _statBox('Verified Safe', safeCount.toString(), safeColor, white),
          ],
        ),

        pw.SizedBox(height: 24),

        // Section title
        pw.Text(
          'Threat Activity Log',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: primaryColor,
          ),
        ),
        pw.SizedBox(height: 12),

        // Message table header
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: pw.BoxDecoration(color: primaryColor),
          child: pw.Row(
            children: [
              pw.Expanded(flex: 2, child: pw.Text('Sender', style: pw.TextStyle(color: white, fontWeight: pw.FontWeight.bold, fontSize: 10))),
              pw.Expanded(flex: 4, child: pw.Text('Message', style: pw.TextStyle(color: white, fontWeight: pw.FontWeight.bold, fontSize: 10))),
              pw.Expanded(flex: 2, child: pw.Text('Risk', style: pw.TextStyle(color: white, fontWeight: pw.FontWeight.bold, fontSize: 10))),
              pw.Expanded(flex: 2, child: pw.Text('Time', style: pw.TextStyle(color: white, fontWeight: pw.FontWeight.bold, fontSize: 10))),
            ],
          ),
        ),

        // Message rows
        if (messages.isEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Text(
              'No messages scanned this week. SafeSenior is actively protecting you.',
              style: pw.TextStyle(color: textLight, fontSize: 12, fontStyle: pw.FontStyle.italic),
            ),
          )
        else
          ...messages.asMap().entries.map((entry) {
            final i   = entry.key;
            final msg = entry.value;
            final bg  = i.isOdd ? bgColor : white;
            final riskLabel = msg.isScam ? 'SCAM' : 'SAFE';
            final riskColor = msg.isScam ? dangerColor : safeColor;
            final time = DateFormat('HH:mm').format(msg.receivedAt);

            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: bg,
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(msg.sender, style: const pw.TextStyle(fontSize: 10)),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(
                      msg.maskedBody.length > 80 ? '${msg.maskedBody.substring(0, 80)}...' : msg.maskedBody,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      riskLabel,
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: riskColor),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(time, style: const pw.TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            );
          }),

        pw.SizedBox(height: 24),

        // Footer
        pw.Divider(color: primaryColor),
        pw.SizedBox(height: 8),
        pw.Text(
          'SafeSenior — Senior Safety & Scam Neutralization Platform\n'
          'Report generated on ${DateFormat('d MMMM yyyy, HH:mm').format(now)}. For support: support@safesenior.app',
          style: pw.TextStyle(fontSize: 9, color: textLight),
          textAlign: pw.TextAlign.center,
        ),
      ],
    ));

    // ── Save & Share ───────────────────────────────────────────────────────
    try {
      final bytes    = await pdf.save();
      final dir      = await getApplicationDocumentsDirectory();
      final fileName = 'SafeSenior_Report_${DateFormat('yyyy-MM-dd').format(now)}.pdf';
      final file     = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      // Share via native share sheet (works on Android & iOS, with origin for tablets/iPad)
      final box = context.mounted ? (context.findRenderObject() as RenderBox?) : null;
      final origin = box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;
      final xFile = XFile(file.path, mimeType: 'application/pdf', name: fileName);
      await SharePlus.instance.share(
        ShareParams(
          text: 'SafeSenior Weekly Security Report — $dateRange',
          files: [xFile],
          sharePositionOrigin: origin,
        ),
      );
    } catch (e) {
      // Fallback: open PDF in-app viewer
      await Printing.layoutPdf(onLayout: (_) => pdf.save());
    }
  }

  static pw.Widget _statBox(String label, String value, PdfColor bg, PdfColor fg) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: pw.BoxDecoration(color: bg, borderRadius: pw.BorderRadius.circular(10)),
        child: pw.Column(
          children: [
            pw.Text(value, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: fg)),
            pw.SizedBox(height: 4),
            pw.Text(label, style: pw.TextStyle(fontSize: 10, color: fg)),
          ],
        ),
      ),
    );
  }
}
