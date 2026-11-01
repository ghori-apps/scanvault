import '../../ads/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../models/content_type.dart';
import '../../providers/history_provider.dart';
import '../../providers/settings_provider.dart';
import '../result/result_sheet.dart';
import 'batch_scanner_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with WidgetsBindingObserver {
  late MobileScannerController _cameraController;
  bool _isProcessing = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_cameraController.value.isInitialized) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _cameraController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _cameraController.start();
    }
  }

  void _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final rawValue = barcode.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _isProcessing = true);

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final history = Provider.of<HistoryProvider>(context, listen: false);

    // Provide audio & haptic feedback
    if (settings.soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    if (settings.vibrationEnabled) {
      HapticFeedback.mediumImpact();
    }

    final formatName = barcode.format.name.toUpperCase();

    // Save scan to local vault storage
    final scannedCode = await history.addScan(
      rawValue: rawValue,
      format: formatName,
      source: ScanSource.camera,
      isIncognito: settings.incognitoMode,
    );

    if (!mounted) return;

    // Slide up Smart Result Sheet
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ResultSheet(code: scannedCode),
    );

    // Reset processing lock when result sheet dismissed
    if (mounted) {
      setState(() => _isProcessing = false);
      AdService.onActionCompleted(triggerFrequency: 4);
    }
  }

  Future<void> _scanFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _isProcessing = true);
      final capture = await _cameraController.analyzeImage(image.path);

      if (capture != null && capture.barcodes.isNotEmpty) {
        final rawValue = capture.barcodes.first.rawValue;
        final format = capture.barcodes.first.format.name.toUpperCase();

        if (rawValue != null && mounted) {
          final history = Provider.of<HistoryProvider>(context, listen: false);
          final settings = Provider.of<SettingsProvider>(context, listen: false);

          final scannedCode = await history.addScan(
            rawValue: rawValue,
            format: format,
            source: ScanSource.gallery,
            isIncognito: settings.incognitoMode,
          );

          if (mounted) {
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => ResultSheet(code: scannedCode),
            );
          }
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No QR code or barcode detected in image.')),
        );
      }

      if (mounted) {
        setState(() => _isProcessing = false);
      AdService.onActionCompleted(triggerFrequency: 4);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Live Camera Preview
          MobileScanner(
            controller: _cameraController,
            onDetect: _onBarcodeDetected,
          ),

          // Custom Scanner Framing Mask
          CustomPaint(
            size: Size.infinite,
            painter: _ScannerOverlayPainter(
              frameColor: AppColors.electricCoral,
            ),
          ),

          // Header Overlay Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Branding Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.electricCoral,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ScanVault',
                          style: AppTypography.labelLarge().copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Top Action Controls (Torch & Camera Switch)
                  Row(
                    children: [
                      _buildHeaderButton(
                        icon: _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                        onPressed: () {
                          _cameraController.toggleTorch();
                          setState(() => _isTorchOn = !_isTorchOn);
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildHeaderButton(
                        icon: Icons.cameraswitch_rounded,
                        onPressed: () => _cameraController.switchCamera(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Bar (Gallery & Batch Mode)
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery Pick
                  _buildBottomActionButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onPressed: _scanFromGallery,
                  ),

                  // Batch Scan Mode Toggle
                  _buildBottomActionButton(
                    icon: Icons.filter_center_focus_rounded,
                    label: 'Batch Mode',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BatchScannerScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildBottomActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white30),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.electricCoral, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.labelLarge().copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter rendering dark mask around clear scan viewfinder window.
class _ScannerOverlayPainter extends CustomPainter {
  final Color frameColor;

  _ScannerOverlayPainter({required this.frameColor});

  @override
  void paint(Canvas canvas, Size size) {
    final windowSize = size.width * 0.72;
    final windowRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 30),
      width: windowSize,
      height: windowSize,
    );

    // Dark background mask
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final windowPath = Path()..addRRect(RRect.fromRectAndRadius(windowRect, const Radius.circular(20)));
    final maskPath = Path.combine(PathOperation.difference, backgroundPath, windowPath);

    final maskPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    canvas.drawPath(maskPath, maskPaint);

    // Viewfinder Corner Brackets
    final cornerPaint = Paint()
      ..color = frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    const cornerLength = 28.0;

    // Top-Left Corner
    canvas.drawPath(
      Path()
        ..moveTo(windowRect.left, windowRect.top + cornerLength)
        ..lineTo(windowRect.left, windowRect.top + 20)
        ..arcToPoint(Offset(windowRect.left + 20, windowRect.top), radius: const Radius.circular(20))
        ..lineTo(windowRect.left + cornerLength, windowRect.top),
      cornerPaint,
    );

    // Top-Right Corner
    canvas.drawPath(
      Path()
        ..moveTo(windowRect.right - cornerLength, windowRect.top)
        ..lineTo(windowRect.right - 20, windowRect.top)
        ..arcToPoint(Offset(windowRect.right, windowRect.top + 20), radius: const Radius.circular(20))
        ..lineTo(windowRect.right, windowRect.top + cornerLength),
      cornerPaint,
    );

    // Bottom-Left Corner
    canvas.drawPath(
      Path()
        ..moveTo(windowRect.left, windowRect.bottom - cornerLength)
        ..lineTo(windowRect.left, windowRect.bottom - 20)
        ..arcToPoint(Offset(windowRect.left + 20, windowRect.bottom), radius: const Radius.circular(20))
        ..lineTo(windowRect.left + cornerLength, windowRect.bottom),
      cornerPaint,
    );

    // Bottom-Right Corner
    canvas.drawPath(
      Path()
        ..moveTo(windowRect.right - cornerLength, windowRect.bottom)
        ..lineTo(windowRect.right - 20, windowRect.bottom)
        ..arcToPoint(Offset(windowRect.right, windowRect.bottom - 20), radius: const Radius.circular(20))
        ..lineTo(windowRect.right, windowRect.bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

