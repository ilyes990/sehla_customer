import 'package:flutter_test/flutter_test.dart';
import 'package:sehla_customer/main.dart';

void main() {
  testWidgets('SehlaApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SehlaApp());
    expect(find.byType(SehlaApp), findsOneWidget);
  });
}
