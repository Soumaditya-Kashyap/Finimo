import '../core/api_client.dart';
import '../core/api_config.dart';
import '../models/deep_dive_models.dart';
import 'insight_repository.dart';

class HttpInsightRepository implements InsightRepository {
  final ApiClient apiClient;

  HttpInsightRepository({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  @override
  Future<DeepDiveSummaryData> getInsightsSummary({
    int? month,
    int? year,
    String? memberId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (month != null) queryParams['month'] = month;
    if (year != null) queryParams['year'] = year;
    if (memberId != null && memberId.trim().isNotEmpty) {
      queryParams['member_id'] = memberId.trim();
    }

    final response = await apiClient.get(
      ApiConfig.insightsSummary,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      requiresAuth: true,
    );

    if (response is Map<String, dynamic>) {
      return DeepDiveSummaryData.fromApiResponse(response);
    }

    throw ApiException(
      statusCode: 500,
      message: 'Unexpected insights response format from server',
    );
  }
}
