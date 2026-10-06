import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  test('mobile_scanner smoke test', () {
    final controller = MobileScannerController(
      autoStart: false,
    );
    expect(controller, isNotNull);
  });
}
