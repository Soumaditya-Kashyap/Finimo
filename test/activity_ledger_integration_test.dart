import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finimo/models/family_member.dart';
import 'package:finimo/models/ledger_transaction.dart';
import 'package:finimo/models/transaction_item.dart';
import 'package:finimo/screens/activity_screen.dart';
import 'package:finimo/services/family_repository.dart';
import 'package:finimo/services/home_repository.dart';
import 'package:finimo/services/transaction_repository.dart';

class _FakeHomeRepo extends MockHomeRepository {}

class _MockFamilyRepo extends MockFamilyRepository {
  @override
  Future<List<FamilyMember>> getFamilyMembers() async {
    return const [
      FamilyMember(
        id: 'mem_arjun',
        name: 'Arjun Mehta',
        initial: 'A',
        relationType: MemberRelation.admin,
      ),
      FamilyMember(
        id: 'mem_priya',
        name: 'Priya Mehta',
        initial: 'P',
        relationType: MemberRelation.spouse,
      ),
    ];
  }
}

class _TestTransactionRepo implements TransactionRepository {
  List<Map<String, dynamic>> items;
  String? lastDeletedId;
  Map<String, dynamic>? lastQueryParams;

  _TestTransactionRepo({required this.items});

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
  }) async {
    lastQueryParams = {
      'limit': limit,
      'cursor': cursor,
      'month': month,
      'year': year,
      'member_id': memberId,
      'type': type,
      'category_id': categoryId,
      'event_id': eventId,
    };

    var filtered = List<Map<String, dynamic>>.from(items);
    if (type != null) {
      filtered = filtered
          .where((i) =>
              (i['type'] as String).toUpperCase() == type.toUpperCase())
          .toList();
    }
    if (memberId != null) {
      filtered = filtered
          .where((i) =>
              (i['paid_by'] != null && i['paid_by']['id'] == memberId) ||
              (i['beneficiary'] != null && i['beneficiary']['id'] == memberId))
          .toList();
    }

    return {
      'items': filtered,
      'next_cursor': null,
    };
  }

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
  }) async {
    final data = await getTransactionsCursor(
      limit: limit,
      cursor: cursor,
      month: month,
      year: year,
      memberId: memberId,
      type: type,
      categoryId: categoryId,
      eventId: eventId,
    );
    final list = data['items'] as List;
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => LedgerTransaction.fromApiResponse(e))
        .toList();
  }

  @override
  Future<List<TransactionItem>> getRecentTransactions({
    int limit = 5,
    String? memberId,
    String? type,
  }) async =>
      [];

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
  }) async =>
      {'id': 'tx_new'};

  @override
  Future<void> deleteTransaction(String transactionId) async {
    lastDeletedId = transactionId;
    items.removeWhere((i) => i['id'] == transactionId);
  }
}

void main() {
  group('LedgerTransaction Model Tests', () {
    test('LedgerTransaction.fromApiResponse correctly parses Expense', () {
      final json = {
        'id': 'tx_exp_1',
        'type': 'EXPENSE',
        'amount': '450.00',
        'title': 'School Books',
        'category': {
          'id': 'cat_edu',
          'name': 'Education',
          'icon_key': 'education',
          'color_hex': '#63F7FF',
        },
        'paid_by': {
          'id': 'mem_arjun',
          'name': 'Arjun Mehta',
          'relation_type': 'PRIMARY',
        },
        'beneficiary': {
          'id': 'mem_aryahi',
          'name': 'Aryahi Mehta',
          'relation_type': 'CHILD',
        },
        'transaction_date': DateTime.now().toUtc().toIso8601String(),
        'payment_mode': 'UPI',
        'notes': 'Grade 5 notebooks',
      };

      final tx = LedgerTransaction.fromApiResponse(json);

      expect(tx.id, equals('tx_exp_1'));
      expect(tx.title, equals('School Books'));
      expect(tx.amount, equals(450.0));
      expect(tx.isExpense, isTrue);
      expect(tx.categoryName, equals('Education'));
      expect(tx.payerName, equals('Arjun Mehta'));
      expect(tx.beneficiaryName, equals('Aryahi Mehta'));
      expect(tx.isMultiBeneficiary, isFalse);
      expect(tx.dateSection, equals('Today'));
      expect(tx.notes, equals('Grade 5 notebooks'));
    });

    test('LedgerTransaction.fromApiResponse correctly parses Income', () {
      final json = {
        'id': 'tx_inc_1',
        'type': 'INCOME',
        'amount': '28000.00',
        'title': 'November Salary',
        'category': {
          'id': 'cat_sal',
          'name': 'Salary',
          'icon_key': 'salary',
          'color_hex': '#C3F400',
        },
        'paid_by': {
          'id': 'mem_arjun',
          'name': 'Arjun Mehta',
          'relation_type': 'PRIMARY',
        },
        'beneficiary': null,
        'transaction_date': DateTime.now().toUtc().toIso8601String(),
        'payment_mode': 'BANK',
      };

      final tx = LedgerTransaction.fromApiResponse(json);

      expect(tx.id, equals('tx_inc_1'));
      expect(tx.title, equals('November Salary'));
      expect(tx.amount, equals(28000.0));
      expect(tx.isExpense, isFalse);
      expect(tx.beneficiaryName, equals('Entire Family'));
      expect(tx.isMultiBeneficiary, isTrue);
      expect(tx.badgeText, equals('Primary Inflow'));
    });
  });

  group('ActivityScreen Integration & Dynamic Ledger Tests', () {
    late _TestTransactionRepo testRepo;
    late _MockFamilyRepo familyRepo;
    late _FakeHomeRepo homeRepo;

    setUp(() {
      homeRepo = _FakeHomeRepo();
      familyRepo = _MockFamilyRepo();
      testRepo = _TestTransactionRepo(items: [
        {
          'id': 'tx_1',
          'type': 'EXPENSE',
          'amount': '450.00',
          'title': 'School Books',
          'category': {
            'id': 'cat_edu',
            'name': 'Education',
            'icon_key': 'education',
          },
          'paid_by': {'id': 'mem_arjun', 'name': 'Arjun Mehta'},
          'beneficiary': {'id': 'mem_priya', 'name': 'Priya Mehta'},
          'transaction_date': DateTime.now().toUtc().toIso8601String(),
          'payment_mode': 'UPI',
        },
        {
          'id': 'tx_2',
          'type': 'INCOME',
          'amount': '28000.00',
          'title': 'Salary Credit',
          'category': {
            'id': 'cat_sal',
            'name': 'Salary',
            'icon_key': 'salary',
          },
          'paid_by': {'id': 'mem_arjun', 'name': 'Arjun Mehta'},
          'beneficiary': null,
          'transaction_date': DateTime.now().toUtc().toIso8601String(),
          'payment_mode': 'BANK',
        },
      ]);
    });

    testWidgets('ActivityScreen loads dynamic transactions and displays telemetry',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: ActivityScreen(
            repository: homeRepo,
            transactionRepository: testRepo,
            familyRepository: familyRepo,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check transaction items render
      expect(find.text('School Books'), findsOneWidget);
      expect(find.text('Salary Credit'), findsOneWidget);

      // Check telemetry displays computed values
      expect(find.text('Expenses'), findsNWidgets(2));
      expect(find.text('Income'), findsNWidgets(2));
      expect(find.text('+₹28,000'), findsOneWidget);
      expect(find.text('₹450'), findsOneWidget);
    });

    testWidgets('ActivityScreen switches filter to Expenses and Income',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: ActivityScreen(
            repository: homeRepo,
            transactionRepository: testRepo,
            familyRepository: familyRepo,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Expenses filter chip
      await tester.tap(find.text('Expenses').first);
      await tester.pumpAndSettle();

      // Only Expense remains
      expect(find.text('School Books'), findsOneWidget);
      expect(find.text('Salary Credit'), findsNothing);

      // Tap Income filter chip
      await tester.tap(find.text('Income').first);
      await tester.pumpAndSettle();

      // Only Income remains
      expect(find.text('Salary Credit'), findsOneWidget);
      expect(find.text('School Books'), findsNothing);
    });

    testWidgets('ActivityScreen search filters transactions in real-time',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: ActivityScreen(
            repository: homeRepo,
            transactionRepository: testRepo,
            familyRepository: familyRepo,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap search icon button
      final searchIcon = find.byIcon(Icons.search_rounded);
      expect(searchIcon, findsOneWidget);
      await tester.tap(searchIcon);
      await tester.pumpAndSettle();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'School');
      await tester.pumpAndSettle();

      // Only matching item is shown
      expect(find.text('School Books'), findsOneWidget);
      expect(find.text('Salary Credit'), findsNothing);
    });

    testWidgets('ActivityScreen deletes transaction with confirmation',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: ActivityScreen(
            repository: homeRepo,
            transactionRepository: testRepo,
            familyRepository: familyRepo,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Long press first transaction card to trigger delete confirmation
      await tester.longPress(find.text('School Books'));
      await tester.pumpAndSettle();

      // Confirmation dialog should be visible
      expect(find.text('Delete Transaction'), findsOneWidget);
      expect(find.text('Are you sure you want to delete "School Books" of ₹450? This will permanently remove it from the ledger.'),
          findsOneWidget);

      // Tap Delete in dialog
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify transaction deleted in repo and removed from screen
      expect(testRepo.lastDeletedId, equals('tx_1'));
      expect(find.text('School Books'), findsNothing);
      expect(find.text('Salary Credit'), findsOneWidget);
    });

    testWidgets('ActivityScreen displays empty state when no transactions exist',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final emptyRepo = _TestTransactionRepo(items: []);

      await tester.pumpWidget(
        MaterialApp(
          home: ActivityScreen(
            repository: homeRepo,
            transactionRepository: emptyRepo,
            familyRepository: familyRepo,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Transactions Found'), findsOneWidget);
      expect(find.text('Log a Transaction'), findsOneWidget);
    });
  });
}
