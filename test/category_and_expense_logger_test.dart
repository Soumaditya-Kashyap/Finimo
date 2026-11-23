import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:finimo/core/api_client.dart';
import 'package:finimo/core/token_storage.dart';
import 'package:finimo/models/conjoined_event_summary.dart';
import 'package:finimo/models/family_member.dart';
import 'package:finimo/models/transaction_category.dart';
import 'package:finimo/models/transaction_item.dart';
import 'package:finimo/services/category_repository.dart';
import 'package:finimo/services/dashboard_repository.dart';
import 'package:finimo/services/event_repository.dart';
import 'package:finimo/services/family_repository.dart';
import 'package:finimo/services/home_repository.dart';
import 'package:finimo/services/transaction_repository.dart';
import 'package:finimo/widgets/beneficiary_chip_selector.dart';
import 'package:finimo/widgets/paid_by_payer_selector.dart';
import 'package:finimo/models/ledger_transaction.dart';
import 'package:finimo/screens/add_expense_income_screen.dart';

class _FakeHomeRepo extends MockHomeRepository {}

class _RecordingTransactionRepo implements TransactionRepository {
  Map<String, dynamic>? lastCreated;

  @override
  Future<Map<String, dynamic>> createTransaction({
    required String type,
    required double amount,
    required String title,
    required String categoryId,
    required String paidByMemberId,
    String? beneficiaryMemberId,
    String? eventId,
    required DateTime transactionDate,
    required String paymentMode,
    String? notes,
  }) async {
    lastCreated = {
      'type': type,
      'amount': amount,
      'title': title,
      'category_id': categoryId,
      'paid_by_member_id': paidByMemberId,
      'beneficiary_member_id': beneficiaryMemberId,
      'event_id': eventId,
      'payment_mode': paymentMode,
      'notes': notes,
    };
    return {'id': 'tx_recorded_123'};
  }

  @override
  Future<List<TransactionItem>> getRecentTransactions({
    int limit = 5,
    String? memberId,
    String? type,
  }) async =>
      [];

  @override
  Future<Map<String, dynamic>> getTransactionsCursor({
    int limit = 50,
    String? cursor,
    int? month,
    int? year,
    String? memberId,
    String? type,
    String? categoryId,
    String? eventId,
  }) async =>
      {'items': [], 'next_cursor': null};

  @override
  Future<List<LedgerTransaction>> getLedgerTransactions({
    int limit = 50,
    String? cursor,
    int? month,
    int? year,
    String? memberId,
    String? type,
    String? categoryId,
    String? eventId,
  }) async =>
      [];

  @override
  Future<void> deleteTransaction(String transactionId) async {}
}

class _StubDashboardRepo extends MockDashboardRepository {
  @override
  Future<ConjoinedEventSummary?> getActiveConjoinedEvent() async => null;
}

class _StubEventRepo extends MockEventRepository {
  final List<Map<String, dynamic>> eventsList;
  _StubEventRepo(this.eventsList);

  @override
  Future<List<Map<String, dynamic>>> getEvents({String? status}) async =>
      eventsList;
}

class _StubFamilyRepo extends MockFamilyRepository {
  final List<FamilyMember> membersList;
  _StubFamilyRepo(this.membersList);

  @override
  Future<List<FamilyMember>> getFamilyMembers() async => membersList;
}

class _StubCategoryRepo implements CategoryRepository {
  final List<TransactionCategory> categories;
  _StubCategoryRepo(this.categories);

  @override
  Future<List<TransactionCategory>> getCategories({
    String? type,
    bool forceRefresh = false,
  }) async {
    if (type != null && type.isNotEmpty) {
      return categories
          .where((c) => c.type.toUpperCase() == type.toUpperCase())
          .toList();
    }
    return categories;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  group('Category and Transaction Category Model Tests', () {
    test('TransactionCategory.fromJson parses fields and icons properly', () {
      final json = {
        'id': 'cat_groceries_uuid',
        'name': 'Groceries',
        'type': 'EXPENSE',
        'icon_key': 'shopping-cart',
        'color_hex': '#10B981',
        'is_system': true,
      };

      final cat = TransactionCategory.fromJson(json);
      expect(cat.id, 'cat_groceries_uuid');
      expect(cat.name, 'Groceries');
      expect(cat.type, 'EXPENSE');
      expect(cat.icon, Icons.shopping_cart_outlined);
      expect(cat.iconColor, const Color(0xFF10B981));
    });

    test('TransactionCategory parses income categories correctly', () {
      final json = {
        'id': 'cat_salary_uuid',
        'name': 'Salary',
        'type': 'INCOME',
        'icon_key': 'briefcase',
        'color_hex': '#22C55E',
      };

      final cat = TransactionCategory.fromJson(json);
      expect(cat.id, 'cat_salary_uuid');
      expect(cat.name, 'Salary');
      expect(cat.type, 'INCOME');
      expect(cat.icon, Icons.work_outline);
      expect(cat.iconColor, const Color(0xFF22C55E));
    });
  });

  group('HttpCategoryRepository Tests', () {
    test('HttpCategoryRepository fetches and filters by type', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final tokenStorage = TokenStorage();
      await tokenStorage.saveTokens(
        accessToken: 'mock_jwt_token',
        refreshToken: 'mock_refresh_token',
      );

      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/api/v1/categories')) {
          final queryType = request.url.queryParameters['type'];
          final all = [
            {
              'id': 'c1',
              'name': 'Groceries',
              'type': 'EXPENSE',
              'icon_key': 'shopping-cart',
              'color_hex': '#10B981',
            },
            {
              'id': 'c2',
              'name': 'Salary',
              'type': 'INCOME',
              'icon_key': 'briefcase',
              'color_hex': '#22C55E',
            },
          ];

          if (queryType != null) {
            final filtered =
                all.where((e) => e['type'] == queryType).toList();
            return http.Response(jsonEncode(filtered), 200,
                headers: {'content-type': 'application/json'});
          }
          return http.Response(jsonEncode(all), 200,
              headers: {'content-type': 'application/json'});
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(
        tokenStorage: tokenStorage,
        httpClient: mockClient,
      );
      final repo = HttpCategoryRepository(apiClient: apiClient);

      final expenses = await repo.getCategories(type: 'EXPENSE');
      expect(expenses.length, 1);
      expect(expenses.first.name, 'Groceries');

      final incomes = await repo.getCategories(type: 'INCOME', forceRefresh: true);
      expect(incomes.length, 1);
      expect(incomes.first.name, 'Salary');
    });
  });

  group('Payer and Beneficiary Selector Widget Tests', () {
    final testMembers = [
      const FamilyMember(
        id: 'member_uuid_arjun',
        name: 'Arjun Mehta',
        initial: 'A',
        relationType: MemberRelation.admin,
      ),
      const FamilyMember(
        id: 'member_uuid_priya',
        name: 'Priya Mehta',
        initial: 'P',
        relationType: MemberRelation.spouse,
      ),
    ];

    testWidgets('PaidByPayerSelector dynamically renders members',
        (tester) async {
      String selected = 'member_uuid_arjun';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaidByPayerSelector(
              members: testMembers,
              selectedMemberId: selected,
              onSelected: (id) => selected = id,
            ),
          ),
        ),
      );

      expect(find.text('Arjun Mehta'), findsOneWidget);
      expect(find.text('Priya Mehta'), findsOneWidget);

      await tester.tap(find.text('Priya Mehta'));
      expect(selected, 'member_uuid_priya');
    });

    testWidgets('BeneficiaryChipSelector dynamically renders Entire Family + members',
        (tester) async {
      String? selectedId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BeneficiaryChipSelector(
              members: testMembers,
              selectedBeneficiaryMemberId: selectedId,
              onSelected: (id) => selectedId = id,
            ),
          ),
        ),
      );

      expect(find.text('Entire Family'), findsOneWidget);
      expect(find.text('Arjun Mehta'), findsOneWidget);
      expect(find.text('Priya Mehta'), findsOneWidget);

      await tester.tap(find.text('Priya Mehta'));
      expect(selectedId, 'member_uuid_priya');

      await tester.tap(find.text('Entire Family'));
      expect(selectedId, isNull);
    });
  });

  group('AddExpenseIncomeScreen Integration Tests', () {
    final testMembers = [
      const FamilyMember(
        id: '256191c9-768a-4424-9dfc-572719c8f858',
        name: 'Arjun',
        initial: 'A',
        relationType: MemberRelation.admin,
      ),
      const FamilyMember(
        id: '1e1941e7-88df-4152-9bca-c7320b925b67',
        name: 'Priya',
        initial: 'P',
        relationType: MemberRelation.spouse,
      ),
    ];

    final testCategories = [
      const TransactionCategory(
        id: 'cat_groceries_uuid',
        name: 'Groceries',
        type: 'EXPENSE',
        icon: Icons.shopping_cart_outlined,
        iconColor: Color(0xFF10B981),
      ),
      const TransactionCategory(
        id: 'cat_salary_uuid',
        name: 'Salary',
        type: 'INCOME',
        icon: Icons.work_outline,
        iconColor: Color(0xFF22C55E),
      ),
    ];

    testWidgets('AddExpenseIncomeScreen records expense transaction cleanly',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final transactionRepo = _RecordingTransactionRepo();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddExpenseIncomeScreen(
              repository: _FakeHomeRepo(),
              familyRepository: _StubFamilyRepo(testMembers),
              categoryRepository: _StubCategoryRepo(testCategories),
              dashboardRepository: _StubDashboardRepo(),
              transactionRepository: transactionRepo,
              initialType: TransactionType.expense,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify category 'Groceries' is present
      expect(find.text('Groceries'), findsOneWidget);

      // Verify Expense contextual labels
      expect(find.text('Paid By'), findsOneWidget);
      expect(find.text('Spent For (Whom?)'), findsOneWidget);

      // Verify event tagging card is REMOVED from normal expense add
      expect(find.text('ISOLATED POOL'), findsNothing);

      // Enter amount '250' via native TextField
      await tester.enterText(find.byType(TextField).first, '250');
      await tester.pump();

      // Tap 'Record Expense' button
      await tester.tap(find.text('Record Expense'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify transaction repository received correct payload
      expect(transactionRepo.lastCreated, isNotNull);
      expect(transactionRepo.lastCreated!['type'], 'EXPENSE');
      expect(transactionRepo.lastCreated!['amount'], 250.0);
      expect(transactionRepo.lastCreated!['title'], 'Groceries');
      expect(transactionRepo.lastCreated!['category_id'], 'cat_groceries_uuid');
      expect(transactionRepo.lastCreated!['paid_by_member_id'],
          '256191c9-768a-4424-9dfc-572719c8f858');
      expect(transactionRepo.lastCreated!['beneficiary_member_id'], isNull);
    });

    testWidgets('AddExpenseIncomeScreen toggles Income type and records salary',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final transactionRepo = _RecordingTransactionRepo();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddExpenseIncomeScreen(
              repository: _FakeHomeRepo(),
              familyRepository: _StubFamilyRepo(testMembers),
              categoryRepository: _StubCategoryRepo(testCategories),
              dashboardRepository: _StubDashboardRepo(),
              transactionRepository: transactionRepo,
              initialType: TransactionType.expense,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to Income tab
      await tester.tap(find.text('Income'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Category list should now show 'Salary'
      expect(find.text('Salary'), findsOneWidget);

      // Verify Income contextual labels
      expect(find.text('Income By'), findsOneWidget);
      expect(find.text('Income For (Whom?)'), findsOneWidget);
      expect(find.text('Paid By'), findsNothing);
      expect(find.text('Spent For (Whom?)'), findsNothing);

      // Enter 50000 via native TextField
      await tester.enterText(find.byType(TextField).first, '50000');
      await tester.pump();

      // Tap 'Record Income' button
      await tester.tap(find.text('Record Income'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(transactionRepo.lastCreated, isNotNull);
      expect(transactionRepo.lastCreated!['type'], 'INCOME');
      expect(transactionRepo.lastCreated!['amount'], 50000.0);
      expect(transactionRepo.lastCreated!['title'], 'Salary');
      expect(transactionRepo.lastCreated!['category_id'], 'cat_salary_uuid');
    });

    testWidgets('AddExpenseIncomeScreen opens in event-only mode and tags event correctly',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final transactionRepo = _RecordingTransactionRepo();
      final eventRepo = _StubEventRepo([
        {
          'id': 'b437f198-508b-4b2a-8924-a28d5462cf42',
          'title': 'Durga Puja',
          'budget_cap': 15000.0,
          'total_spent': 3000.0,
          'remaining_budget': 12000.0,
          'percentage_used': 20.0,
          'status': 'ACTIVE',
        },
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddExpenseIncomeScreen(
              repository: _FakeHomeRepo(),
              familyRepository: _StubFamilyRepo(testMembers),
              categoryRepository: _StubCategoryRepo(testCategories),
              dashboardRepository: _StubDashboardRepo(),
              transactionRepository: transactionRepo,
              eventRepository: eventRepo,
              isEventExpenseOnly: true,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Header should say 'Add Event Expense'
      expect(find.text('Add Event Expense'), findsOneWidget);

      // Income toggle should NOT exist
      expect(find.text('Income'), findsNothing);

      // Mandatory event tag card should be visible
      expect(find.text('Event Pool (Required)'), findsOneWidget);
      expect(find.text('ISOLATED POOL'), findsOneWidget);
      expect(find.text('Durga Puja'), findsOneWidget);

      // Enter amount 2000 via native TextField
      await tester.enterText(find.byType(TextField).first, '2000');
      await tester.pump();

      // Tap 'Record Event Expense'
      await tester.tap(find.text('Record Event Expense'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(transactionRepo.lastCreated, isNotNull);
      expect(transactionRepo.lastCreated!['type'], 'EXPENSE');
      expect(transactionRepo.lastCreated!['amount'], 2000.0);
      expect(transactionRepo.lastCreated!['event_id'],
          'b437f198-508b-4b2a-8924-a28d5462cf42');
    });
  });
}
