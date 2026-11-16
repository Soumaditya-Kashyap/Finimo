import '../core/api_client.dart';
import '../core/api_config.dart';
import '../models/conjoined_event_summary.dart';
import '../models/home_dashboard_data.dart';
import 'dashboard_repository.dart';

class HttpDashboardRepository implements DashboardRepository {
  final ApiClient apiClient;

  HttpDashboardRepository({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  @override
  Future<HomeDashboardData> getDashboardMetrics({
    int? month,
    int? year,
    String? memberId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (month != null) queryParams['month'] = month;
    if (year != null) queryParams['year'] = year;
    if (memberId != null && memberId.isNotEmpty) {
      queryParams['member_id'] = memberId;
    }

    final insightsResp = await apiClient.get(
      ApiConfig.insightsSummary,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      requiresAuth: true,
    );

    int accountsCount = 1;
    try {
      final familyResp = await apiClient.get(ApiConfig.family, requiresAuth: true);
      if (familyResp is Map<String, dynamic>) {
        accountsCount = (familyResp['active_members_count'] as int?) ??
            (familyResp['members_count'] as int?) ??
            1;
      }
    } catch (_) {}

    if (insightsResp is Map<String, dynamic>) {
      return HomeDashboardData.fromInsightsResponse(
        insightsResp,
        jointAccountsCount: accountsCount,
      );
    }

    throw ApiException(
      statusCode: 500,
      message: 'Failed to load dashboard insights from server',
    );
  }

  @override
  Future<ConjoinedEventSummary?> getActiveConjoinedEvent() async {
    try {
      final response = await apiClient.get(
        ApiConfig.events,
        queryParameters: {'status': 'ACTIVE'},
        requiresAuth: true,
      );
      if (response is List && response.isNotEmpty) {
        final activeItem = response.firstWhere(
          (item) =>
              item is Map<String, dynamic> &&
              item['status']?.toString().toUpperCase() == 'ACTIVE',
          orElse: () => null,
        );

        if (activeItem is Map<String, dynamic>) {
          return ConjoinedEventSummary.fromApiResponse(activeItem);
        }
      }
    } catch (_) {
      // In case of network error or no events created yet
      return null;
    }
    return null;
  }
}

