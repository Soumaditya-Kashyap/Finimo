import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finimo/models/conjoined_event_detail.dart';
import 'package:finimo/models/home_dashboard_data.dart';
import 'package:finimo/models/monthly_limit_item.dart';
import 'package:finimo/models/sinking_fund_goal.dart';
import 'package:finimo/models/targets_dashboard_data.dart';
import 'package:finimo/screens/conjoined_event_detail_screen.dart';
import 'package:finimo/screens/targets_screen.dart';
import 'package:finimo/services/category_repository.dart';
import 'package:finimo/services/dashboard_repository.dart';
import 'package:finimo/services/event_repository.dart';
import 'package:finimo/services/home_repository.dart';
import 'package:finimo/services/target_repository.dart';
import 'package:finimo/services/transaction_repository.dart';

class _FakeHomeRepo extends MockHomeRepository {}

class _TestDashboardRepo extends MockDashboardRepository {
  @override
  Future<HomeDashboardData> getDashboardMetrics({
    int? month,
    int? year,
    String? memberId,
  }) async {
    return const HomeDashboardData(
      consolidatedLiquidity: 200000,
      jointAccountsCount: 2,
      monthlyInflow: 30000,
      monthlySpent: 450,
      dailySafeBurn: 985,
      livePingSeconds: '01S',
    );
  }
}

void main() {
  group('Step 5 Models Tests - Targets & Events', () {
    test('MonthlyLimitItem.fromApiResponse maps target properly', () {
      final json = {
        'id': 'target_1',
        'target_name': 'Groceries & Household',
        'limit_amount': '15000.00',
        'time_frame': 'MONTHLY',
        'notify_threshold_pct': 80,
        'current_period_spent': '450.00',
        'percentage_consumed': 3.0,
        'category': {
          'id': 'cat_household',
          'name': 'Household',
          'icon_key': 'home',
          'color_hex': '#C3F400',
        },
      };

      final item = MonthlyLimitItem.fromApiResponse(json);

      expect(item.id, equals('target_1'));
      expect(item.title, equals('Groceries & Household'));
      expect(item.limitCap, equals(15000.0));
      expect(item.currentSpent, equals(450.0));
      expect(item.percentageUsed, equals(3.0));
      expect(item.isWarning, isFalse);
      expect(item.statusText, contains('buffer'));
    });

    test('SinkingFundGoal.fromApiResponse maps event properly', () {
      final json = {
        'id': 'ev_pujo_2026',
        'title': 'Durga Puja 2026',
        'budget_cap': '10000.00',
        'total_spent': '8672.00',
        'remaining_budget': '1328.00',
        'percentage_used': 86.72,
        'status': 'ACTIVE',
        'contributing_members_count': 3,
      };

      final goal = SinkingFundGoal.fromApiResponse(json);

      expect(goal.id, equals('ev_pujo_2026'));
      expect(goal.title, equals('Durga Puja 2026'));
      expect(goal.targetGoal, equals(10000.0));
      expect(goal.currentAmount, equals(8672.0));
      expect(goal.percentage, equals(86.72));
      expect(goal.neededText, contains('needed'));
      expect(goal.paceStatus, equals('Pacing high'));
    });

    test('ConjoinedEventDetail.fromEventItemsResponse computes splits dynamically', () {
      final json = {
        'event': {
          'id': 'ev_pujo_2026',
          'title': 'Durga Puja 2026',
          'budget_cap': '10000.00',
          'total_spent': '6000.00',
          'remaining_budget': '4000.00',
          'percentage_used': 60.0,
          'status': 'ACTIVE',
        },
        'items': [
          {
            'id': 'rec_1',
            'title': 'Ethnic Garments',
            'amount': '4000.00',
            'type': 'EXPENSE',
            'category': {'name': 'Garments'},
            'paid_by': {'id': 'mem_priya', 'name': 'Priya Mehta'},
            'transaction_date': DateTime.now().toUtc().toIso8601String(),
          },
          {
            'id': 'rec_2',
            'title': 'Bhog Rituals',
            'amount': '2000.00',
            'type': 'EXPENSE',
            'category': {'name': 'Rituals'},
            'paid_by': {'id': 'mem_arjun', 'name': 'Arjun Mehta'},
            'transaction_date': DateTime.now().toUtc().toIso8601String(),
          },
        ],
      };

      final detail = ConjoinedEventDetail.fromEventItemsResponse(json);

      expect(detail.id, equals('ev_pujo_2026'));
      expect(detail.eventTitle, equals('Durga Puja 2026'));
      expect(detail.totalSunkVolume, equals(6000.0));
      expect(detail.budgetCap, equals(10000.0));
      expect(detail.memberSplits.length, equals(2));

      // Priya spent 4000/6000 = 66.67%
      final priyaSplit = detail.memberSplits.firstWhere((s) => s.name == 'Priya Mehta');
      expect(priyaSplit.amount, equals(4000.0));
      expect(priyaSplit.ratioPercentage, closeTo(66.66, 0.1));

      // Arjun spent 2000/6000 = 33.33%
      final arjunSplit = detail.memberSplits.firstWhere((s) => s.name == 'Arjun Mehta');
      expect(arjunSplit.amount, equals(2000.0));
      expect(arjunSplit.ratioPercentage, closeTo(33.33, 0.1));

      expect(detail.ledgerRecords.length, equals(2));
      expect(detail.ledgerRecords[0].title, equals('Ethnic Garments'));
    });

    test('TargetsDashboardData.compute calculates concentric gauge metrics accurately', () {
      final limits = [
        const MonthlyLimitItem(
          id: 'master_1',
          title: 'Total Monthly Cap',
          limitCap: 30000,
          currentSpent: 7000,
          percentageUsed: 23.3,
          statusText: 'Buffer',
          footerStatus: 'Good',
          accentColor: Colors.white,
          icon: Icons.roofing_outlined,
          // categoryId is null => Master Budget
        ),
        const MonthlyLimitItem(
          id: '1',
          title: 'Dining',
          limitCap: 10000,
          currentSpent: 2000,
          percentageUsed: 20,
          statusText: 'Buffer',
          footerStatus: 'Good',
          accentColor: Colors.white,
          icon: Icons.restaurant,
          categoryId: 'cat_dining',
        ),
        const MonthlyLimitItem(
          id: '2',
          title: 'Groceries',
          limitCap: 20000,
          currentSpent: 5000,
          percentageUsed: 25,
          statusText: 'Buffer',
          footerStatus: 'Good',
          accentColor: Colors.white,
          icon: Icons.shopping_basket,
          categoryId: 'cat_groceries',
        ),
      ];

      final data = TargetsDashboardData.compute(
        limits: limits,
        regularMonthlySpent: 7000,
      );

      expect(data.hasMasterBudget, isTrue);
      expect(data.safeCapAmount, equals(30000.0));
      expect(data.budgetRemainingAmount, equals(23000.0));
      expect(data.budgetRemainingPct, closeTo(76.66, 0.1));
      expect(data.allocatedCategoryAmount, equals(30000.0));
      expect(data.unallocatedBuffer, equals(0.0));
      expect(data.runwayProgress, closeTo(0.233, 0.01));
    });
  });

  group('TargetsScreen Widget Tests', () {
    late _FakeHomeRepo homeRepo;
    late MockTargetRepository targetRepo;
    late MockEventRepository eventRepo;
    late MockCategoryRepository categoryRepo;
    late _TestDashboardRepo dashboardRepo;
    late MockTransactionRepository txRepo;

    setUp(() {
      homeRepo = _FakeHomeRepo();
      targetRepo = MockTargetRepository(initialTargets: [
        {
          'id': 'target_master',
          'target_name': 'Total Family Monthly Budget',
          'limit_amount': '30000.00',
          'current_period_spent': '450.00',
          'percentage_consumed': 1.5,
          'notify_threshold_pct': 80,
          'is_active': true,
          'category_id': null,
        },
        {
          'id': 'target_1',
          'target_name': 'Groceries & Household',
          'limit_amount': '15000.00',
          'current_period_spent': '450.00',
          'percentage_consumed': 3.0,
          'notify_threshold_pct': 80,
          'is_active': true,
          'category_id': 'cat_household',
          'category': {
            'id': 'cat_household',
            'name': 'Household',
            'icon_key': 'home',
            'color_hex': '#C3F400',
          },
        },
      ]);
      eventRepo = MockEventRepository(initialEvents: [
        {
          'id': 'ev_pujo',
          'title': 'Durga Puja 2026',
          'budget_cap': '10000.00',
          'total_spent': '8672.00',
          'remaining_budget': '1328.00',
          'percentage_used': 86.72,
          'status': 'ACTIVE',
          'contributing_members_count': 3,
        },
      ]);
      categoryRepo = MockCategoryRepository();
      dashboardRepo = _TestDashboardRepo();
      txRepo = MockTransactionRepository(customTransactions: [
        {
          'id': 'tx_reg_1',
          'title': 'Monthly Groceries',
          'amount': '450.00',
          'type': 'EXPENSE',
          'category_id': 'cat_household',
          'event_id': null,
        },
      ]);
    });

    testWidgets('TargetsScreen renders live limits, master budget, and events', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: TargetsScreen(
            repository: homeRepo,
            targetRepository: targetRepo,
            eventRepository: eventRepo,
            categoryRepository: categoryRepo,
            dashboardRepository: dashboardRepo,
            transactionRepository: txRepo,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Targets & Budgets'), findsOneWidget);
      expect(find.text('Category Allocations'), findsOneWidget);
      expect(find.text('Groceries & Household'), findsOneWidget);
      expect(find.text('Total Family Monthly Budget'), findsOneWidget);
      expect(find.text('Savings Goals & Events'), findsOneWidget);
      expect(find.text('DURGA PUJA 2026'), findsOneWidget);
    });

    testWidgets('TargetsScreen displays empty state when no targets or events exist',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final emptyTargetRepo = MockTargetRepository(initialTargets: []);
      final emptyEventRepo = MockEventRepository(initialEvents: []);
      final emptyTxRepo = MockTransactionRepository(customTransactions: []);

      await tester.pumpWidget(
        MaterialApp(
          home: TargetsScreen(
            repository: homeRepo,
            targetRepository: emptyTargetRepo,
            eventRepository: emptyEventRepo,
            categoryRepository: categoryRepo,
            dashboardRepository: dashboardRepo,
            transactionRepository: emptyTxRepo,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.widgetWithText(ElevatedButton, 'Set Master Monthly Budget'), findsOneWidget);
      expect(find.text('Category limits locked'), findsOneWidget);
      expect(find.text('No active sinking pools'), findsOneWidget);
      expect(find.text('New Sinking Pool'), findsOneWidget);
    });

    testWidgets('TargetsScreen opens Master Budget sheet when tapping Set Master Monthly Budget', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final emptyTargetRepo = MockTargetRepository(initialTargets: []);
      final emptyEventRepo = MockEventRepository(initialEvents: []);
      final emptyTxRepo = MockTransactionRepository(customTransactions: []);

      await tester.pumpWidget(
        MaterialApp(
          home: TargetsScreen(
            repository: homeRepo,
            targetRepository: emptyTargetRepo,
            eventRepository: emptyEventRepo,
            categoryRepository: categoryRepo,
            dashboardRepository: dashboardRepo,
            transactionRepository: emptyTxRepo,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Set Master Monthly Budget button
      final setMasterBtn = find.widgetWithText(ElevatedButton, 'Set Master Monthly Budget');
      expect(setMasterBtn, findsOneWidget);
      await tester.tap(setMasterBtn);
      await tester.pumpAndSettle();

      expect(find.textContaining('Step 1: Set your Family Master Monthly Budget'), findsOneWidget);
    });

    testWidgets('Event transactions do NOT deplete Master Budget or Category Limits', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Create a master target of 30,000 and Groceries category target of 15,000
      final tRepo = MockTargetRepository(initialTargets: [
        {
          'id': 'master_target',
          'target_name': 'Total Family Monthly Budget',
          'limit_amount': '30000.00',
          'current_period_spent': '0.00',
          'percentage_consumed': 0.0,
          'notify_threshold_pct': 80,
          'is_active': true,
          'category_id': null,
        },
        {
          'id': 'cat_target',
          'target_name': 'Groceries',
          'limit_amount': '15000.00',
          'current_period_spent': '0.00',
          'percentage_consumed': 0.0,
          'notify_threshold_pct': 80,
          'is_active': true,
          'category_id': 'cat_groceries',
        },
      ]);

      // A large transaction of 6,000 for Durga Puja event (event_id is set)
      final isolatedTxRepo = MockTransactionRepository(customTransactions: [
        {
          'id': 'tx_event_1',
          'title': 'Garments for Puja',
          'amount': '6000.00',
          'type': 'EXPENSE',
          'category_id': 'cat_groceries',
          'event_id': 'ev_pujo', // Non-null event ID: ISOLATED!
        },
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: TargetsScreen(
            repository: homeRepo,
            targetRepository: tRepo,
            eventRepository: eventRepo,
            categoryRepository: categoryRepo,
            dashboardRepository: dashboardRepo,
            transactionRepository: isolatedTxRepo,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Master budget should remain at 100% / ₹30,000 left because event expense is isolated!
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('₹30,000 left'), findsOneWidget);
    });
  });

  group('ConjoinedEventDetailScreen Widget Tests', () {
    late _FakeHomeRepo homeRepo;
    late MockEventRepository eventRepo;

    setUp(() {
      homeRepo = _FakeHomeRepo();
      eventRepo = MockEventRepository(
        initialEvents: [
          {
            'id': 'ev_pujo',
            'title': 'Durga Puja 2026',
            'budget_cap': '10000.00',
            'total_spent': '6000.00',
            'remaining_budget': '4000.00',
            'percentage_used': 60.0,
            'status': 'ACTIVE',
            'contributing_members_count': 2,
          },
        ],
        initialReceipts: {
          'ev_pujo': [
            {
              'id': 'rec_1',
              'title': 'Ethnic Garments',
              'amount': '4000.00',
              'type': 'EXPENSE',
              'category': {'name': 'Garments'},
              'paid_by': {'id': 'mem_priya', 'name': 'Priya Mehta'},
              'transaction_date': DateTime.now().toUtc().toIso8601String(),
            },
          ],
        },
      );
    });

    testWidgets('ConjoinedEventDetailScreen renders event volume and ledger records',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: ConjoinedEventDetailScreen(
            repository: homeRepo,
            eventRepository: eventRepo,
            eventId: 'ev_pujo',
            eventTitle: 'Durga Puja 2026',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Durga Puja 2026'), findsWidgets);
      expect(find.text('Add Expense to Event'), findsOneWidget);
      expect(find.text('Ethnic Garments'), findsOneWidget);
      expect(find.text('Priya Mehta'), findsWidgets);
    });

    testWidgets('ConjoinedEventDetailScreen deletes event pool on confirmation',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: ConjoinedEventDetailScreen(
            repository: homeRepo,
            eventRepository: eventRepo,
            eventId: 'ev_pujo',
            eventTitle: 'Durga Puja 2026',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap 3-dots popup menu
      final popupMenu = find.byType(PopupMenuButton<String>);
      expect(popupMenu, findsOneWidget);
      await tester.tap(popupMenu);
      await tester.pumpAndSettle();

      // Tap Delete Event
      final deleteItem = find.text('Delete Event');
      expect(deleteItem, findsOneWidget);
      await tester.tap(deleteItem);
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Delete Event Pool?'), findsOneWidget);
      final confirmBtn = find.text('Delete Pool');
      expect(confirmBtn, findsOneWidget);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Event should be removed from mock repo
      final remaining = await eventRepo.getEvents();
      expect(remaining.where((e) => e['id'] == 'ev_pujo'), isEmpty);
    });
  });
}
