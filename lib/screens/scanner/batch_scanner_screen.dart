import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../models/content_type.dart';
import '../../models/scanned_code.dart';
import '../../providers/history_provider.dart';
import '../../services/export_service.dart';
import '../../widgets/sv_button.dart';

class BatchScannerScreen extends StatefulWidget {
  const BatchScannerScreen({super.key});

  @override
  State<BatchScannerScreen> createState() => _BatchScannerScreenState();
}

class _BatchScannerScreenState extends State<BatchScannerScreen> {
  late MobileScannerController _controller;
  final List<ScannedCode> _batchSession = [];
  final Map<String, DateTime> _lastScannedTimes = {};

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.unrestricted,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final raw = barcode.rawValue;
    if (raw == null || raw.isEmpty) return;

    final now = DateTime.now();

    // De-duplication filter: ignore same raw value scanned within 3 seconds
    if (_lastScannedTimes.containsKey(raw)) {
      final lastTime = _lastScannedTimes[raw]!;
      if (now.difference(lastTime).inSeconds < 3) {
        return;
      }
    }

    _lastScannedTimes[raw] = now;

    HapticFeedback.lightImpact();

    final history = Provider.of<HistoryProvider>(context, listen: false);
    final scannedCode = await history.addScan(
      rawValue: raw,
      format: barcode.format.name.toUpperCase(),
      source: ScanSource.batch,
    );

    setState(() {
      _batchSession.insert(0, scannedCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Batch Mode (${_batchSession.length})',
          style: AppTypography.titleLarge().copyWith(color: Colors.white),
        ),
        actions: [
          if (_batchSession.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share_rounded, color: AppColors.electricCoral),
              onPressed: () {
                final csvData = ExportService.toCsv(_batchSession);
                SharePlus.instance.share(ShareParams(text: csvData, subject: 'ScanVault Batch Export (${_batchSession.length} items)'));
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Top guidance text
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.68),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                'Point camera at codes continuously. Session saves automatically.',
                style: AppTypography.bodySmall().copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Bottom horizontal list strip of batch items
          if (_batchSession.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 110,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _batchSession.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final code = _batchSession[index];
                        return Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : AppColors.warmWhite,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.electricCoral, width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                code.parsedContent.title,
                                style: AppTypography.labelLarge(isDark: isDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                code.format,
                                style: AppTypography.labelSmall(isDark: isDark).copyWith(
                                  color: AppColors.electricCoral,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SVButton(
                      label: 'Done Scanning (${_batchSession.length})',
                      fullWidth: true,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

