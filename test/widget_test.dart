import 'package:flutter_test/flutter_test.dart';
import 'package:finimo/main.dart';
import 'package:finimo/screens/auth_screen.dart';
import 'package:finimo/services/auth_repository.dart';
import 'package:finimo/widgets/finimo_animated_logo.dart';

void main() {
  testWidgets('FinimoApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(FinimoApp(authRepository: MockAuthRepository()));
    expect(find.byType(FinimoAnimatedLogo), findsOneWidget);

    // Pump past the splash delay (700ms + 2100ms + 400ms transition = 3200ms)
    await tester.pump(const Duration(milliseconds: 3500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(AuthScreen), findsOneWidget);
  });
}
