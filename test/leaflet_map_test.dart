import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  test('flutter_map and latlong2 smoke test', () {
    final current = LatLng(28.6315, 77.2167);
    final home = LatLng(28.5284, 77.2065);
    final distanceKm = const Distance().as(LengthUnit.Kilometer, current, home);
    expect(distanceKm, greaterThan(5));
    
    final options = MapOptions(
      initialCenter: current,
      initialZoom: 13.0,
    );
    expect(options.initialCenter.latitude, equals(28.6315));
  });
}
