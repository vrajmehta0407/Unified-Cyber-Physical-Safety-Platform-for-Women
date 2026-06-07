import 'package:flutter_test/flutter_test.dart';
import 'package:cybershield/app.dart';

void main() {
  testWidgets('CyberShield app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CyberShieldApp());
    await tester.pump();
    expect(find.byType(CyberShieldApp), findsOneWidget);
  });
}
