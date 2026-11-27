import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finimo/models/family_member.dart';
import 'package:finimo/widgets/family_orbit_selector.dart';

void main() {
  group('FamilyOrbitSelector Widget Tests', () {
    final singleMember = [
      const FamilyMember(
        id: 'user-ram-1',
        name: 'ram',
        initial: 'R',
        relationType: MemberRelation.self,
      ),
    ];

    final multiMembers = [
      const FamilyMember(
        id: 'user-ram-1',
        name: 'Ram',
        initial: 'R',
        relationType: MemberRelation.self,
      ),
      const FamilyMember(
        id: 'user-priya-2',
        name: 'Priya',
        initial: 'P',
        relationType: MemberRelation.spouse,
      ),
      const FamilyMember(
        id: 'user-arav-3',
        name: 'Arav',
        initial: 'A',
        relationType: MemberRelation.child,
      ),
    ];

    testWidgets('Renders real single member initial when Family (All) is selected',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FamilyOrbitSelector(
              members: singleMember,
              selectedLabel: 'Family (All)',
              selectedMemberId: null,
            ),
          ),
        ),
      );

      // Verify Operating Orbit & Family Vault
      expect(find.text('OPERATING ORBIT'), findsOneWidget);
      expect(find.text('Family Vault'), findsOneWidget);
      expect(find.text('Family (All)'), findsOneWidget);

      // Verify real single member initial 'R' is rendered and NOT hardcoded 'A', 'C'
      expect(find.text('R'), findsOneWidget);
      expect(find.text('C'), findsNothing);
    });

    testWidgets('Renders multiple real member initials when multiple members exist',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FamilyOrbitSelector(
              members: multiMembers,
              selectedLabel: 'Family (All)',
              selectedMemberId: null,
            ),
          ),
        ),
      );

      expect(find.text('Family Vault'), findsOneWidget);
      expect(find.text('R'), findsOneWidget);
      expect(find.text('P'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('C'), findsNothing);
    });

    testWidgets('Switches to personal user profile orbit when specific member is selected',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FamilyOrbitSelector(
              members: multiMembers,
              selectedLabel: 'Ram',
              selectedMemberId: 'user-ram-1',
            ),
          ),
        ),
      );

      // Title switches to member's personal vault
      expect(find.text("Ram's Vault"), findsOneWidget);
      expect(find.text('Family Vault'), findsNothing);

      // Pill displays selected member name and their single avatar badge
      expect(find.text('Ram'), findsOneWidget);
      expect(find.text('R'), findsOneWidget);
      expect(find.text('P'), findsNothing);
      expect(find.text('A'), findsNothing);
    });
  });
}
