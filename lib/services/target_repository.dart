export 'http_target_repository.dart';

abstract class TargetRepository {
  Future<List<Map<String, dynamic>>> getTargets({bool? isActive});

  Future<Map<String, dynamic>> getTargetById(String id);

  Future<Map<String, dynamic>> createTarget({
    required String targetName,
    required double limitAmount,
    required String timeFrame,
    String? categoryId,
    int notifyThresholdPct = 80,
  });

  Future<Map<String, dynamic>> updateTarget(
    String id, {
    String? targetName,
    double? limitAmount,
    String? timeFrame,
    String? categoryId,
    int? notifyThresholdPct,
    bool? isActive,
  });

  Future<void> deleteTarget(String id);
}

class MockTargetRepository implements TargetRepository {
  final List<Map<String, dynamic>> _targets = [];

  MockTargetRepository({List<Map<String, dynamic>>? initialTargets}) {
    if (initialTargets != null) {
      _targets.addAll(initialTargets);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTargets({bool? isActive}) async {
    if (isActive != null) {
      return _targets
          .where((t) => t['is_active'] == isActive)
          .toList();
    }
    return List.from(_targets);
  }

  @override
  Future<Map<String, dynamic>> getTargetById(String id) async {
    return _targets.firstWhere(
      (t) => t['id'] == id,
      orElse: () => throw Exception('Target not found'),
    );
  }

  @override
  Future<Map<String, dynamic>> createTarget({
    required String targetName,
    required double limitAmount,
    required String timeFrame,
    String? categoryId,
    int notifyThresholdPct = 80,
  }) async {
    final newTarget = {
      'id': 'target_mock_${DateTime.now().millisecondsSinceEpoch}',
      'target_name': targetName,
      'limit_amount': limitAmount.toStringAsFixed(2),
      'time_frame': timeFrame,
      'category_id': categoryId,
      'notify_threshold_pct': notifyThresholdPct,
      'is_active': true,
      'current_period_spent': '0.00',
      'percentage_consumed': 0.0,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    _targets.add(newTarget);
    return newTarget;
  }

  @override
  Future<Map<String, dynamic>> updateTarget(
    String id, {
    String? targetName,
    double? limitAmount,
    String? timeFrame,
    String? categoryId,
    int? notifyThresholdPct,
    bool? isActive,
  }) async {
    final idx = _targets.indexWhere((t) => t['id'] == id);
    if (idx != -1) {
      final existing = Map<String, dynamic>.from(_targets[idx]);
      if (targetName != null) existing['target_name'] = targetName;
      if (limitAmount != null) {
        existing['limit_amount'] = limitAmount.toStringAsFixed(2);
      }
      if (timeFrame != null) existing['time_frame'] = timeFrame;
      if (categoryId != null) existing['category_id'] = categoryId;
      if (notifyThresholdPct != null) {
        existing['notify_threshold_pct'] = notifyThresholdPct;
      }
      if (isActive != null) existing['is_active'] = isActive;
      existing['updated_at'] = DateTime.now().toUtc().toIso8601String();
      _targets[idx] = existing;
      return existing;
    }
    throw Exception('Target not found');
  }

  @override
  Future<void> deleteTarget(String id) async {
    _targets.removeWhere((t) => t['id'] == id);
  }
}
