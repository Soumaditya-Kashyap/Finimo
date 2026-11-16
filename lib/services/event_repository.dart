export 'http_event_repository.dart';

abstract class EventRepository {
  Future<List<Map<String, dynamic>>> getEvents({String? status});

  Future<Map<String, dynamic>> getEventById(String id);

  Future<Map<String, dynamic>> getEventItems(String id);

  Future<Map<String, dynamic>> createEvent({
    required String title,
    required double budgetCap,
    required DateTime startDate,
    DateTime? endDate,
    String status = 'ACTIVE',
  });

  Future<Map<String, dynamic>> updateEvent(
    String id, {
    String? title,
    double? budgetCap,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  });

  Future<void> deleteEvent(String id);

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
  });
}

class MockEventRepository implements EventRepository {
  final List<Map<String, dynamic>> _events = [];
  final Map<String, List<Map<String, dynamic>>> _eventReceipts = {};

  MockEventRepository({
    List<Map<String, dynamic>>? initialEvents,
    Map<String, List<Map<String, dynamic>>>? initialReceipts,
  }) {
    if (initialEvents != null) _events.addAll(initialEvents);
    if (initialReceipts != null) _eventReceipts.addAll(initialReceipts);
  }

  @override
  Future<List<Map<String, dynamic>>> getEvents({String? status}) async {
    if (status != null && status.isNotEmpty) {
      return _events
          .where((e) =>
              e['status']?.toString().toUpperCase() == status.toUpperCase())
          .toList();
    }
    return List.from(_events);
  }

  @override
  Future<Map<String, dynamic>> getEventById(String id) async {
    return _events.firstWhere(
      (e) => e['id'] == id,
      orElse: () => throw Exception('Event not found'),
    );
  }

  @override
  Future<Map<String, dynamic>> getEventItems(String id) async {
    final event = await getEventById(id);
    final items = _eventReceipts[id] ?? [];
    return {
      'event': event,
      'items': items,
    };
  }

  @override
  Future<Map<String, dynamic>> createEvent({
    required String title,
    required double budgetCap,
    required DateTime startDate,
    DateTime? endDate,
    String status = 'ACTIVE',
  }) async {
    final newEvent = {
      'id': 'event_mock_${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'budget_cap': budgetCap.toStringAsFixed(2),
      'start_date': startDate.toIso8601String().substring(0, 10),
      'end_date': endDate?.toIso8601String().substring(0, 10),
      'status': status.toUpperCase(),
      'total_spent': '0.00',
      'remaining_budget': budgetCap.toStringAsFixed(2),
      'percentage_used': 0.0,
      'contributing_members_count': 1,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    _events.add(newEvent);
    return newEvent;
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
    final idx = _events.indexWhere((e) => e['id'] == id);
    if (idx != -1) {
      final existing = Map<String, dynamic>.from(_events[idx]);
      if (title != null) existing['title'] = title;
      if (budgetCap != null) {
        existing['budget_cap'] = budgetCap.toStringAsFixed(2);
      }
      if (startDate != null) {
        existing['start_date'] = startDate.toIso8601String().substring(0, 10);
      }
      if (endDate != null) {
        existing['end_date'] = endDate.toIso8601String().substring(0, 10);
      }
      if (status != null) existing['status'] = status.toUpperCase();
      existing['updated_at'] = DateTime.now().toUtc().toIso8601String();
      _events[idx] = existing;
      return existing;
    }
    throw Exception('Event not found');
  }

  @override
  Future<void> deleteEvent(String id) async {
    _events.removeWhere((e) => e['id'] == id);
    _eventReceipts.remove(id);
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
    final receipt = {
      'id': 'receipt_${DateTime.now().millisecondsSinceEpoch}',
      'event_id': id,
      'amount': amount.toStringAsFixed(2),
      'title': title,
      'type': 'EXPENSE',
      'category_id': categoryId,
      'paid_by_member_id': paidByMemberId,
      'beneficiary_member_id': beneficiaryMemberId,
      'transaction_date': transactionDate.toUtc().toIso8601String(),
      'payment_mode': paymentMode,
      'notes': notes,
    };
    _eventReceipts.putIfAbsent(id, () => []).add(receipt);
    return receipt;
  }
}
