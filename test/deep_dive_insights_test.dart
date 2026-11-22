import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finimo/models/deep_dive_models.dart';
import 'package:finimo/models/family_member.dart';
import 'package:finimo/screens/deep_dive_screen.dart';
import 'package:finimo/services/family_repository.dart';
import 'package:finimo/services/home_repository.dart';
import 'package:finimo/services/insight_repository.dart';

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

class _TestInsightRepo implements InsightRepository {
  DeepDiveSummaryData responseData;
  int? lastRequestedMonth;
  int? lastRequestedYear;
  String? lastRequestedMemberId;

  _TestInsightRepo({required this.responseData});

  @override
  Future<DeepDiveSummaryData> getInsightsSummary({
    int? month,
    int? year,
    String? memberId,
  }) async {
    lastRequestedMonth = month;
    lastRequestedYear = year;
    lastRequestedMemberId = memberId;
    return responseData;
  }
}

void main() {
  group('DeepDive Insights OpenAPI Model Tests', () {
    test('DeepDiveSummaryData.fromApiResponse correctly parses OpenAPI response', () {
      final json = {
        'period': {
          'month': 11,
          'year': 2026,
          'timezone': 'Asia/Kolkata',
        },
        'consolidated_liquidity': '18500.00',
        'total_monthly_income': '50000.00',
        'total_monthly_expense': '5500.00',
        'daily_safe_to_spend': '450.00',
        'budget_health_score_pct': 88,
        'category_breakdown': [
          {
            'category_id': 'c1',
            'category_name': 'Dining',
            'amount': '2000.00',
            'percentage': 36.36,
          },
          {
            'category_id': 'c2',
            'category_name': 'Garments',
            'amount': '1000.00',
            'percentage': 18.18,
          },
        ],
        'event_summaries': [
          {
            'event_id': 'e1',
            'title': 'Durga Puja',
            'total_spent': '3000.00',
            'budget_cap': '15000.00',
          }
        ],
        'member_breakdown': [
          {
            'member_id': 'm1',
            'name': 'Priya Mehta',
            'total_paid': '4500.00',
            'total_benefited': '2000.00',
          },
          {
            'member_id': 'm2',
            'name': 'Arjun Mehta',
            'total_paid': '1000.00',
            'total_benefited': '3500.00',
          },
        ],
      };

      final data = DeepDiveSummaryData.fromApiResponse(json);

      expect(data.month, equals(11));
      expect(data.year, equals(2026));
      expect(data.timezone, equals('Asia/Kolkata'));
      expect(data.totalOutflow, equals(5500.0));
      expect(data.totalIncome, equals(50000.0));
      expect(data.consolidatedLiquidity, equals(18500.0));
      expect(data.dailySafeToSpend, equals(450.0));
      expect(data.budgetHealthScorePct, equals(88));

      expect(data.categories.length, equals(2));
      expect(data.categories[0].categoryName, equals('Dining'));
      expect(data.categories[0].amount, equals(2000.0));
      expect(data.categories[0].percentage, closeTo(36.36, 0.01));

      expect(data.members.length, equals(2));
      expect(data.members[0].name, equals('Priya Mehta'));
      expect(data.members[0].totalPaid, equals(4500.0));
      expect(data.members[0].totalBenefited, equals(2000.0));
      expect(data.members[0].percentageOfTotal, closeTo(81.81, 0.1));

      expect(data.eventSummaries.length, equals(1));
      expect(data.eventSummaries[0].title, equals('Durga Puja'));
      expect(data.eventSummaries[0].totalSpent, equals(3000.0));
      expect(data.eventSummaries[0].budgetCap, equals(15000.0));
    });

    test('DeepDiveSummaryData.fromApiResponse handles empty data safely', () {
      final json = {
        'period': {'month': 11, 'year': 2026, 'timezone': 'UTC'},
        'consolidated_liquidity': '0.00',
        'total_monthly_income': '0.00',
        'total_monthly_expense': '0.00',
        'daily_safe_to_spend': null,
        'budget_health_score_pct': null,
        'category_breakdown': [],
        'event_summaries': [],
        'member_breakdown': [],
      };

      final data = DeepDiveSummaryData.fromApiResponse(json);
      expect(data.totalOutflow, equals(0.0));
      expect(data.categories, isEmpty);
      expect(data.members, isEmpty);
      expect(data.eventSummaries, isEmpty);
      expect(data.budgetHealthScorePct, isNull);
    });
  });

  group('DeepDiveScreen Widget Tests', () {
    testWidgets('Renders header, month pill, donut chart hero, and category breakdown',
        (tester) async {
      final testData = DeepDiveSummaryData(
        month: 11,
        year: 2026,
        timezone: 'Asia/Kolkata',
        totalOutflow: 5500.0,
        totalIncome: 50000.0,
        consolidatedLiquidity: 18500.0,
        dailySafeToSpend: 450.0,
        budgetHealthScorePct: 88,
        categories: [
          const InsightCategoryBurn(
            categoryId: 'c1',
            categoryName: 'Dining',
            amount: 2000.0,
            percentage: 36.36,
            color: Color(0xFFF59E0B),
            icon: Icons.restaurant_outlined,
          ),
          const InsightCategoryBurn(
            categoryId: 'c2',
            categoryName: 'Garments',
            amount: 1000.0,
            percentage: 18.18,
            color: Color(0xFF8B5CF6),
            icon: Icons.checkroom_outlined,
          ),
        ],
        members: [
          const InsightMemberBurn(
            memberId: 'm1',
            name: 'Priya Mehta',
            initial: 'P',
            totalPaid: 4500.0,
            totalBenefited: 2000.0,
            percentageOfTotal: 81.8,
            accentColor: Color(0xFFC3F400),
          ),
        ],
      );

      final insightRepo = _TestInsightRepo(responseData: testData);
      final familyRepo = _TestFamilyRepo();

      await tester.pumpWidget(
        MaterialApp(
          home: DeepDiveScreen(
            repository: _FakeHomeRepo(),
            insightRepository: insightRepo,
            familyRepository: familyRepo,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check Header & Month
      expect(find.text('INSIGHTS'), findsOneWidget);
      expect(find.text('MONTHLY ANALYTICS'), findsOneWidget);
      expect(find.text('All Family Pool'), findsOneWidget);

      // Check Category View (Default)
      expect(find.text('Category View'), findsOneWidget);
      expect(find.text('TOTAL EXPENSES'), findsOneWidget);
      expect(find.text('₹5,500'), findsOneWidget);
      expect(find.text('Health: 88%'), findsOneWidget);

      // Check categories
      expect(find.text('Dining'), findsOneWidget);
      expect(find.text('Garments'), findsOneWidget);
      expect(find.text('₹2,000'), findsOneWidget);
      expect(find.text('₹1,000'), findsOneWidget);
    });

    testWidgets('Toggles to Family Member View and displays member breakdown',
        (tester) async {
      final testData = DeepDiveSummaryData(
        month: 11,
        year: 2026,
        timezone: 'Asia/Kolkata',
        totalOutflow: 5500.0,
        totalIncome: 50000.0,
        consolidatedLiquidity: 18500.0,
        dailySafeToSpend: 450.0,
        budgetHealthScorePct: 88,
        categories: [],
        members: [
          const InsightMemberBurn(
            memberId: 'm1',
            name: 'Priya Mehta',
            initial: 'P',
            totalPaid: 4500.0,
            totalBenefited: 2000.0,
            percentageOfTotal: 82.0,
            accentColor: Color(0xFFC3F400),
          ),
          const InsightMemberBurn(
            memberId: 'm2',
            name: 'Arjun Mehta',
            initial: 'A',
            totalPaid: 1000.0,
            totalBenefited: 3500.0,
            percentageOfTotal: 18.0,
            accentColor: Color(0xFFE9B3FF),
          ),
        ],
      );

      final insightRepo = _TestInsightRepo(responseData: testData);
      final familyRepo = _TestFamilyRepo();

      await tester.pumpWidget(
        MaterialApp(
          home: DeepDiveScreen(
            repository: _FakeHomeRepo(),
            insightRepository: insightRepo,
            familyRepository: familyRepo,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Family Member View toggle
      await tester.tap(find.text('Family Member View'));
      await tester.pumpAndSettle();

      // Check Family Spend Attribution Card
      expect(find.text('FAMILY SPEND SHARE'), findsOneWidget);
      expect(find.text('Spend by Family Member'), findsOneWidget);

      // Check Member burn cards
      expect(find.text('Priya Mehta'), findsWidgets);
      expect(find.text('Arjun Mehta'), findsWidgets);
      expect(find.text('Paid: ₹4,500'), findsOneWidget);
      expect(find.text('Benefited: ₹2,000'), findsOneWidget);
      expect(find.text('Paid: ₹1,000'), findsOneWidget);
      expect(find.text('Benefited: ₹3,500'), findsOneWidget);
    });

    testWidgets('Renders empty states gracefully when zero categories exist',
        (tester) async {
      final emptyData = DeepDiveSummaryData(
        month: 11,
        year: 2026,
        timezone: 'Asia/Kolkata',
        totalOutflow: 0.0,
        totalIncome: 0.0,
        consolidatedLiquidity: 0.0,
        dailySafeToSpend: null,
        budgetHealthScorePct: null,
        categories: [],
        members: [],
      );

      final insightRepo = _TestInsightRepo(responseData: emptyData);

      await tester.pumpWidget(
        MaterialApp(
          home: DeepDiveScreen(
            repository: _FakeHomeRepo(),
            insightRepository: insightRepo,
            familyRepository: _TestFamilyRepo(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Category Expenses'), findsOneWidget);
      expect(find.text('Zero Outflow'), findsOneWidget);
    });
  });
}
