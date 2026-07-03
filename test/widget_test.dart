import 'package:flutter_test/flutter_test.dart';
import 'package:safe_senior/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SafeSeniorApp());
    expect(find.text('Safe Senior'), findsWidgets);
  });
}
