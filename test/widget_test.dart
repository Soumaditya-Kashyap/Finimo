import 'package:flutter_test/flutter_test.dart';
import 'package:finimo/main.dart';
import 'package:finimo/screens/auth_screen.dart';
import 'package:finimo/widgets/finimo_animated_logo.dart';

void main() {
  testWidgets('FinimoApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FinimoApp());
    expect(find.byType(FinimoAnimatedLogo), findsOneWidget);

    // Pump past the splash delay to AuthScreen
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pumpAndSettle();
    expect(find.byType(AuthScreen), findsOneWidget);
  });
}
