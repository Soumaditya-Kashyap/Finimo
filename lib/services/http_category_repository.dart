import '../core/api_client.dart';
import '../core/api_config.dart';
import '../models/transaction_category.dart';
import 'category_repository.dart';

class HttpCategoryRepository implements CategoryRepository {
  final ApiClient apiClient;
  List<TransactionCategory>? _cachedAll;

  HttpCategoryRepository({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  @override
  Future<List<TransactionCategory>> getCategories({
    String? type,
    bool forceRefresh = false,
  }) async {
    // If not forcing refresh and cached list is available, return filtered from cache
    if (!forceRefresh && _cachedAll != null && _cachedAll!.isNotEmpty) {
      if (type != null && type.isNotEmpty) {
        return _cachedAll!
            .where((c) => c.type.toUpperCase() == type.toUpperCase())
            .toList();
      }
      return List<TransactionCategory>.from(_cachedAll!);
    }

    try {
      final queryParams = <String, dynamic>{};
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type.toUpperCase();
      }

      final response = await apiClient.get(
        ApiConfig.categories,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        requiresAuth: true,
      );

      if (response is List) {
        final list = response
            .whereType<Map<String, dynamic>>()
            .map((e) => TransactionCategory.fromJson(e))
            .toList();

        if (type == null || type.isEmpty) {
          _cachedAll = list;
        }
        return list;
      }
    } catch (_) {
      // Fallback to default categories if network/auth fails
    }

    if (type != null && type.isNotEmpty) {
      return TransactionCategory.defaultCategories
          .where((c) => c.type.toUpperCase() == type.toUpperCase())
          .toList();
    }
    return TransactionCategory.defaultCategories;
  }
}

