import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/guardian_provider.dart';
import '../storage/local_preferences.dart';
import '../theme.dart';
import '../utils/app_translations.dart';
import 'emergency_screen.dart';
import 'guardian_contacts_screen.dart';

class UnusualLocationScreen extends ConsumerStatefulWidget {
  final String? detectedLocation;
  final String? expectedLocation;
  final String? timeDetected;
  final double? currentLat;
  final double? currentLng;
  final double? homeLat;
  final double? homeLng;
  final String? alertReason;

  const UnusualLocationScreen({
    super.key,
    this.detectedLocation,
    this.expectedLocation,
    this.timeDetected,
    this.currentLat,
    this.currentLng,
    this.homeLat,
    this.homeLng,
    this.alertReason,
  });

  @override
  ConsumerState<UnusualLocationScreen> createState() => _UnusualLocationScreenState();
}

class _UnusualLocationScreenState extends ConsumerState<UnusualLocationScreen> {
  late MapController _mapController;
  late double _currentLat;
  late double _currentLng;
  late double _homeLat;
  late double _homeLng;
  late String _detectedLocation;
  late String _expectedLocation;
  late String _timeDetected;
  late String _alertReason;
  bool _isLocatingGps = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Default to Ahmedabad coordinates & preferences
    _homeLat = widget.homeLat ?? LocalPreferences.getHomeLat();
    _homeLng = widget.homeLng ?? LocalPreferences.getHomeLng();
    _expectedLocation = widget.expectedLocation ?? LocalPreferences.getHomeLocationAddress();

    _currentLat = widget.currentLat ?? LocalPreferences.getLastKnownLat();
    _currentLng = widget.currentLng ?? LocalPreferences.getLastKnownLng();
    _detectedLocation = widget.detectedLocation ?? LocalPreferences.getLastKnownLocationAddress();

    // If still set to old Delhi coordinates, migrate immediately to Ahmedabad
    if (_currentLat > 28.0 && _currentLat < 29.0) {
      _currentLat = 23.0525;
      _currentLng = 72.5120;
      _detectedLocation = 'SG Highway, Ahmedabad';
    }
    if (_homeLat > 28.0 && _homeLat < 29.0) {
      _homeLat = 23.0365;
      _homeLng = 72.5611;
      _expectedLocation = 'Navrangpura, Ahmedabad';
    }

    _timeDetected = widget.timeDetected ??
        LocalPreferences.getLastLocationAlertTime() ??
        DateFormat('h:mm a').format(DateTime.now());

    _alertReason = widget.alertReason ?? 'Unusual — not your typical area';

    // Auto-detect live GPS location on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLiveGpsLocation(silent: true);
    });
  }

  /// Queries the device GPS sensor via Geolocator
  Future<void> _fetchLiveGpsLocation({bool silent = false}) async {
    if (_isLocatingGps) return;
    setState(() => _isLocatingGps = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!silent && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable device GPS / Location Service in settings.')),
          );
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!silent && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied.')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!silent && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are permanently denied. Please allow in app settings.')),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      if (mounted) {
        setState(() {
          _currentLat = position.latitude;
          _currentLng = position.longitude;
          _detectedLocation = 'Current GPS: ${position.latitude.toStringAsFixed(4)}° N, ${position.longitude.toStringAsFixed(4)}° E (Ahmedabad)';
          _timeDetected = DateFormat('h:mm a').format(DateTime.now());
        });

        LocalPreferences.setLastKnownLat(position.latitude);
        LocalPreferences.setLastKnownLng(position.longitude);
        LocalPreferences.setLastKnownLocationAddress(_detectedLocation);
        LocalPreferences.setLastLocationAlertTime(_timeDetected);

        _mapController.move(LatLng(position.latitude, position.longitude), 15.0);

        if (!silent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📍 Live GPS Located: ${position.latitude.toStringAsFixed(4)}°, ${position.longitude.toStringAsFixed(4)}°'),
              backgroundColor: AppTheme.primaryTeal,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Live GPS detection error: $e');
    } finally {
      if (mounted) setState(() => _isLocatingGps = false);
    }
  }

  double _computeDistanceKm() {
    return const Distance().as(
      LengthUnit.Kilometer,
      LatLng(_currentLat, _currentLng),
      LatLng(_homeLat, _homeLng),
    );
  }

  void _recenterCurrent() {
    _mapController.move(LatLng(_currentLat, _currentLng), 14.5);
  }

  void _recenterHome() {
    _mapController.move(LatLng(_homeLat, _homeLng), 14.5);
  }

  void _fitBoth() {
    final southWest = LatLng(
      math.min(_currentLat, _homeLat),
      math.min(_currentLng, _homeLng),
    );
    final northEast = LatLng(
      math.max(_currentLat, _homeLat),
      math.max(_currentLng, _homeLng),
    );

    final bounds = LatLngBounds(southWest, northEast);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(48.0),
      ),
    );
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  Future<void> _openExternalNavigation() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$_homeLat,$_homeLng&destination=$_currentLat,$_currentLng&travelmode=driving',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _selectPresetLocation(String name, double lat, double lng) {
    setState(() {
      _detectedLocation = name;
      _currentLat = lat;
      _currentLng = lng;
      _timeDetected = DateFormat('h:mm a').format(DateTime.now());
    });
    LocalPreferences.setLastKnownLocationAddress(name);
    LocalPreferences.setLastKnownLat(lat);
    LocalPreferences.setLastKnownLng(lng);
    LocalPreferences.setLastLocationAlertTime(_timeDetected);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitBoth();
    });
  }

  void _showLocationSwitcherDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('Simulate / Change Location'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Live GPS Detection Button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _fetchLiveGpsLocation(silent: false);
                    },
                    icon: _isLocatingGps
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.my_location, size: 18),
                    label: Text(
                      _isLocatingGps ? 'Detecting Live GPS...' : '📍 Detect My Live GPS (Ahmedabad)',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

                const Divider(),
                Text(
                  'Ahmedabad Locations:',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 6),

                _buildPresetTile('SG Highway, Ahmedabad (Sindhu Bhavan)', 23.0525, 72.5120, ctx),
                _buildPresetTile('Navrangpura / CG Road, Ahmedabad', 23.0365, 72.5611, ctx),
                _buildPresetTile('Vastrapur Lake & Alpha One, Ahmedabad', 23.0350, 72.5293, ctx),
                _buildPresetTile('Sabarmati Riverfront, Ahmedabad', 23.0304, 72.5714, ctx),
                _buildPresetTile('Maninagar & Kankaria Lake, Ahmedabad', 22.9978, 72.6030, ctx),
                _buildPresetTile('SVP International Airport, Ahmedabad', 23.0734, 72.6347, ctx),
                _buildPresetTile('GIFT City / Gandhinagar Financial Hub', 23.1610, 72.6840, ctx),
                _buildPresetTile('Bopal / South Bopal, Ahmedabad', 23.0315, 72.4695, ctx),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPresetTile(String title, double lat, double lng, BuildContext sheetCtx) {
    final isSelected = (_currentLat - lat).abs() < 0.001 && (_currentLng - lng).abs() < 0.001;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6F00) : const Color(0xFFFF6F00).withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.pin_drop,
          color: isSelected ? Colors.white : const Color(0xFFFF6F00),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFFFF6F00), size: 20)
          : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () {
        Navigator.pop(sheetCtx);
        _selectPresetLocation(title, lat, lng);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryGuardian = ref.watch(primaryGuardianProvider);
    final distanceKm = _computeDistanceKm();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Alert Header ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: const BoxDecoration(
                color: Color(0xFFFF6F00),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      ),
                      const Spacer(),
                      Text(
                        context.tr('⚠️ LOCATION ALERT'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.tune, color: Colors.white, size: 20),
                        tooltip: 'Change Test Location',
                        onPressed: () => _showLocationSwitcherDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr('Unusual Location Pattern'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${context.tr('Detected at')} $_timeDetected',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.atkinsonHyperlegible(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            // ── Main Scroll Content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // ── Dynamic Leaflet Map ──
                    Container(
                      height: 230,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFFF6F00).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: LatLng(_currentLat, _currentLng),
                                initialZoom: 13.5,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.all,
                                ),
                              ),
                              children: [
                                // OpenStreetMap Leaflet Tile Layer
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.safesenior.app',
                                ),
                                // Polyline from Home to Current Location
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points: [
                                        LatLng(_homeLat, _homeLng),
                                        LatLng(_currentLat, _currentLng),
                                      ],
                                      strokeWidth: 4.0,
                                      color: const Color(0xFFFF6F00).withValues(alpha: 0.8),
                                      pattern: StrokePattern.dashed(segments: const [10.0, 8.0]),
                                    ),
                                  ],
                                ),
                                // Dynamic Markers Layer
                                MarkerLayer(
                                  markers: [
                                    // 🟢 Home Location Marker (Navrangpura, Ahmedabad)
                                    Marker(
                                      point: LatLng(_homeLat, _homeLng),
                                      width: 80,
                                      height: 65,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryTeal,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.3),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(Icons.home, color: Colors.white, size: 20),
                                          ),
                                          const SizedBox(height: 2),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryTeal,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              context.tr('Home'),
                                              style: GoogleFonts.atkinsonHyperlegible(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // 🟠 Current Location Marker (Pulsing Amber)
                                    Marker(
                                      point: LatLng(_currentLat, _currentLng),
                                      width: 90,
                                      height: 70,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFF6F00),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFFFF6F00).withValues(alpha: 0.5),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(Icons.location_on, color: Colors.white, size: 22),
                                          ),
                                          const SizedBox(height: 2),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFF6F00),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              context.tr('Current'),
                                              style: GoogleFonts.atkinsonHyperlegible(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Top Distance Badge Overlay
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.near_me, size: 14, color: Color(0xFFFF6F00)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${distanceKm.toStringAsFixed(1)} km ${context.tr('Distance from home')}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Map Controls Right Overlay
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Column(
                                children: [
                                  _buildMapIconButton(
                                    Icons.my_location,
                                    'GPS Me',
                                    () => _fetchLiveGpsLocation(silent: false),
                                  ),
                                  const SizedBox(height: 6),
                                  _buildMapIconButton(Icons.crop_free, 'Fit', _fitBoth),
                                  const SizedBox(height: 6),
                                  _buildMapIconButton(Icons.home, 'Home', _recenterHome),
                                  const SizedBox(height: 6),
                                  _buildMapIconButton(Icons.add, 'Zoom In', _zoomIn),
                                  const SizedBox(height: 6),
                                  _buildMapIconButton(Icons.remove, 'Zoom Out', _zoomOut),
                                ],
                              ),
                            ),

                            // Open in Maps App Bottom Overlay Button
                            Positioned(
                              bottom: 8,
                              right: 10,
                              child: GestureDetector(
                                onTap: _openExternalNavigation,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryTeal,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.directions, color: Colors.white, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        context.tr('Open in Maps'),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Dynamic Location Details Card ──
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildLocationRow(
                            Icons.location_on,
                            const Color(0xFFFF6F00),
                            context.tr('Current Location'),
                            _detectedLocation,
                            context.tr(_alertReason),
                            coordText: '${_currentLat.toStringAsFixed(4)}° N, ${_currentLng.toStringAsFixed(4)}° E',
                            onTapEdit: () => _showLocationSwitcherDialog(context),
                          ),
                          const Divider(height: 24),
                          _buildLocationRow(
                            Icons.home_outlined,
                            AppTheme.primaryTeal,
                            context.tr('Your Home Area'),
                            _expectedLocation,
                            context.tr('Your usual location'),
                            coordText: '${_homeLat.toStringAsFixed(4)}° N, ${_homeLng.toStringAsFixed(4)}° E',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Guardian Notification Status & Live Location Share ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6F00).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFF6F00).withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.notifications_active, color: Color(0xFFFF6F00), size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  primaryGuardian != null
                                      ? '${primaryGuardian.name}${primaryGuardian.relationship != null ? ' (${primaryGuardian.relationship})' : ''} is linked for location safety updates.'
                                      : 'No primary guardian linked yet. Share your location with family below.',
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFFF6F00),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final box = context.findRenderObject() as RenderBox?;
                                final origin = box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;
                                final osmLink =
                                    'https://www.openstreetmap.org/?mlat=$_currentLat&mlon=$_currentLng#map=16/$_currentLat/$_currentLng';
                                final gMapsLink =
                                    'https://www.google.com/maps/search/?api=1&query=$_currentLat,$_currentLng';

                                final locMsg =
                                    '📍 ${context.tr('SafeSenior Location Notice')}:\n'
                                    'I am currently at $_detectedLocation (Expected: $_expectedLocation at $_timeDetected).\n'
                                    'Distance: ${distanceKm.toStringAsFixed(1)} km.\n\n'
                                    '🗺️ OpenStreetMap: $osmLink\n'
                                    '📍 Google Maps: $gMapsLink\n\n'
                                    'Sent safely from SafeSenior Protection App.';

                                await SharePlus.instance.share(
                                  ShareParams(
                                    text: locMsg,
                                    subject: 'SafeSenior Location Update',
                                    sharePositionOrigin: origin,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.share, size: 16, color: Color(0xFFFF6F00)),
                              label: Text(
                                context.tr('Share Current Location with Family'),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFF6F00),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: const Color(0xFFFF6F00).withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── What Should You Do Advice Section ──
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('What should you do?'),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildAdvice(context.tr("If you went out intentionally, you're safe. Just confirm below.")),
                          const SizedBox(height: 8),
                          _buildAdvice(context.tr("If you're confused or feel unsafe, call a guardian immediately.")),
                          const SizedBox(height: 8),
                          _buildAdvice(context.tr('If someone forced you to go somewhere, press the SOS button.')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Dynamic Bottom Action Buttons ──
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '✅ Safety Confirmed: Safe departure acknowledged.',
                              style: GoogleFonts.atkinsonHyperlegible(color: Colors.white),
                            ),
                            backgroundColor: AppTheme.primaryTeal,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        elevation: 0,
                      ),
                      child: Text(
                        context.tr("I'm Safe — Went Out Intentionally"),
                        style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            if (primaryGuardian != null && primaryGuardian.phone.isNotEmpty) {
                              final cleanPhone = primaryGuardian.phone.replaceAll(RegExp(r'[^\d+]'), '');
                              final callUri = Uri.parse('tel:$cleanPhone');
                              if (await canLaunchUrl(callUri)) {
                                await launchUrl(callUri);
                                return;
                              }
                            }
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const GuardianContactsScreen()),
                              );
                            }
                          },
                          icon: const Icon(Icons.call, size: 18),
                          label: Text(
                            primaryGuardian != null ? 'Call ${primaryGuardian.name.split(' ').first}' : context.tr('Call Guardian'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primaryTeal),
                            foregroundColor: AppTheme.primaryTeal,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                            );
                          },
                          icon: const Icon(Icons.sos, size: 18),
                          label: Text(context.tr('SOS')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.dangerRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapIconButton(IconData icon, String tooltip, VoidCallback onTap) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 16, color: AppTheme.textPrimary),
        padding: EdgeInsets.zero,
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }

  Widget _buildLocationRow(
    IconData icon,
    Color color,
    String label,
    String location,
    String note, {
    String? coordText,
    VoidCallback? onTapEdit,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.atkinsonHyperlegible(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (onTapEdit != null)
                    GestureDetector(
                      onTap: onTapEdit,
                      child: Text(
                        'Change',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                location,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                note,
                style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, color: color),
              ),
              if (coordText != null) ...[
                const SizedBox(height: 2),
                Text(
                  coordText,
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvice(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.arrow_right, color: AppTheme.primaryTeal, size: 20),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.atkinsonHyperlegible(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
