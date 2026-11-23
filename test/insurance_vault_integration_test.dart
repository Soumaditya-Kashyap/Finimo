import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finimo/models/family_member.dart';
import 'package:finimo/models/insurance_policy_model.dart';
import 'package:finimo/screens/insurance_vault_screen.dart';
import 'package:finimo/services/family_repository.dart';
import 'package:finimo/services/home_repository.dart';
import 'package:finimo/services/insurance_repository.dart';

class _FakeHomeRepo extends MockHomeRepository {}

class _TestFamilyRepo extends MockFamilyRepository {
  @override
  Future<List<FamilyMember>> getFamilyMembers() async {
    return const [
      FamilyMember(
        id: 'm1',
        name: 'Arjun Mehta',
        initial: 'A',
        relationType: MemberRelation.admin,
      ),
      FamilyMember(
        id: 'm2',
        name: 'Priya Mehta',
        initial: 'P',
        relationType: MemberRelation.spouse,
      ),
    ];
  }
}

class _TestInsuranceRepo implements InsuranceRepository {
  InsuranceVaultOverview overview;
  bool deleteCalled = false;
  String? lastDeletedId;
  CreateInsuranceRequest? lastCreatedRequest;

  _TestInsuranceRepo({required this.overview});

  @override
  Future<InsuranceVaultOverview> getInsuranceOverview() async {
    return overview;
  }

  @override
  Future<InsurancePolicyModel> createPolicy(
      CreateInsuranceRequest request) async {
    lastCreatedRequest = request;
    final newPol = InsurancePolicyModel(
      id: 'pol_new_1',
      familyId: 'fam_1',
      insuredMemberId: request.insuredMemberId,
      insuredMemberName: 'Arjun Mehta',
      policyName: request.policyName,
      policyType: InsurancePolicyModel.parseType(request.policyType),
      policyNumber: request.policyNumber,
      sumAssured: request.sumAssured,
      premiumAmount: request.premiumAmount,
      premiumFrequency: request.premiumFrequency,
      renewalDueDate: DateTime.parse(request.renewalDueDate),
      status: InsurancePolicyModel.parseStatus(request.status),
    );
    return newPol;
  }

  @override
  Future<void> deletePolicy(String policyId) async {
    deleteCalled = true;
    lastDeletedId = policyId;
  }

  @override
  Future<InsurancePolicyModel> updatePolicy(
      String policyId, Map<String, dynamic> patch) async {
    throw UnimplementedError();
  }
}

void main() {
  group('Insurance Policy OpenAPI Model Tests', () {
    test('InsurancePolicyModel.fromApiResponse correctly parses OpenAPI response', () {
      final json = {
        'id': 'pol_1',
        'family_id': 'fam_1',
        'insured_member_id': 'm1',
        'policy_name': 'HDFC Ergo Optima Secure',
        'policy_type': 'HEALTH',
        'policy_number': 'POL-99238',
        'sum_assured': '2500000.00',
        'premium_amount': '24000.00',
        'premium_frequency': 'ANNUAL',
        'renewal_due_date': '2027-05-15',
        'status': 'ACTIVE',
        'created_at': '2026-11-20T10:00:00Z',
        'updated_at': '2026-11-20T10:00:00Z',
      };

      final policy = InsurancePolicyModel.fromApiResponse(json, memberName: 'Arjun Mehta');

      expect(policy.id, equals('pol_1'));
      expect(policy.insuredMemberName, equals('Arjun Mehta'));
      expect(policy.policyName, equals('HDFC Ergo Optima Secure'));
      expect(policy.policyType, equals(PolicyType.health));
      expect(policy.sumAssured, equals(2500000.0));
      expect(policy.premiumAmount, equals(24000.0));
      expect(policy.premiumFrequency, equals('ANNUAL'));
      expect(policy.status, equals(PolicyStatus.active));
      expect(InsurancePolicyModel.formatSumAssured(policy.sumAssured), equals('₹25 L'));
    });

    test('InsuranceVaultOverview.fromApiResponse correctly parses nested members response', () {
      final json = {
        'total_sum_assured_umbrella': '12500000.00',
        'members': [
          {
            'member_id': 'm1',
            'member_name': 'Arjun Mehta',
            'total_sum_assured': '10000000.00',
            'policies': [
              {
                'id': 'pol_term_1',
                'family_id': 'fam_1',
                'insured_member_id': 'm1',
                'policy_name': 'HDFC Click 2 Protect',
                'policy_type': 'TERM_LIFE',
                'policy_number': 'POL-TERM-12',
                'sum_assured': '10000000.00',
                'premium_amount': '18000.00',
                'premium_frequency': 'ANNUAL',
                'renewal_due_date': '2027-11-18',
                'status': 'ACTIVE',
              }
            ]
          },
          {
            'member_id': 'm2',
            'member_name': 'Priya Mehta',
            'total_sum_assured': '2500000.00',
            'policies': [
              {
                'id': 'pol_health_1',
                'family_id': 'fam_1',
                'insured_member_id': 'm2',
                'policy_name': 'Care Supreme Floater',
                'policy_type': 'HEALTH',
                'policy_number': 'CARE-4412',
                'sum_assured': '2500000.00',
                'premium_amount': '1500.00',
                'premium_frequency': 'MONTHLY',
                'renewal_due_date': '2026-12-15',
                'status': 'ACTIVE',
              }
            ]
          }
        ]
      };

      final overview = InsuranceVaultOverview.fromApiResponse(json);

      expect(overview.totalSumAssuredUmbrella, equals(12500000.0));
      expect(overview.formattedUmbrellaText, equals('₹1.25 Cr'));
      expect(overview.coveredFamilyMembersCount, equals(2));
      expect(overview.policies.length, equals(2));

      // Annual cost = 18000 (annual) + 1500 * 12 (monthly) = 36000
      expect(overview.annualCostTotal, equals(36000.0));
      expect(overview.monthlyCostEquivalent, equals(3000.0));
      expect(overview.nextCycleText, equals("Dec '26"));
    });
  });

  group('InsuranceVaultScreen Widget Tests', () {
    testWidgets('Renders umbrella hero card, dynamic filters, and policy cards',
        (tester) async {
      final testOverview = InsuranceVaultOverview(
        totalSumAssuredUmbrella: 12500000.0,
        formattedUmbrellaText: '₹1.25 Cr',
        coveredFamilyMembersCount: 2,
        annualCostTotal: 36000.0,
        monthlyCostEquivalent: 3000.0,
        nextCycleText: "Dec '26",
        nextCycleStatus: 'Active Pacing',
        policies: [
          InsurancePolicyModel(
            id: 'pol_1',
            familyId: 'fam_1',
            insuredMemberId: 'm1',
            insuredMemberName: 'Arjun Mehta',
            policyName: 'HDFC Click 2 Protect',
            policyType: PolicyType.termLife,
            policyNumber: 'POL-TERM-12',
            sumAssured: 10000000.0,
            premiumAmount: 18000.0,
            premiumFrequency: 'ANNUAL',
            renewalDueDate: DateTime(2027, 11, 18),
            status: PolicyStatus.active,
          ),
          InsurancePolicyModel(
            id: 'pol_2',
            familyId: 'fam_1',
            insuredMemberId: 'm2',
            insuredMemberName: 'Priya Mehta',
            policyName: 'Care Supreme Floater',
            policyType: PolicyType.health,
            policyNumber: 'CARE-4412',
            sumAssured: 2500000.0,
            premiumAmount: 18000.0,
            premiumFrequency: 'ANNUAL',
            renewalDueDate: DateTime(2026, 12, 15),
            status: PolicyStatus.active,
          ),
        ],
      );

      final insuranceRepo = _TestInsuranceRepo(overview: testOverview);
      final familyRepo = _TestFamilyRepo();

      await tester.pumpWidget(
        MaterialApp(
          home: InsuranceVaultScreen(
            repository: _FakeHomeRepo(),
            insuranceRepository: insuranceRepo,
            familyRepository: familyRepo,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check Header & Hero Card
      expect(find.text('INSURANCE'), findsOneWidget);
      expect(find.text('TOTAL FAMILY COVER'), findsOneWidget);
      expect(find.text('₹1.25'), findsOneWidget);
      expect(find.text('Cr'), findsOneWidget);
      expect(find.text('2 Family Members Covered'), findsOneWidget);

      // Check Policies count
      expect(find.text('Registered Policies'), findsOneWidget);
      expect(find.text('2 POLICIES'), findsOneWidget);

      // Check policy card titles
      expect(find.text('HDFC Click 2 Protect'), findsOneWidget);
      expect(find.text('Care Supreme Floater'), findsOneWidget);

      // Filter to Health only
      await tester.tap(find.text('Health (1)'));
      await tester.pumpAndSettle();

      expect(find.text('Care Supreme Floater'), findsOneWidget);
      expect(find.text('HDFC Click 2 Protect'), findsNothing);
    });

    testWidgets('Renders empty state cleanly when zero policies exist',
        (tester) async {
      final emptyOverview = const InsuranceVaultOverview(
        totalSumAssuredUmbrella: 0.0,
        formattedUmbrellaText: '₹0',
        coveredFamilyMembersCount: 0,
        annualCostTotal: 0.0,
        monthlyCostEquivalent: 0.0,
        nextCycleText: 'None',
        nextCycleStatus: 'All Active',
        policies: [],
      );

      final insuranceRepo = _TestInsuranceRepo(overview: emptyOverview);

      await tester.pumpWidget(
        MaterialApp(
          home: InsuranceVaultScreen(
            repository: _FakeHomeRepo(),
            insuranceRepository: insuranceRepo,
            familyRepository: _TestFamilyRepo(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Insurance Policies Registered'), findsOneWidget);
      expect(find.text('Add First Policy'), findsOneWidget);
    });

    testWidgets('Opens Add Policy sheet when tapping Add Policy button',
        (tester) async {
      final emptyOverview = const InsuranceVaultOverview(
        totalSumAssuredUmbrella: 0.0,
        formattedUmbrellaText: '₹0',
        coveredFamilyMembersCount: 0,
        annualCostTotal: 0.0,
        monthlyCostEquivalent: 0.0,
        nextCycleText: 'None',
        nextCycleStatus: 'All Active',
        policies: [],
      );

      final insuranceRepo = _TestInsuranceRepo(overview: emptyOverview);

      await tester.pumpWidget(
        MaterialApp(
          home: InsuranceVaultScreen(
            repository: _FakeHomeRepo(),
            insuranceRepository: insuranceRepo,
            familyRepository: _TestFamilyRepo(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap + Add Policy button
      await tester.tap(find.text('Add Policy'));
      await tester.pumpAndSettle();

      expect(find.text('REGISTER POLICY'), findsOneWidget);
      expect(find.text('Add Family Insurance'), findsOneWidget);
      expect(find.text('Save & Register Policy'), findsOneWidget);
    });
  });
}
