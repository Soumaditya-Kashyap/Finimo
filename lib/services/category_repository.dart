import '../models/transaction_category.dart';
export 'http_category_repository.dart';

abstract class CategoryRepository {
  Future<List<TransactionCategory>> getCategories({
    String? type,
    bool forceRefresh = false,
  });
}

class MockCategoryRepository implements CategoryRepository {
  @override
  Future<List<TransactionCategory>> getCategories({
    String? type,
    bool forceRefresh = false,
  }) async {
    if (type != null && type.isNotEmpty) {
      return TransactionCategory.defaultCategories
          .where((c) => c.type.toUpperCase() == type.toUpperCase())
          .toList();
    }
    return TransactionCategory.defaultCategories;
  }
}

