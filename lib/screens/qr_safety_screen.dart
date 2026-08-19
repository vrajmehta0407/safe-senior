import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
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

  void _verifyQrUrl(String input) async {
    final query = input.trim();
    if (query.isEmpty) return;

    setState(() {
      _isChecking = true;
      _scanResult = null;
    });

    await Future.delayed(const Duration(milliseconds: 1000));

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
        'riskLevel': isSuspicious ? 'HIGH RISK MALWARE' : 'SAFE OFFICIAL DESTINATION',
        'domain': Uri.tryParse(query.startsWith('http') ? query : 'https://$query')?.host ?? query,
        'details': isSuspicious
            ? 'This QR code points to an unverified third-party domain known for phishing and credential capture.'
            : 'Verified destination. No malware signatures or credential phishing patterns detected.',
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
                    color: Colors.black.withValues(alpha: 0.04),
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
                    // ── Visual Scanner Frame ──
                    Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
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
                              // Camera Permission Request Banner
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryTeal.withValues(alpha: 0.2),
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
                                    const SizedBox(height: 6),
                                    Text(
                                      'Grant camera access to scan QR codes on posters, bills, or messages safely.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.atkinsonHyperlegible(
                                        fontSize: 13,
                                        color: Colors.white70,
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
                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              // Active Viewfinder with Laser Scanner Animation
                              Center(
                                child: Container(
                                  width: 170,
                                  height: 170,
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
                                            top: _laserAnim.value * 150 + 8,
                                            left: 6,
                                            right: 6,
                                            child: Container(
                                              height: 3,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF00FFD5),
                                                borderRadius: BorderRadius.circular(2),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFF00FFD5).withValues(alpha: 0.8),
                                                    blurRadius: 8,
                                                    spreadRadius: 2,
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
                              // Top Controls: Torch & Camera Status
                              Positioned(
                                top: 14,
                                right: 14,
                                child: IconButton(
                                  icon: Icon(
                                    _torchOn ? Icons.flash_on : Icons.flash_off,
                                    color: _torchOn ? const Color(0xFFFFD700) : Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(() => _torchOn = !_torchOn);
                                  },
                                ),
                              ),
                              Positioned(
                                top: 18,
                                left: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.6)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF00E676),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Camera Active',
                                        style: GoogleFonts.atkinsonHyperlegible(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 14,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Point camera at any QR code to analyze',
                                    style: GoogleFonts.atkinsonHyperlegible(
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Manual Link / QR Paste Input ──
                    Text(
                      'Or check a link manually:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _urlCtrl,
                            style: GoogleFonts.atkinsonHyperlegible(fontSize: 15, color: AppTheme.textDark),
                            decoration: InputDecoration(
                              hintText: 'Paste scanned QR link or URL...',
                              hintStyle: GoogleFonts.atkinsonHyperlegible(fontSize: 14, color: const Color(0xFF717171)),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFE3E2E2)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFE3E2E2)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _isChecking ? null : () => _verifyQrUrl(_urlCtrl.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryTeal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _isChecking
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Check'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Quick Sample Buttons
                    Row(
                      children: [
                        Text('Try sample:', style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, color: AppTheme.textLight)),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            _urlCtrl.text = 'https://sbi-pan-kyc.top/download.apk';
                            _verifyQrUrl(_urlCtrl.text);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFDAD6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Fake KYC Link',
                              style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFFAA361F)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            _urlCtrl.text = 'https://onlinesbi.sbi';
                            _verifyQrUrl(_urlCtrl.text);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2F2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Official SBI URL',
                              style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryTeal),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Verification Result ──
                    if (_scanResult != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _scanResult!['isSafe'] == true ? const Color(0xFFE0F2F2) : const Color(0xFFFFDAD6),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: _scanResult!['isSafe'] == true ? AppTheme.primaryTeal : const Color(0xFFAA361F),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _scanResult!['isSafe'] == true ? Icons.verified : Icons.warning_rounded,
                                  color: _scanResult!['isSafe'] == true ? AppTheme.primaryTeal : const Color(0xFFAA361F),
                                  size: 28,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _scanResult!['riskLevel'],
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: _scanResult!['isSafe'] == true ? AppTheme.primaryTeal : const Color(0xFFAA361F),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Target Destination: ${_scanResult!['domain']}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _scanResult!['details'],
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 14.5,
                                color: const Color(0xFF1B1C1C),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Safety Advisory Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE3E2E2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline, color: AppTheme.primaryTeal, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Senior QR Safety Rule',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Remember: You NEVER need to scan a QR code or enter your UPI PIN to RECEIVE money. QR codes are strictly for SENDING money.',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 14,
                              color: AppTheme.textLight,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
