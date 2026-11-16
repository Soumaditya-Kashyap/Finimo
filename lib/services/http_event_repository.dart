import '../core/api_client.dart';
import '../core/api_config.dart';
import 'event_repository.dart';

class HttpEventRepository implements EventRepository {
  final ApiClient apiClient;

  HttpEventRepository({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  @override
  Future<List<Map<String, dynamic>>> getEvents({String? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status.toUpperCase();
    }

    try {
      final response = await apiClient.get(
        ApiConfig.events,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        requiresAuth: true,
      );

      if (response is List) {
        return response.whereType<Map<String, dynamic>>().toList();
      }
    } catch (_) {
      return [];
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> getEventById(String id) async {
    final response = await apiClient.get(
      ApiConfig.eventById(id),
      requiresAuth: true,
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw ApiException(statusCode: 500, message: 'Failed to load event');
  }

  @override
  Future<Map<String, dynamic>> getEventItems(String id) async {
    final response = await apiClient.get(
      ApiConfig.eventItems(id),
      requiresAuth: true,
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw ApiException(statusCode: 500, message: 'Failed to load event items');
  }

  @override
  Future<Map<String, dynamic>> createEvent({
    required String title,
    required double budgetCap,
    required DateTime startDate,
    DateTime? endDate,
    String status = 'ACTIVE',
  }) async {
    final body = <String, dynamic>{
      'title': title.trim(),
      'budget_cap': budgetCap.toStringAsFixed(2),
      'start_date': startDate.toIso8601String().substring(0, 10),
      'status': status.toUpperCase(),
    };
    if (endDate != null) {
      body['end_date'] = endDate.toIso8601String().substring(0, 10);
    }

    final response = await apiClient.post(
      ApiConfig.events,
      body: body,
      requiresAuth: true,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }
    throw ApiException(statusCode: 500, message: 'Failed to create event');
  }

  @override
  Future<Map<String, dynamic>> updateEvent(
    String id, {
    String? title,
    double? budgetCap,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    final body = <String, dynamic>{};
    if (title != null && title.trim().isNotEmpty) {
      body['title'] = title.trim();
    }
    if (budgetCap != null) {
      body['budget_cap'] = budgetCap.toStringAsFixed(2);
    }
    if (startDate != null) {
      body['start_date'] = startDate.toIso8601String().substring(0, 10);
    }
    if (endDate != null) {
      body['end_date'] = endDate.toIso8601String().substring(0, 10);
    }
    if (status != null && status.isNotEmpty) {
      body['status'] = status.toUpperCase();
    }

    final response = await apiClient.patch(
      ApiConfig.eventById(id),
      body: body,
      requiresAuth: true,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }
    throw ApiException(statusCode: 500, message: 'Failed to update event');
  }

  @override
  Future<void> deleteEvent(String id) async {
    await apiClient.delete(
      ApiConfig.eventById(id),
      requiresAuth: true,
    );
  }

  @override
  Future<Map<String, dynamic>> addEventReceipt(
    String id, {
    required double amount,
    required String title,
    required String categoryId,
    required String paidByMemberId,
    String? beneficiaryMemberId,
    required DateTime transactionDate,
    String paymentMode = 'UPI',
    String? notes,
  }) async {
    final body = <String, dynamic>{
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
    if (notes != null && notes.trim().isNotEmpty) {
      body['notes'] = notes.trim();
    }

    final response = await apiClient.post(
      ApiConfig.eventAddReceipt(id),
      body: body,
      requiresAuth: true,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }
    throw ApiException(
      statusCode: 500,
      message: 'Failed to add receipt to event',
    );
  }
}
