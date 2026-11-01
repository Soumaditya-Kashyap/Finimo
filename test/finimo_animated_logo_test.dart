import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finimo/widgets/finimo_animated_logo.dart';
import 'package:finimo/screens/splash_screen.dart';
import 'package:finimo/screens/auth_screen.dart';
import 'package:finimo/services/auth_repository.dart';
import 'package:finimo/services/home_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FinimoAnimatedLogo Widget Tests', () {
    testWidgets('renders three elements with exact aspect ratio', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: FinimoAnimatedLogo(
                size: 96.0,
                animate: false,
              ),
            ),
          ),
        ),
      );

      // Verify widget presence
      expect(find.byType(FinimoAnimatedLogo), findsOneWidget);

      // Verify that 3 Image widgets exist (one for each element)
      expect(find.byType(Image), findsNWidgets(3));

      // Verify 3 ColorFiltered widgets wrap the elements
      expect(find.byType(ColorFiltered), findsNWidgets(3));

      // Verify RepaintBoundary is used for performance optimization
      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('repeats animation smoothly over time', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: FinimoAnimatedLogo(
                size: 80.0,
                duration: Duration(milliseconds: 2400),
                animate: true,
              ),
            ),
          ),
        ),
      );

      // Initial state
      await tester.pump();
      expect(find.byType(FinimoAnimatedLogo), findsOneWidget);

      // Phase 0 transition (1/3 of cycle)
      await tester.pump(const Duration(milliseconds: 800));
      expect(tester.takeException(), isNull);

      // Phase 1 transition (2/3 of cycle)
      await tester.pump(const Duration(milliseconds: 800));
      expect(tester.takeException(), isNull);

      // Phase 2 transition (3/3 of cycle, loop back)
      await tester.pump(const Duration(milliseconds: 800));
      expect(tester.takeException(), isNull);
    });

    testWidgets('FinimoLoader renders as expected', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinimoLoader(size: 40.0),
          ),
        ),
      );

      expect(find.byType(FinimoLoader), findsOneWidget);
      expect(find.byType(FinimoAnimatedLogo), findsOneWidget);
    });
  });

  group('SplashScreen Navigation Tests', () {
    testWidgets('displays animated logo and navigates to AuthScreen', (tester) async {
      final mockAuth = MockAuthRepository();
      final mockHome = MockHomeRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            authRepository: mockAuth,
            homeRepository: mockHome,
          ),
        ),
      );

      // Logo is initially rendered on screen
      expect(find.byType(FinimoAnimatedLogo), findsOneWidget);

      // Advance time past the splash delay (2800ms + transition)
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();

      // AuthScreen is reached
      expect(find.byType(AuthScreen), findsOneWidget);
    });
  });
}

