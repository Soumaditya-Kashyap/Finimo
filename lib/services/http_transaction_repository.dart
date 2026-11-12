import '../core/api_client.dart';
import '../core/api_config.dart';
import '../models/ledger_transaction.dart';
import '../models/transaction_item.dart';
import 'transaction_repository.dart';

class HttpTransactionRepository implements TransactionRepository {
  final ApiClient apiClient;

  HttpTransactionRepository({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  @override
  Future<List<TransactionItem>> getRecentTransactions({
    int limit = 5,
    String? memberId,
    String? type,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit};
    if (memberId != null && memberId.isNotEmpty) {
      queryParams['member_id'] = memberId;
    }
    if (type != null && type.isNotEmpty) {
      queryParams['type'] = type.toUpperCase();
    }

    try {
      final response = await apiClient.get(
        ApiConfig.transactions,
        queryParameters: queryParams,
        requiresAuth: true,
      );

      if (response is Map<String, dynamic> && response['items'] is List) {
        final items = response['items'] as List;
        return items
            .whereType<Map<String, dynamic>>()
            .map((e) => TransactionItem.fromApiResponse(e))
            .toList();
      }
    } catch (_) {
      // In case of network errors or empty response
      return [];
    }
    return [];
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
    final queryParams = <String, dynamic>{'limit': limit};
    if (cursor != null && cursor.isNotEmpty) queryParams['cursor'] = cursor;
    if (month != null) queryParams['month'] = month;
    if (year != null) queryParams['year'] = year;
    if (memberId != null && memberId.isNotEmpty) {
      queryParams['member_id'] = memberId;
    }
    if (type != null && type.isNotEmpty) {
      queryParams['type'] = type.toUpperCase();
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['category_id'] = categoryId;
    }
    if (eventId != null && eventId.isNotEmpty) {
      queryParams['event_id'] = eventId;
    }

    final response = await apiClient.get(
      ApiConfig.transactions,
      queryParameters: queryParams,
      requiresAuth: true,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }
    return {'items': [], 'next_cursor': null};
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

    if (data['items'] is List) {
      final items = data['items'] as List;
      return items
          .whereType<Map<String, dynamic>>()
          .map((e) => LedgerTransaction.fromApiResponse(e))
          .toList();
    }
    return [];
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
    final body = <String, dynamic>{
      'type': type.toUpperCase(),
      'amount': amount.toStringAsFixed(2),
      'title': title.trim(),
      'category_id': categoryId,
      'paid_by_member_id': paidByMemberId,
      'transaction_date': transactionDate.toUtc().toIso8601String(),
      'payment_mode': paymentMode.toUpperCase(),
    };
    if (beneficiaryMemberId != null && beneficiaryMemberId.isNotEmpty) {
      body['beneficiary_member_id'] = beneficiaryMemberId;
    }
    if (eventId != null && eventId.isNotEmpty) {
      body['event_id'] = eventId;
    }
    if (notes != null && notes.trim().isNotEmpty) {
      body['notes'] = notes.trim();
    }

    final response = await apiClient.post(
      ApiConfig.transactions,
      body: body,
      requiresAuth: true,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }
    throw ApiException(
        statusCode: 500, message: 'Failed to create transaction');
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    await apiClient.delete(
      ApiConfig.transactionById(transactionId),
      requiresAuth: true,
    );
  }
}
