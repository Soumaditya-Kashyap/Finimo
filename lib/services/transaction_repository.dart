import '../models/ledger_transaction.dart';
import '../models/transaction_item.dart';
export 'http_transaction_repository.dart';

abstract class TransactionRepository {
  Future<List<TransactionItem>> getRecentTransactions({
    int limit = 5,
    String? memberId,
    String? type,
  });

  Future<Map<String, dynamic>> getTransactionsCursor({
    int limit = 50,
    String? cursor,
    int? month,
    int? year,
    String? memberId,
    String? type,
    String? categoryId,
    String? eventId,
  });

  Future<List<LedgerTransaction>> getLedgerTransactions({
    int limit = 50,
    String? cursor,
    int? month,
    int? year,
    String? memberId,
    String? type,
    String? categoryId,
    String? eventId,
  });

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
  });

  Future<void> deleteTransaction(String transactionId);
}

class MockTransactionRepository implements TransactionRepository {
  @override
  Future<List<TransactionItem>> getRecentTransactions({
    int limit = 5,
    String? memberId,
    String? type,
  }) async {
    return const [
      TransactionItem(
        id: 'tx_1',
        title: 'FabIndia Garments',
        subtitle: '08 Oct · ETHNIC WEAR',
        amount: 4025.00,
        type: TransactionType.expense,
        attributionName: 'Chandrani',
        attributionTagColor: 'purple',
        iconKey: 'shopping_bag',
      ),
      TransactionItem(
        id: 'tx_2',
        title: 'Bhog & Puja Items',
        subtitle: '07 Oct · RITUALS',
        amount: 2299.00,
        type: TransactionType.expense,
        attributionName: 'Arpa',
        attributionTagColor: 'lime',
        iconKey: 'shopping_bag',
      ),
      TransactionItem(
        id: 'tx_3',
        title: 'Restaurant Dinners',
        subtitle: '06 Oct · DINING',
        amount: 1608.00,
        type: TransactionType.expense,
        attributionName: 'All Members',
        attributionTagColor: 'cyan',
        iconKey: 'shopping_bag',
      ),
      TransactionItem(
        id: 'tx_4',
        title: 'Discount Adjustment',
        subtitle: '06 Oct · CASHBACK',
        amount: 50.00,
        type: TransactionType.income,
        attributionName: 'Store Cashback',
        attributionTagColor: 'lime',
        iconKey: 'receipt',
      ),
    ];
  }

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
    final list = await getRecentTransactions(limit: limit);
    return {
      'items': list.map((e) => e.toJson()).toList(),
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
    return const [];
  }

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
    return {'id': 'tx_mock_${DateTime.now().millisecondsSinceEpoch}'};
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {}
}
