import 'package:flutter_test/flutter_test.dart';
import 'package:finimo/main.dart';

void main() {
  testWidgets('FinimoApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FinimoApp());
    expect(find.text('FINIMO'), findsOneWidget);
  });
}
