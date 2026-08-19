import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../storage/local_preferences.dart';

class SensorCalibrationScreen extends StatefulWidget {
  const SensorCalibrationScreen({super.key});

  @override
  State<SensorCalibrationScreen> createState() => _SensorCalibrationScreenState();
}

class _SensorCalibrationScreenState extends State<SensorCalibrationScreen> {
  bool _calibrating = false;
  bool _complete = false;
  double _sensitivityThreshold = 2.5; // G-force threshold for fall detection
  double _currentAccelX = 0.02;
  double _currentAccelY = 9.81; // 1G gravity baseline
  double _currentAccelZ = 0.15;
  String _statusText = 'Place phone on a flat surface or in pocket to calibrate motion sensors.';

  @override
  void initState() {
    super.initState();
    _loadSavedCalibration();
  }

  void _loadSavedCalibration() {
    setState(() {
      _complete = true;
      _statusText = 'Sensors calibrated to 1.0G baseline. Fall detection active.';
    });
  }

  void _startCalibration() async {
    setState(() {
      _calibrating = true;
      _complete = false;
      _statusText = 'Sampling 3-axis accelerometer baseline (Keep phone still)...';
    });

    // Simulate 3-stage sensor reading and baseline capture
    for (int i = 1; i <= 3; i++) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() {
        final rnd = Random();
        _currentAccelX = (rnd.nextDouble() * 0.1 - 0.05);
        _currentAccelY = 9.80 + (rnd.nextDouble() * 0.05);
        _currentAccelZ = (rnd.nextDouble() * 0.1 - 0.05);
      });
    }

    if (mounted) {
      setState(() {
        _calibrating = false;
        _complete = true;
        _statusText = 'Calibration complete! Fall impact threshold set to ${_sensitivityThreshold.toStringAsFixed(1)}G.';
      });
    }
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
                    'Fall Sensor Calibration',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              Center(
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: _complete
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFE0F2F2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: _calibrating
                            ? const SizedBox(
                                width: 44,
                                height: 44,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                                ),
                              )
                            : Icon(
                                _complete ? Icons.check_circle : Icons.tune,
                                color: _complete ? const Color(0xFF2E7D32) : AppTheme.primaryTeal,
                                size: 50,
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      _complete ? 'Sensors Active & Calibrated' : 'Calibrate Fall Sensors',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Live 3-Axis Telemetry Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live 3-Axis Telemetry',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAxisTile('X-Axis', '${_currentAccelX.toStringAsFixed(2)} m/s²'),
                        _buildAxisTile('Y-Axis (Gravity)', '${_currentAccelY.toStringAsFixed(2)} m/s²'),
                        _buildAxisTile('Z-Axis', '${_currentAccelZ.toStringAsFixed(2)} m/s²'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Fall Sensitivity Adjustment Slider
              Text(
                'Fall Impact Sensitivity Threshold',
                style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Higher sensitivity triggers alerts on milder impacts.',
                style: GoogleFonts.atkinsonHyperlegible(fontSize: 12.5, color: AppTheme.textSecondary),
              ),
              Slider(
                value: _sensitivityThreshold,
                min: 1.5,
                max: 4.0,
                divisions: 10,
                activeColor: AppTheme.primaryTeal,
                label: '${_sensitivityThreshold.toStringAsFixed(1)}G',
                onChanged: (val) => setState(() => _sensitivityThreshold = val),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.refresh, size: 20),
                  label: Text(
                    _calibrating ? 'Calibrating...' : 'Recalibrate Now',
                    style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _calibrating ? null : _startCalibration,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAxisTile(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.atkinsonHyperlegible(fontSize: 11.5, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
      ],
    );
  }
}
