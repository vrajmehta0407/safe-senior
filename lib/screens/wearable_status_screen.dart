import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/permission_service.dart';

class WearableStatusScreen extends StatefulWidget {
  const WearableStatusScreen({super.key});

  @override
  State<WearableStatusScreen> createState() => _WearableStatusScreenState();
}

class _WearableStatusScreenState extends State<WearableStatusScreen> {
  bool _isConnected = true;
  bool _isScanning = false;
  int _batteryLevel = 84;
  int _heartRate = 72;
  String _deviceName = 'SafeSenior SOS Smart Band';
  String _macAddress = '7C:9E:BD:41:A2:18';

  void _startBleScan() async {
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isScanning = false;
        _isConnected = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected to $_deviceName ($_macAddress)'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
    }
  }

  void _testPanicButtonSignal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.ring_volume, color: AppTheme.primaryTeal),
            const SizedBox(width: 8),
            Text('Panic Button Test', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Press the physical SOS button on your smartwatch now. A loud test tone will sound when signal is received.',
          style: GoogleFonts.atkinsonHyperlegible(fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppTheme.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Wearable Protection',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Device Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: _isConnected ? const Color(0xFFE0F2F2) : const Color(0xFFFFEBEE),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          _isConnected ? Icons.watch : Icons.watch_off,
                          color: _isConnected ? AppTheme.primaryTeal : AppTheme.dangerRed,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _deviceName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                          color: _isConnected ? const Color(0xFF2E7D32) : AppTheme.dangerRed,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isConnected ? 'Connected • Battery $_batteryLevel%' : 'Disconnected',
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: _isConnected ? const Color(0xFF2E7D32) : AppTheme.dangerRed,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Status Metrics
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMetricRow(Icons.favorite_rounded, 'Senior Heart Rate', '$_heartRate BPM (Normal)', const Color(0xFFE91E63)),
                    const Divider(height: 24),
                    _buildMetricRow(Icons.directions_run_rounded, 'Fall Detection Monitor', 'Active & Calibrated', const Color(0xFF2E7D32)),
                    const Divider(height: 24),
                    _buildMetricRow(Icons.signal_cellular_alt_rounded, 'BLE Signal (RSSI)', '-58 dBm (Strong)', AppTheme.primaryTeal),
                  ],
                ),
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppTheme.primaryTeal),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.volume_up, color: AppTheme.primaryTeal),
                      label: Text('Test SOS Signal', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                      onPressed: _testPanicButtonSignal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: _isScanning
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.bluetooth_searching),
                      label: Text(_isScanning ? 'Scanning...' : 'Pair Device', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                      onPressed: _isScanning ? null : _startBleScan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(IconData icon, String title, String val, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title, style: GoogleFonts.atkinsonHyperlegible(fontSize: 14, color: AppTheme.textPrimary)),
        ),
        Text(val, style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
      ],
    );
  }
}
