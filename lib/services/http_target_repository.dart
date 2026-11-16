import '../core/api_client.dart';
import '../core/api_config.dart';
import 'target_repository.dart';

class HttpTargetRepository implements TargetRepository {
  final ApiClient apiClient;

  HttpTargetRepository({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  @override
  Future<List<Map<String, dynamic>>> getTargets({bool? isActive}) async {
    final queryParams = <String, dynamic>{};
    if (isActive != null) {
      queryParams['is_active'] = isActive;
    }

    try {
      final response = await apiClient.get(
        ApiConfig.targets,
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
  Future<Map<String, dynamic>> getTargetById(String id) async {
    final response = await apiClient.get(
      ApiConfig.targetById(id),
      requiresAuth: true,
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw ApiException(statusCode: 500, message: 'Failed to load target');
  }

  @override
  Future<Map<String, dynamic>> createTarget({
    required String targetName,
    required double limitAmount,
    required String timeFrame,
    String? categoryId,
    int notifyThresholdPct = 80,
  }) async {
    final body = <String, dynamic>{
      'target_name': targetName.trim(),
      'limit_amount': limitAmount.toStringAsFixed(2),
      'time_frame': timeFrame.toUpperCase(),
      'notify_threshold_pct': notifyThresholdPct,
    };
    if (categoryId != null && categoryId.isNotEmpty) {
      body['category_id'] = categoryId;
    }

    final response = await apiClient.post(
      ApiConfig.targets,
      body: body,
      requiresAuth: true,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }
    throw ApiException(statusCode: 500, message: 'Failed to create target');
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
    final body = <String, dynamic>{};
    if (targetName != null && targetName.trim().isNotEmpty) {
      body['target_name'] = targetName.trim();
    }
    if (limitAmount != null) {
      body['limit_amount'] = limitAmount.toStringAsFixed(2);
    }
    if (timeFrame != null && timeFrame.isNotEmpty) {
      body['time_frame'] = timeFrame.toUpperCase();
    }
    if (categoryId != null) {
      body['category_id'] = categoryId;
    }
    if (notifyThresholdPct != null) {
      body['notify_threshold_pct'] = notifyThresholdPct;
    }
    if (isActive != null) {
      body['is_active'] = isActive;
    }

    final response = await apiClient.patch(
      ApiConfig.targetById(id),
      body: body,
      requiresAuth: true,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }
    throw ApiException(statusCode: 500, message: 'Failed to update target');
  }

  @override
  Future<void> deleteTarget(String id) async {
    await apiClient.delete(
      ApiConfig.targetById(id),
      requiresAuth: true,
    );
  }
}
