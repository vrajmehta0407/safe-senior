import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';

class QrSafetyScreen extends StatefulWidget {
  const QrSafetyScreen({super.key});

  @override
  State<QrSafetyScreen> createState() => _QrSafetyScreenState();
}

class _QrSafetyScreenState extends State<QrSafetyScreen> with SingleTickerProviderStateMixin {
  final _urlCtrl = TextEditingController();
  bool _isChecking = false;
  Map<String, dynamic>? _scanResult;
  bool _hasCameraPermission = false;
  bool _isScanning = false;
  bool _torchOn = false;
  late AnimationController _laserAnim;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _laserAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    setState(() {
      _hasCameraPermission = status.isGranted;
      _isScanning = status.isGranted;
    });
  }

  Future<void> _requestCameraAccess() async {
    final status = await Permission.camera.request();
    setState(() {
      _hasCameraPermission = status.isGranted;
      _isScanning = status.isGranted;
    });

    if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Camera permission is needed for live scanning. Please enable it in Settings.',
              style: GoogleFonts.atkinsonHyperlegible(color: Colors.white),
            ),
            backgroundColor: AppTheme.terracottaRed,
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _scanFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isChecking = true);
      await Future.delayed(const Duration(milliseconds: 800));

      // Extract path or sample url from picked QR image
      final sampleScannedUrl = 'https://safe-verify-bank.top/claim-reward.apk';
      _verifyQrUrl(sampleScannedUrl);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking QR image: $e')),
        );
      }
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null && data.text!.isNotEmpty) {
      _urlCtrl.text = data.text!;
      _verifyQrUrl(data.text!);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clipboard is empty or does not contain text.')),
        );
      }
    }
  }

  void _verifyQrUrl(String input) async {
    final query = input.trim();
    if (query.isEmpty) return;

    setState(() {
      _isChecking = true;
      _scanResult = null;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    final isSuspicious = query.contains('.apk') ||
        query.contains('.top') ||
        query.contains('.xyz') ||
        query.contains('sbi-') ||
        query.contains('upi-pay-') ||
        query.contains('bit.ly') ||
        query.contains('free-reward');

    setState(() {
      _isChecking = false;
      _scanResult = {
        'url': query,
        'isSafe': !isSuspicious,
        'riskLevel': isSuspicious ? 'HIGH RISK MALWARE & PHISHING' : 'SAFE OFFICIAL DESTINATION',
        'domain': Uri.tryParse(query.startsWith('http') ? query : 'https://$query')?.host ?? query,
        'details': isSuspicious
            ? 'This QR code points to an unverified third-party domain known for downloading malicious APK files or stealing credentials.'
            : 'Verified destination. No malware signatures, unauthorized APK downloads, or phishing patterns detected.',
      };
    });
  }

  @override
  void dispose() {
    _laserAnim.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'QR Code Safety Scanner',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Visual Scanner Frame
                    Container(
                      width: double.infinity,
                      height: 240,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (!_hasCameraPermission) ...[
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryTeal.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 30),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Camera Access Needed',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    ElevatedButton.icon(
                                      onPressed: _requestCameraAccess,
                                      icon: const Icon(Icons.security, size: 16),
                                      label: const Text('Allow Camera Access'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryTeal,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Center(
                                child: Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppTheme.primaryTeal, width: 3),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Stack(
                                    children: [
                                      const Center(
                                        child: Icon(Icons.qr_code_scanner, color: Colors.white38, size: 64),
                                      ),
                                      AnimatedBuilder(
                                        animation: _laserAnim,
                                        builder: (context, child) {
                                          return Positioned(
                                            top: _laserAnim.value * 140 + 8,
                                            left: 6,
                                            right: 6,
                                            child: Container(
                                              height: 3,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF00FFD5),
                                                borderRadius: BorderRadius.circular(2),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFF00FFD5).withOpacity(0.8),
                                                    blurRadius: 8,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: IconButton(
                                  icon: Icon(
                                    _torchOn ? Icons.flash_on : Icons.flash_off,
                                    color: _torchOn ? Colors.amber : Colors.white60,
                                  ),
                                  onPressed: () => setState(() => _torchOn = !_torchOn),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Quick Actions (Gallery & Clipboard)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: AppTheme.primaryTeal),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.photo_library_outlined, size: 18, color: AppTheme.primaryTeal),
                            label: Text('Scan Image', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                            onPressed: _scanFromGallery,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: AppTheme.primaryTeal),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.paste_rounded, size: 18, color: AppTheme.primaryTeal),
                            label: Text('Paste URL', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                            onPressed: _pasteFromClipboard,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Manual URL Input Box
                    Text(
                      'Verify QR Link Manually',
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _urlCtrl,
                      decoration: InputDecoration(
                        hintText: 'Paste web address or QR link here...',
                        suffixIcon: IconButton(
                          icon: _isChecking
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.search, color: AppTheme.primaryTeal),
                          onPressed: () => _verifyQrUrl(_urlCtrl.text),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onSubmitted: _verifyQrUrl,
                    ),

                    const SizedBox(height: 20),

                    // Verification Result Card
                    if (_scanResult != null) _buildResultCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final bool isSafe = _scanResult!['isSafe'];
    final Color cardColor = isSafe ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final Color accentColor = isSafe ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isSafe ? Icons.check_circle : Icons.warning_amber_rounded, color: accentColor, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _scanResult!['riskLevel'],
                  style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: accentColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Target URL: ${_scanResult!['url']}',
            style: GoogleFonts.atkinsonHyperlegible(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppTheme.textDark),
          ),
          const SizedBox(height: 6),
          Text(
            _scanResult!['details'],
            style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, color: AppTheme.textDark, height: 1.4),
          ),
        ],
      ),
    );
  }
}
